/**
 * @file	CNShellThread.swift
 * @brief	Define CNShellThread class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

open class CNShellThread: CNThread
{
	private var mEnvironment:	CNShellEnvironment
	private var mReadline:		CNReadline
	private var mConfig:		CNConfig

	public init(input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream,  environment env: CNShellEnvironment, config conf: CNConfig, terminationHander termhdlr: TerminationHandler?){
		mEnvironment	= env
		mReadline 	= CNReadline()
		mConfig		= conf
		super.init(input: instrm, output: outstrm, error: errstrm, terminationHander: termhdlr)
		mReadline.console = super.console
	}

	public var environment: CNShellEnvironment	{ get { return mEnvironment	}}
	public var config: CNConfig			{ get { return mConfig		}}

	open func promptString() -> String {
		return "$ "
	}

	open override func start() {
		super.start()
	}

	open override func mainOperation() -> Int32 {
		let BS  = CNEscapeCode.backspace.encode()
		let DEL = BS + " " + BS

		var doprompt    = true
		var currentline = ""
		var currentpos  = 0
		while !isCancelled {
			if doprompt {
				self.console.print(string: promptString() + currentline)
				doprompt = false
			}
			/* Read command line */
			switch mReadline.readLine() {
			case .commandLine(let cmdline):
				let determined       = cmdline.didDetermined
				let (newline, newpos) = cmdline.get()
				if determined {
					/* Execute command */
					console.print(string: "\n") // Execute at new line
					execute(command: newline)
					/* Print prompt again */
					currentline = ""
					currentpos  = 0
					doprompt    = true
				} else {
					/* Move cursor to end of line */
					let forward = currentline.count - currentpos
					let fwdstr  = CNEscapeCode.cursorForward(forward).encode()
					if forward > 0 {
						console.print(string: fwdstr)
					}
					/* Erace current command line */
					let curlen  = currentline.count
					for _ in 0..<curlen {
						console.print(string: DEL)
					}
					/* Print new command line */
					console.print(string: newline)
					/* Adjust cursor */
					let newlen = newline.count
					let back   = newlen - newpos
					let bakstr = CNEscapeCode.cursorBack(back).encode()
					if back > 0 {
						console.print(string: bakstr)
					}
					/* Update current line*/
					currentline = newline
					currentpos  = newpos
				}
			case .escapeCode(let code):
				console.error(string: "ECODE: \(code.description())\n")
			case .none:
				break
			}
		}
		return 0
	}

	open func execute(command cmd: String) {
		console.error(string: "execute: \(cmd)\n")
	}
}
