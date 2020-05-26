/**
 * @file	CNCurses.swift
 * @brief	Define CNCurses class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNCurses
{
	private var mTerminalInfo:	CNTerminalInfo
	private var mConsole:		CNFileConsole
	private var mHandler:		((_ hdl: FileHandle) -> Void)?
	private var mBuffer:		String
	private var mLock:		NSLock

	public init(console cons: CNFileConsole, terminalInfo terminfo: CNTerminalInfo) {
		mTerminalInfo	= terminfo
		mConsole	= cons
		mHandler	= nil
		mBuffer		= ""
		mLock		= NSLock()
	}

	public var width:  Int { get { return mTerminalInfo.width	}}
	public var height: Int { get { return mTerminalInfo.height	}}

	public func start() {
		/* Select alternative screen */
		let selalt = CNEscapeCode.selectAltScreen(true)
		mConsole.print(string: selalt.encode())

		/* Erace buffer */
		let erace = CNEscapeCode.eraceEntireBuffer
		mConsole.print(string: erace.encode())

		/* Replace handler */
		mHandler = mConsole.inputHandle.readabilityHandler
		mConsole.inputHandle.readabilityHandler = {
			(_ hdl: FileHandle) -> Void in
			self.mLock.lock()
			if let str = String(data: hdl.availableData, encoding: .utf8) {
				self.mBuffer.append(str)
			}
			self.mLock.unlock()
		}
	}

	public func end() {
		let code = CNEscapeCode.selectAltScreen(false)
		mConsole.print(string: code.encode())

		/* Restore handler */
		mConsole.inputHandle.readabilityHandler = mHandler
	}

	public func moveTo(x xpos: Int, y ypos: Int) {
		let x    = max(0, min(xpos, mTerminalInfo.width  - 1))
		let y    = max(0, min(ypos, mTerminalInfo.height - 1))
		let code = CNEscapeCode.cursorPoisition(y, x)
		mConsole.print(string: code.encode())
	}

	public func inkey() -> Character? {
		let result: Character?
		mLock.lock()
		if let c = mBuffer.first {
			mBuffer.removeFirst()
			result = c
		} else {
			Thread.sleep(forTimeInterval: 0.1)
			result = nil
		}
		mLock.unlock()
		return result
	}
}
