/**
 * @file	UTShell.swift
 * @brief	Test function for CNShell class
 * @par Copyright
 *   Copyright (C) 2015-2019 Steel Wheels Project
 */

import CoconutShell
import CoconutData
import Foundation

private class UTShellThread: CNShellThread {
	public var printed = false

	public override func promptString() -> String {
		return "UTShell$ "
	}

	open override func execute(command cmd: String) -> Bool {
		console.print(string: "UTShell/In \"\(cmd)\"\n")
		printed = true
		return true
	}
}

public func testShell(console cons: CNFileConsole) -> Bool
{
	let inpipe  = Pipe()
	let outpipe = Pipe()
	let errpipe = Pipe()

	let queue   = DispatchQueue(label: "testShell", qos: .default, attributes: .concurrent)
	let instrm  = CNFileStream.pipe(inpipe)
	let outstrm = CNFileStream.pipe(outpipe)
	let errstrm = CNFileStream.pipe(errpipe)
	let env     = CNEnvironment()
	let shell   = UTShellThread(queue: queue, input: instrm, output: outstrm, error: errstrm, environment: env)

	outpipe.fileHandleForReading.readabilityHandler = {
		(_ hdl: FileHandle) -> Void in
		let data = hdl.availableData
		if let str = String(data: data, encoding: .utf8) {
			cons.print(string: "UTShell/Out: \"\(str)\"\n")
		}
	}

	errpipe.fileHandleForReading.readabilityHandler = {
		(_ hdl: FileHandle) -> Void in
		let data = hdl.availableData
		if let str = String(data: data, encoding: .utf8) {
			cons.print(string: "UTShell/Err: \"\(str)\"\n")
		}
	}

	cons.print(string: "testShell: Start\n")
	shell.start(arguments: [])

	queue.async {
		inpipe.fileHandleForWriting.write(string: "command-1\n")
		inpipe.fileHandleForWriting.write(string: "command-2\n")
		inpipe.fileHandleForWriting.write(string: "command-3\n")
		inpipe.fileHandleForWriting.write(string: "a!1b\n")
		inpipe.fileHandleForWriting.write(string: CNEscapeCode.eot.encode())
		inpipe.fileHandleForWriting.closeFile()
	}

	cons.print(string: "testShell: Wait until exit\n")
	let ecode = shell.waitUntilExit()

	cons.print(string: "testShell: Done with error code \(ecode)\n")
	return true
}

/*


public func testShell(console cons: CNFileConsole) -> Bool
{


	/* Check request from shell */
	var result      = true
	var didresponce = false
	DispatchQueue.main.async {
		while !didresponce {
			let data = shell.outputFileHandle.availableData
			if let str = String(data: data, encoding: .utf8) {
				switch CNEscapeCode.decode(string: str) {
				case .ok(let codes):
					for code in codes {
						switch code {
						case .string(let str):
							cons.print(string: "Output string: \"\(str)\"\n")
						case .requestScreenSize:
							shell.inputFileHandle.write(string: CNEscapeCode.screenSize(80, 25).encode())
							didresponce = true
						default:
							cons.print(string: "[Error] Ignored: \(code.description())\n")
							didresponce = true
							result      = false
						}
					}
				case .error(let err):
					cons.print(string: "[Error] Failed to decode: \(str) \(err.description())\n")
					didresponce = true
					result      = false
				}
			} else {
				cons.print(string: "[Error] Failed to decode request\n")
				didresponce = true
				result      = false
			}
		}
	}

	/* input command */
	shell.inputFileHandle.write(string: "shell-command\n")
	shell.inputFileHandle.closeFile()

	/* Wait some prited */
	cons.print(string: "testShell: Wait until printed\n")
	while !shell.printed {
	}

	cons.print(string: "testShell: Wait until exit\n")
	shell.cancel()
	let ecode = shell.waitUntilExit()
	cons.print(string: "testShell: exitCode=\(ecode)\n")

	return result
}

*/

