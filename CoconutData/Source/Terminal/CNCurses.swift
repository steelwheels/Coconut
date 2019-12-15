/**
 * @file	CNCurses.swift
 * @brief	Define CNCurses class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public class CNCurses
{
	public struct Size {
		public var 	width: 		Int
		public var	height:		Int
		public init(width w: Int, height h: Int){
			width  = w
			height = h
		}
	}

	private var 	mConsole:	CNFileConsole
	private var	mTerminalInfo:	CNTerminalInfo

	public init(console cons: CNFileConsole, terminalInfo tinfo: CNTerminalInfo) {
		mConsole	= cons
		mTerminalInfo	= tinfo
	}

	public var size: Size {
		return Size(width: mTerminalInfo.width, height: mTerminalInfo.height)
	}

	public func setup(){
		/* Set raw mode */
		let _ = mConsole.inputHandle.setRawMode(enable: true)

		/* Send setup requests */
		let reqcmd = CNEscapeCode.requestScreenSize
		mConsole.print(string: reqcmd.encode())

		/* Receive ack commands */
		var didfinish = false
		while !didfinish {
			if let str = mConsole.scan() {
				switch CNEscapeCode.decode(string: str) {
				case .ok(let codes):
					for code in codes {
						receiveSetup(escapeCode: code)
					}
					didfinish = didFinishSetup()
				case .error(let err):
					mConsole.error(string: "[Error] Failed to setup curses: \(err.description())")
				}
			}
		}
	}

	public func finalize() {
		/* Reset raw mode */
		let _ = mConsole.inputHandle.setRawMode(enable: false)
	}

	private func receiveSetup(escapeCode code: CNEscapeCode) {
		switch code {
		case .screenSize(let width, let height):
			mTerminalInfo.width	= width
			mTerminalInfo.height	= height
		default:
			mConsole.error(string: "Unrecogized command: \(code.description())")
		}
	}

	private func didFinishSetup() -> Bool {
		return mTerminalInfo.width > 0
	}
}

