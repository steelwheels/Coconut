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
			let cmdline = mReadline.readLine()
			if cmdline.didUpdated {
				let context = cmdline.context

				let fixedcmds = context.fixedCommands
				if fixedcmds.count > 0 {
					/* Execute commands */
					for cmd in fixedcmds {
						console.print(string: "\n") // Execute at new line
						execute(command: cmd)
					}
					/* Print prompt again */
					currentline = context.commandLine
					doprompt    = true
				} else {
					/* Move cursor to end of line */
					let forward = currentline.count - currentpos
					if forward > 0 {
						let movstr = CNEscapeCode.cursorForward(forward).encode()
						console.print(string: movstr)
					}
					/* Erace current command line */
					let curlen  = currentline.count
					for _ in 0..<curlen {
						console.print(string: DEL)
					}
					/* Print new command line */
					let newline = context.commandLine
					console.print(string: newline)
					/* Adjust cursor */
					let newlen = newline.count
					let newpos = context.position
					let back   = newlen - newpos
					if back > 0 {
						let movl = CNEscapeCode.cursorBack(back).encode()
						console.print(string: movl)
					}
					/* Update current line*/
					currentline = newline
					currentpos  = newpos
				}
			}
		}
		return 0
	}

	open func execute(command cmd: String) {
		NSLog("Override this method (a)")
	}

/*
	private func addString(string str: String) -> Bool {
		var newstr = mInputedString + str
		while newstr.lengthOfBytes(using: .utf8) > 0 {
			if let nlidx = newstr.firstIndex(of: "\n") {
				/* put string before newline */
				let line = newstr[..<nlidx]
				self.inputLine(line: String(line))
				/* Keep string after newline */
				let nxtidx = newstr.index(after: nlidx)
				if nxtidx < newstr.endIndex {
					newstr = String(newstr[nxtidx..<newstr.endIndex])
				} else {
					newstr = ""
				}
			} else {
				break
			}
		}
		mInputedString = newstr
		return true
	}


*/
}
