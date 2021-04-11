/*
 * @file	CNReadline.swift
 * @brief	Define CNReadline class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation
import Darwin

open class CNReadline
{
	public typealias ReadError = CNEscapeCode.DecodeError

	private var mHistory:		CNCommandHistory
	private var mLine:		String
	private var mCurrentIndex:	String.Index
	private var mCodeQueue:		CNQueue<CNEscapeCode>

	public enum Result {
		case	none
		case	string(String, Int, Bool)	// string, index, determined
		case	error(ReadError)
	}

	public init(commandHistory hist: CNCommandHistory) {
		mHistory	= hist
		mLine		= ""
		mCurrentIndex	= mLine.startIndex
		mCodeQueue	= CNQueue()
	}

	public var history: Array<String> {
		get { return mHistory.commandHistory }
	}

	open func readLine(console cons: CNConsole) -> Result {
		if let str = cons.scan() {
			switch CNEscapeCode.decode(string: str) {
			case .ok(let codes):
				for code in codes {
					mCodeQueue.push(code)
				}
			case .error(let err):
				return .error(err)
			}
		}
		if let code = mCodeQueue.pop() {
			return readLine(escapeCode: code, console: cons)
		} else {
			return .none
		}
	}

	private func readLine(escapeCode code: CNEscapeCode, console cons: CNConsole) -> Result {
		let result: Result
		switch code {
		case .string(let str):
			/* Update the current line */
			mLine.insert(contentsOf: str, at: mCurrentIndex)
			/* Get the substring after current index */
			let pstr = mLine.suffix(from: mCurrentIndex)
			cons.print(string: String(pstr))
			/* Forward index for inserted string */
			mCurrentIndex = mLine.index(mCurrentIndex, offsetBy: str.count)
			/* Rollback cursor for substring */
			let len = pstr.count - str.count
			if len > 0 {
				cons.print(string: CNEscapeCode.cursorBackward(len).encode())
			}
			result = .none
		case .newline:
			let dist = mLine.distance(from: mLine.startIndex, to: mCurrentIndex)
			result 		= .string(mLine, dist, true)
			mHistory.append(command: mLine)
			mLine  		= ""
			mCurrentIndex	= mLine.startIndex
		case .tab:
			result = complement()
		case .backspace:
			if mLine.startIndex < mCurrentIndex {
				mCurrentIndex = mLine.index(before: mCurrentIndex)
				cons.print(string: code.encode())
			}
			result = .none
		case .delete:
			if mLine.startIndex < mCurrentIndex {
				let newidx = mLine.index(before: mCurrentIndex)
				mLine.remove(at: newidx)
				mCurrentIndex = newidx
				cons.print(string: code.encode())
			}
			result = .none
		case .cursorUp(let num), .cursorPreviousLine(let num):
			result = selectHistory(delta: num)
		case .cursorDown(let num), .cursorNextLine(let num):
			result = selectHistory(delta: -num)
		case .cursorForward(let delta):
			for _ in 0..<delta {
				if mCurrentIndex < mLine.endIndex {
					mCurrentIndex = mLine.index(after: mCurrentIndex)
					cons.print(string: code.encode())
				} else {
					break
				}
			}
			result = .none
		case .cursorBackward(let delta):
			for _ in 0..<delta {
				if mLine.startIndex < mCurrentIndex {
					mCurrentIndex = mLine.index(before: mCurrentIndex)
					cons.print(string: code.encode())
				} else {
					break
				}
			}
			result = .none
		default:
			/* Not supported */
			result = .none
		}
		return result
	}

	private func complement() -> Result {
		return .none
	}

	private func selectHistory(delta val: Int) -> Result {
		return .none
	}
}

