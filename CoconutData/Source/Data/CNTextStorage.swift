/**
 * @file	CNTextStorage.swift
 * @brief	Extend NSAttributedString class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public extension NSMutableAttributedString
{
	func execute(index idx: Int, terminalInfo tinfo: CNTerminalInfo, escapeCode code: CNEscapeCode) -> Int? { /* -> Next index */
		var result: Int? = nil
		switch code {
		case .string(let str):
			let astr = self.attributedString(string: str, terminalInfo: tinfo)
			result = self.write(string: astr, at: idx)
		case .eot:
			result = idx // ignore
		case .newline:
			/* Move cursor to end */
			let idx2 = self.moveCursorToLineEnd(from: idx)
			let astr = NSAttributedString(string: "\n")
			result = self.write(string: astr, at: idx2)
		case .tab:
			let astr = NSAttributedString(string: "\t")
			result = self.write(string: astr, at: idx)
		case .backspace:
			result = self.backspace(from: idx)
		case .delete:
			result = self.deleteBackwardCharacters(at: idx, number: 1)
		case .cursorUp(let n):
			result = self.moveCursorUp(from: idx, number: n, moveToHead: false)
		case .cursorDown(let n):
			result = self.moveCursorDown(from: idx, number: n, moveToHead: false)
		case .cursorForward(let n):
			result = self.moveCursorForward(from: idx, number: n)
		case .cursorBackward(let n):
			result = self.moveCursorBackward(from: idx, number: n)
		case .cursorNextLine(let n):
			result = self.moveCursorDown(from: idx, number: n, moveToHead: true)
		case .cursorPreviousLine(let n):
			result = self.moveCursorUp(from: idx, number: n, moveToHead: true)
		case .cursorHolizontalAbsolute(let pos):
			result = self.moveCursorTo(from: idx, x: pos, y: nil)
		case .cursorPoisition(let x, let y):
			result = self.moveCursorTo(from: idx, x: x, y: y)
		case .eraceFromCursorToEnd:
			result = self.deleteForwardAllCharacters(at: idx)
		case .eraceFromCursorToBegin:
			result = self.deleteBackwardAllCharacters(at: idx)
		case .eraceFromCursorToRight:
			result = self.deleteForwardLineCharacters(at: idx)
		case .eraceFromCursorToLeft:
			result = self.deleteBackwardLineCharacters(at: idx)
		case .eraceEntireLine:
			result = self.deleteEntireLine(at: idx)
		case .eraceEntireBuffer:
			self.clear()
			result = 0
		case .scrollUp:
			result = nil			// not accepted
		case .scrollDown:
			result = nil			// not accepted
		case .foregroundColor(_):
			result = nil
		case .backgroundColor(_):
			result = nil
		case .setNormalAttributes:
			result = nil
		case .requestScreenSize:
			result = nil 			// not accepted
		case .screenSize(_, _):
			result = idx			// ignore
		}
		return result
	}

	private func attributedString(string str: String, terminalInfo tinfo: CNTerminalInfo) -> NSAttributedString {
		let fcol = tinfo.foregroundColor.toObject()
		let bcol = tinfo.backgroundColor.toObject()
		let attr: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.foregroundColor: fcol,
			NSAttributedString.Key.backgroundColor: bcol
		]
		return NSAttributedString(string: str, attributes: attr)
	}
}
