/*
 * @file	CNReadline.swift
 * @brief	Define CNReadline class
 * @par Copyright
 *   Copyright (C) 2019-2021 Steel Wheels Project
 */

import Foundation
import Darwin

open class CNReadline
{
	public enum Result {
		case	none
		case	string(String, Int)	// string, index
		case	error(NSError)
	}

	private enum ReadMode {
		case	input
		case	popupLines(PopupLines)
	}

	private struct PopupLines {
		var cursorDiff:		Int
		var addedLines:		Int

		public init(cursorDiff diff: Int, addedLines lines: Int){
			cursorDiff	= diff
			addedLines	= lines
		}
	}

	private var mReadMode:		ReadMode
	private var mHistory:		CNCommandHistory
	private var mLine:		String
	private var mCurrentIndex:	String.Index
	private var mCodeQueue:		CNQueue<CNEscapeCode>
	private var mComplemeter:	CNCommandComplemeter

	private var mHistoryCommandExpression:	NSRegularExpression

	public init(terminalInfo terminfo: CNTerminalInfo, environment env: CNEnvironment) {
		mReadMode	= .input
		mHistory	= CNCommandHistory()
		mLine		= ""
		mCurrentIndex	= mLine.startIndex
		mCodeQueue	= CNQueue()
		let cmdtable	= CNCommandTable()
		mComplemeter	= CNCommandComplemeter(terminalInfo: terminfo, commandTable: cmdtable)
		mHistoryCommandExpression = try! NSRegularExpression(pattern: #"^\s*!([0-9]+)\s*$"#, options: [])

		cmdtable.read(from: env)
	}

	public var history: Array<String> {
		get { return mHistory.commandHistory }
	}

	open func readLine(console cons: CNFileConsole) -> Result {
		switch cons.inputFile.gets() {
		case .str(let str):
			/* Erace popuped lines if it exist */
			switch mReadMode {
			case .input:
				break	// Do nothing
			case .popupLines(let plines):
				popLines(popupLines: plines, console: cons)
				mReadMode = .input
			}
			switch CNEscapeCode.decode(string: str) {
			case .ok(let codes):
				for code in codes {
					mCodeQueue.push(code)
				}
			case .error(let err):
				return .error(err)
			}
		case .endOfFile:
			break
		case .null:
			break
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
			result = readLine(string: str, console: cons)
		case .newline:
			result = determineLine(console: cons)
		case .tab:
			result = complement(console: cons)
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
			result = selectHistory(delta: -num, console: cons)
		case .cursorDown(let num), .cursorNextLine(let num):
			result = selectHistory(delta: +num, console: cons)
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

	private func readLine(string str: String, console cons: CNConsole) -> Result {
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
		return .none
	}

	private func determineLine(console cons: CNConsole) -> Result {
		/* Move cursor to the end */
		moveCursorToEnd(console: cons)

		let result: Result
		if let repcmd = convertToHistoryCommand(string: mLine) {
			result = replaceLine(newLine: repcmd, console: cons)
		} else {
			/* Normal command */
			let dist = mLine.distance(from: mLine.startIndex, to: mCurrentIndex)
			result 		= .string(mLine, dist)
			mHistory.append(command: mLine)
			mLine  		= ""
			mCurrentIndex	= mLine.startIndex
		}
		return result
	}

	private func convertToHistoryCommand(string str: String) -> String? {// History ID
		let matches = mHistoryCommandExpression.matches(in: str, options: [], range: NSRange(location: 0, length: str.count))
		if matches.count > 0 {
			let match = matches[0]
			if match.numberOfRanges > 1 {
				let range = match.range(at: 1)
				let start  = str.index(str.startIndex, offsetBy: range.location)
				let end    = str.index(start, offsetBy: range.length)
				let pat    = String(str[start..<end])
				if let val = Int(pat) {
					return mHistory.command(at: val)
				}
			}
		}
		return nil
	}

	private func replaceLine(newLine newline: String, console cons: CNConsole) -> Result {
		/* Set return value */
		let result: Result = .string(newline, newline.count)

		/* Reset newline */
		mLine  		= ""
		mCurrentIndex	= mLine.startIndex
		return result
	}

	private func complement(console cons: CNConsole) -> Result {
		switch mComplemeter.complement(string: mLine, index: mCurrentIndex) {
		case .none:
			break
		case .matched(let newline):
			replaceCurrentLine(newLine: newline, console: cons)
		case .candidates(let lines):
			let popup = pushLines(lines: lines, console: cons)
			mReadMode = .popupLines(popup)
		}
		return .none
	}

	private func selectHistory(delta val: Int, console cons: CNConsole) -> Result {
		if let cmd = mHistory.select(delta: val, latest: mLine) {
			moveCursorToEnd(console: cons)
			replaceCurrentLine(newLine: cmd, console: cons)
		}
		return .none
	}

	private func moveCursorToEnd(console cons: CNConsole) {
		var mvcount = 0
		while mCurrentIndex < mLine.endIndex {
			mCurrentIndex = mLine.index(after: mCurrentIndex)
			mvcount += 1
		}
		if mvcount > 0 {
			cons.print(string: CNEscapeCode.cursorForward(mvcount).encode())
		}
	}

	private func replaceCurrentLine(newLine str: String, console cons: CNConsole) {
		/* Delete current line */
		var delcode: String = ""
		for _ in 0..<mLine.count {
			delcode += CNEscapeCode.delete.encode()
		}
		cons.print(string: delcode)
		/* Put newline */
		cons.print(string: str)
		/* Reset newline */
		mLine  		= str
		mCurrentIndex	= mLine.endIndex
	}

	private func pushLines(lines srclines: Array<String>, console cons: CNConsole) -> PopupLines {
		/* Move to end of line */
		let mvcnt = mLine.distance(from: mCurrentIndex, to: mLine.endIndex)
		var ecode = CNEscapeCode.cursorForward(mvcnt).encode()
		mCurrentIndex = mLine.endIndex
		/* Append lines */
		for line in srclines {
			ecode += CNEscapeCode.string("\n" + line).encode()
		}
		/* Execute the code */
		cons.print(string: ecode)
		return PopupLines(cursorDiff: mvcnt, addedLines: srclines.count)
	}

	private func popLines(popupLines plines: PopupLines, console cons: CNConsole){
		/* Remove lines */
		var ecode: String = ""
		for _ in 0..<plines.addedLines {
			ecode += CNEscapeCode.eraceEntireLine.encode()
		}
		/* Restore line position */
		ecode += CNEscapeCode.cursorBackward(plines.cursorDiff).encode()
		mCurrentIndex = mLine.index(mCurrentIndex, offsetBy: -plines.cursorDiff)
		/* Execute the code */
		cons.print(string: ecode)
	}
}

