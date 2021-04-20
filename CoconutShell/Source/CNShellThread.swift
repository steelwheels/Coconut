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

	private var mReadline:		CNReadline
	private var mReadlineStatus:	ReadlineStatus
	private var mTerminalInfo:	CNTerminalInfo
	private var mIsCancelled:	Bool

	public var readline: CNReadline		{ get { return mReadline	}}
	public var terminalInfo: CNTerminalInfo	{ get { return mTerminalInfo	}}

	public init(processManager procmgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, terminalInfo terminfo: CNTerminalInfo, environment env: CNEnvironment){
		mReadline 	= CNReadline(terminalInfo: terminfo, environment: env)
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
			case .string(let str, _):
				determineCommandLine(newLine: str)
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
		/* Execute command */
		console.print(string: "\n") // Execute at new line
		execute(command: newline)

		/* Reset terminal */
		let resetstr = CNEscapeCode.resetCharacterAttribute.encode()
		self.console.print(string: resetstr)

		/* Print prompt again */
		self.mReadlineStatus.doPrompt		= true
		self.mReadlineStatus.editingLine	= ""
		self.mReadlineStatus.editingPosition	= 0
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
