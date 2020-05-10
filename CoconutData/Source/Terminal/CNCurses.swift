/**
 * @file	CNCurses.swift
 * @brief	Define CNCurses class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNCurses
{
	private var mEnvironment:	CNEnvironment
	private var mConsole:		CNConsole

	public init(console cons: CNConsole, environment env: CNEnvironment) {
		mEnvironment	= env
		mConsole	= cons
	}

	public var columns: Int { get { return mEnvironment.columns	}}
	public var lines:   Int { get { return mEnvironment.lines	}}

	public func start() {
		let code = CNEscapeCode.selectAltScreen(true)
		mConsole.print(string: code.encode())
	}

	public func end() {
		let code = CNEscapeCode.selectAltScreen(false)
		mConsole.print(string: code.encode())
	}

	public func moveTo(x xpos: Int, y ypos: Int) {
		let x    = max(0, min(xpos, mEnvironment.columns - 1))
		let y    = max(0, min(ypos, mEnvironment.lines   - 1))
		let code = CNEscapeCode.cursorPoisition(x, y)
		mConsole.print(string: code.encode())
	}
}
