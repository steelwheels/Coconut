/**
 * @file	CNCurses.swift
 * @brief	Define CNCurses class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNCurses
{
	public enum Color: Int32 {
		case	black	= 0
		case	red 	= 1
		case	green	= 2
		case 	yellow	= 3
		case 	blue	= 4
		case	magenta	= 5
		case	cyan	= 6
		case	white	= 7
	}

	private var mTerminalInfo:	CNTerminalInfo
	private var mConsole:		CNFileConsole
	private var mHandler:		((_ hdl: FileHandle) -> Void)?
	private var mBuffer:		String
	private var mLock:		NSLock

	public var foregroundColor:	CNColor {
		get		{ return mTerminalInfo.foregroundColor		}
		set(newcol) 	{ mTerminalInfo.foregroundColor = newcol	}
	}

	public var backgroundColor:	CNColor {
		get 		{ return mTerminalInfo.backgroundColor 		}
		set(newcol)	{ mTerminalInfo.backgroundColor = newcol	}
	}

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

		#if false
		/* Erace buffer */
		let erace = CNEscapeCode.eraceEntireBuffer
		mConsole.print(string: erace.encode())
		#endif

		/* Replace handler */
		mHandler = mConsole.inputHandle.readabilityHandler
		mConsole.inputHandle.readabilityHandler = {
			(_ hdl: FileHandle) -> Void in
			self.mLock.lock()
			if let str = String.stringFromData(data: hdl.availableData){
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
		let col  = clip(value: xpos, min: 0, max: mTerminalInfo.width  - 1)
		let row  = clip(value: ypos, min: 0, max: mTerminalInfo.height - 1)
		let code = CNEscapeCode.cursorPosition(row+1, col+1) // started from 1
		mConsole.print(string: code.encode())
	}

	public func put(string str: String) {
		let code = CNEscapeCode.string(str)
		mConsole.print(string: code.encode())
	}

	public func inkey() -> Character? {
		let result: Character?
		mLock.lock()
		if let c = mBuffer.first {
			mBuffer.removeFirst()
			result  = c
		} else {
			result  = nil
		}
		mLock.unlock()
		return result
	}

	public func fill(x xpos: Int, y ypos: Int, width dwidth: Int, height dheight: Int, char c: Character) {
		let x0 = clip(value: xpos, min: 0, max: mTerminalInfo.width  - 1)
		let y0 = clip(value: ypos, min: 0, max: mTerminalInfo.height - 1)

		let x1 = clip(value: xpos + dwidth,  min: 0, max: mTerminalInfo.width)
		let y1 = clip(value: ypos + dheight, min: 0, max: mTerminalInfo.height)

		let len = x1 - x0
		if len > 0 && y0 <= y1 {
			mConsole.print(string: CNEscapeCode.foregroundColor(mTerminalInfo.foregroundColor).encode())
			mConsole.print(string: CNEscapeCode.backgroundColor(mTerminalInfo.backgroundColor).encode())
			let str = String(repeating: c, count: len)
			for y in y0..<y1 {
				moveTo(x: x0, y: y)
				put(string: str)
			}
		}
	}

	private func clip(value v: Int, min minv: Int, max maxv: Int) -> Int {
		return max(minv, min(maxv, v))
	}
}
