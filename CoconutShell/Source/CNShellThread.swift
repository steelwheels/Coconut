/**
 * @file	CNShellThread.swift
 * @brief	Define CNShellThread class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

@objc open class CNShellThread: CNThread
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

	private var mCommandHistoty:	CNCommandHistory
	private var mReadline:		CNReadline
	private var mReadlineStatus:	ReadlineStatus
	private var mTerminalInfo:	CNTerminalInfo
	private var mIsCancelled:	Bool

	public var history: CNCommandHistory	{ get { return mCommandHistoty	}}
	public var readline: CNReadline		{ get { return mReadline	}}
	public var terminalInfo: CNTerminalInfo	{ get { return mTerminalInfo	}}

	public init(processManager procmgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, terminalInfo terminfo: CNTerminalInfo, environment env: CNEnvironment){
		mCommandHistoty	= CNCommandHistory()
		mReadline 	= CNReadline(commandHistory: mCommandHistoty)
		mReadlineStatus	= ReadlineStatus(doPrompt: true)
		mTerminalInfo	= terminfo
		mIsCancelled	= false
		super.init(processManager: procmgr, input: instrm, output: outstrm, error: errstrm, environment: env)
	}

	open override func main(argument arg: CNNativeValue) -> Int32 {
		/* Request updating screen size */
		let reqsz  = CNEscapeCode.requestScreenSize
		self.console.print(string: reqsz.encode())

		/* Setup terminal */
		while !mIsCancelled {
			/* Insert prompt */
			insertPrompt()

			/* Read command line */
			switch mReadline.readLine(console: self.console) {
			case .string(let str, let pos, let determined):
				if determined {
					determineCommandLine(newLine: str)
				} else {
					updateCommandLine(newLine: str, newPosition: pos)
				}
			case .none:
				break
			case .error(let err):
				NSLog("[Error] \(err.description()) at \(#function)")
				break
			@unknown default:
				NSLog("Unknown case at \(#function)")
				cancel()
			}
		}
		return 0
	}

	private func insertPrompt() {
		if mReadlineStatus.doPrompt {
			self.console.print(string: promptString() + mReadlineStatus.editingLine)
			mReadlineStatus.doPrompt = false
		}
	}

	private func determineCommandLine(newLine newline: String) {
		/* Replace replay command */
		/*
		let newcmd = mReadline.replaceReplayCommand(source: newline)
		*/

		/* Execute command */
		console.print(string: "\n") // Execute at new line
		execute(command: newline)

		/*
		/* Save current command */
		let readline = self.mReadline
		readline.addCommand(command: newcmd)

		/* Update history */
		let histmgr = CNCommandHistory.shared
		histmgr.set(history: readline.history())
*/

		/* Reset terminal */
		let resetstr = CNEscapeCode.resetCharacterAttribute.encode()
		self.console.print(string: resetstr)

		/* Print prompt again */
		self.mReadlineStatus.doPrompt		= true
		self.mReadlineStatus.editingLine	= ""
		self.mReadlineStatus.editingPosition	= 0
	}

	private func updateCommandLine(newLine newline: String, newPosition newpos: Int) {
		let BS  = CNEscapeCode.backspace.encode()
		let DEL = BS + " " + BS

		/* Move cursor to end of line */
		let forward = mReadlineStatus.editingLine.count - mReadlineStatus.editingPosition
		if forward > 0 {
			let fwdstr  = CNEscapeCode.cursorForward(forward).encode()
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

	public func cancel(){
		mIsCancelled = true
	}

	open func promptString() -> String {
		return "$ "
	}

	open func execute(command cmd: String) {
		console.error(string: "execute: \(cmd)\n")
	}
}
