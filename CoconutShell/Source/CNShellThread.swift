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
	private struct ReadlineStatus {
		var	doPrompt	: Bool
		var	editingLine	: String
		var 	editingPosition	: Int

		public init(doPrompt prompt: Bool){
			doPrompt	= prompt
			editingLine	= ""
			editingPosition	= 0
		}
	}

	private var mReadline:		CNReadline
	private var mReadlineStatus:	ReadlineStatus
	private var mTerminalInfo:	CNTerminalInfo
	private var mIsCancelled:	Bool

	public var readline: CNReadline { get { return mReadline }}
	public var terminalInfo: CNTerminalInfo { get { return mTerminalInfo }}

	public init(processManager procmgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, complementor compl: CNComplementor, environment env: CNEnvironment){
		mReadline 	= CNReadline(complementor: compl, environment: env)
		mReadlineStatus	= ReadlineStatus(doPrompt: true)
		mTerminalInfo	= CNTerminalInfo(width: 80, height: 25)
		mIsCancelled	= false
		super.init(processManager: procmgr, input: instrm, output: outstrm, error: errstrm, environment: env)
	}

	open override func main(argument arg: CNNativeValue) -> Int32 {
		/* Request updating screen size */
		let reqsz  = CNEscapeCode.requestScreenSize
		self.console.print(string: reqsz.encode())

		/* Setup terminal */
		while !mIsCancelled {
			let BS  = CNEscapeCode.backspace.encode()
			let DEL = BS + " " + BS

			if mReadlineStatus.doPrompt {
				self.console.print(string: promptString() + mReadlineStatus.editingLine)
				mReadlineStatus.doPrompt = false
			}
			/* Read command line */
			switch mReadline.readLine(console: self.console, terminalInfo: mTerminalInfo) {
			case .commandLine(let cmdline, let determined):
				let newline	= cmdline.string
				let newpos	= cmdline.position
				if determined {
					/* Replace replay command */
					let newcmd = mReadline.replaceReplayCommand(source: newline)

					/* Execute command */
					console.print(string: "\n") // Execute at new line
					let _ = execute(command: newcmd)

					/* Save current command */
					mReadline.addCommand(command: newcmd)

					/* Update history */
					let histmgr = CNCommandHistory.shared
					histmgr.set(history: mReadline.history())

					/* Reset terminal */
					let resetstr = CNEscapeCode.resetCharacterAttribute.encode()
					console.print(string: resetstr)

					/* Print prompt again */
					mReadlineStatus.doPrompt	= true
					mReadlineStatus.editingLine     = ""
					mReadlineStatus.editingPosition	= 0
				} else {
					/* Move cursor to end of line */
					let forward = mReadlineStatus.editingLine.count - mReadlineStatus.editingPosition
					let fwdstr  = CNEscapeCode.cursorForward(forward).encode()
					if forward > 0 {
						console.print(string: fwdstr)
					}
					/* Erace current command line */
					let curlen  = mReadlineStatus.editingLine.count
					for _ in 0..<curlen {
						console.print(string: DEL)
					}
					/* Print new command line */
					console.print(string: newline)

					/* Adjust cursor */
					let newlen = newline.count
					let back   = newlen - newpos
					let bakstr = CNEscapeCode.cursorBackward(back).encode()
					if back > 0 {
						console.print(string: bakstr)
					}

					/* Update current line*/
					mReadlineStatus.editingLine     = newline
					mReadlineStatus.editingPosition = newpos
				}
			case .escapeCode(let code):
				switch code {
				case .screenSize(let width, let height):
					//NSLog("Update terminal info: \(width) \(height)")
					mTerminalInfo.width	= width
					mTerminalInfo.height	= height
				case .eot:
					cancel()
				default:
					console.error(string: "ECODE: \(code.description())\n")
				}
			case .none:
				break
			}
		}
		return 0
	}

	public func cancel(){
		mIsCancelled = true
	}

	open func promptString() -> String {
		return "$ "
	}

	open func execute(command cmd: String) -> Bool {	// -> OK/Fail
		console.error(string: "execute: \(cmd)\n")
		return false
	}
}
