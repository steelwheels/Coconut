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
	private var mConsole:		CNConsole

	public init(console cons: CNConsole, terminalInfo terminfo: CNTerminalInfo) {
		mTerminalInfo	= terminfo
		mConsole	= cons
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
	}

	public func end() {
		let code = CNEscapeCode.selectAltScreen(false)
		mConsole.print(string: code.encode())
	}

	public func moveTo(x xpos: Int, y ypos: Int) {
		let x    = max(0, min(xpos, mTerminalInfo.width  - 1))
		let y    = max(0, min(ypos, mTerminalInfo.height - 1))
		let code = CNEscapeCode.cursorPoisition(y, x)
		mConsole.print(string: code.encode())
	}
}
