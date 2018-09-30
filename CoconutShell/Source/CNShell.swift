/*
 * @file	CNShell.swift
 * @brief	Define CNShell class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import CoconutData
import Foundation

#if os(OSX)

public class CNShell
{
	public class func execute(command cmd: String, console cons: CNConsole, terminateHandler termhdl: ((_ exitcode: Int32) -> Void)?) -> Process {
		let inpipe  = Pipe()
		let outpipe = Pipe()
		let errpipe = Pipe()

		inpipe.fileHandleForWriting.writeabilityHandler = {
			(filehandle: FileHandle) -> Void in
			if let str = cons.scan() {
				if let data = str.data(using: .utf8) {
					filehandle.write(data)
				} else {
					NSLog("Error encoding data: \(str)")
				}
			}
		}
		outpipe.fileHandleForReading.readabilityHandler = {
			(_ handle: FileHandle) -> Void in
			if let str = String(data: handle.availableData, encoding: String.Encoding.utf8) {
				cons.print(string: str)
			} else {
				NSLog("Error decoding data: \(handle.availableData)")
			}
		}
		errpipe.fileHandleForReading.readabilityHandler = {
			(_ handle: FileHandle) -> Void in
			if let str = String(data: handle.availableData, encoding: String.Encoding.utf8) {
				cons.error(string: str)
			} else {
				NSLog("Error decoding data: \(handle.availableData)")
			}
		}

		return CNShell.execute(command: cmd, input: inpipe, output: outpipe, error: errpipe, terminateHandler: termhdl)
	}

	public class func execute(command cmd: String, input inpipe: Pipe?, output outpipe: Pipe?, error errpipe: Pipe?, terminateHandler termhdl: ((_ exitcode: Int32) -> Void)?) -> Process {
		let process  		= Process()

		process.launchPath	= "/bin/sh"
		process.arguments	= ["-c", cmd]

		if let pipe = inpipe {
			process.standardInput = pipe
		} else {
			process.standardInput = FileHandle.standardInput
		}
		if let pipe = outpipe {
			process.standardOutput = pipe
		} else {
			process.standardOutput = FileHandle.standardOutput
		}
		if let pipe = errpipe {
			process.standardError = pipe
		} else {
			process.standardError = FileHandle.standardError
		}

		if let handler = termhdl  {
			process.terminationHandler = {
				(process: Process) -> Void in
				handler(process.terminationStatus)
			}
		}

		process.launch()
		return process
	}
	
	private static var commandTable: Dictionary<String, String> = [:]

	public class func searchCommand(commandName name: String) -> String? {
		if let cmdpath = commandTable[name] {
			return cmdpath
		} else if let pathstr = ProcessInfo.processInfo.environment["PATH"] {
			let fmanager = FileManager.default

			let pathes = pathstr.components(separatedBy: ":")
			for path in pathes {
				let cmdpath = path + "/" + name
				if fmanager.fileExists(atPath: cmdpath) {
					if fmanager.isExecutableFile(atPath: cmdpath) {
						commandTable[name] = cmdpath
						return cmdpath
					}
				}
			}
		}
		return nil
	}
}

#endif /* os(OSX) */

