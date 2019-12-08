/*
 * @file	CNCurses.swift
 * @brief	Define CNCurses class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNCurses
{
	private var mCurrentBuffer:	CNQueue<CNEscapeCode>

	public init(){
		mCurrentBuffer	= CNQueue()
	}

	public enum ControlCommand {
		case	none
		case	escapeCode(CNEscapeCode)
	}

	open func readLine(console cons: CNConsole) -> ControlCommand {
		/* Scan input */
		if let str = cons.scan() {
			switch CNEscapeCode.decode(string: str) {
			case .ok(let codes):
				for code in codes {
					mCurrentBuffer.push(code)
				}
			case .error(let err):
				let msg = "[Error] " + err.description()
				cons.error(string: msg)
			}
		}
		/* Return result */
		if let code = mCurrentBuffer.pop() {
			return .escapeCode(code)
		} else {
			return .none
		}
	}

	open func scan(console cons: CNConsole) -> String? {
		return cons.scan()
	}
}
