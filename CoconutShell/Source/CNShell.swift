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
	public enum Port {
	case File(CNDataFile)
	case Pipe(CNPipe)
	case Standard
	}

	public class func execute(command cmd: String, inputFile infile: Port, outputFile outfile: Port, errorFile errfile: Port, terminateHandler termhdl: ((_ exitcode: Int32) -> Void)?) -> Process {
		let process  		= Process()

		process.launchPath	= "/bin/sh"
		process.arguments	= ["-c", cmd]

		/* Standard input */
		switch infile {
		case .File(let file):
			process.standardInput = file.fileHandle
		case .Pipe(let pipe):
			process.standardInput = pipe.pipe
		case .Standard:
			process.standardInput = FileHandle.standardInput
		}

		/* Standard output */
		switch outfile {
		case .File(let file):
			process.standardOutput = file.fileHandle
		case .Pipe(let pipe):
			process.standardOutput = pipe.pipe
		case .Standard:
			process.standardOutput = FileHandle.standardOutput
		}

		/* Standard error */
		switch errfile {
		case .File(let file):
			process.standardError = file.fileHandle
		case .Pipe(let pipe):
			process.standardError = pipe.pipe
		case .Standard:
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

