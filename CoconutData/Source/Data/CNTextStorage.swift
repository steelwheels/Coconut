/**
 * @file	CNTextStorage.swift
 * @brief	Extend NSAttributedString class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

private var mIsAltenativeSelected:	Bool			= false
private var mAlternativeIndex:		Int			= 0
private var mAlternativeString:		NSAttributedString	= NSAttributedString(string: "")

public extension NSMutableAttributedString
{
	func execute(base baseidx: String.Index, index idx: String.Index, doInsert doins: Bool, font fnt: CNFont, format fmt: CNStringFormat, escapeCode code: CNEscapeCode) -> String.Index? { /* -> Next index */
		var result: String.Index?
		switch code {
		case .string(let str):
			let astr = NSAttributedString(string: str, font: fnt, format: fmt)
			result = self.write(string: astr, at: idx)
		case .eot:
			result = idx // ignore
		case .newline:
			let astr = NSAttributedString(string: "\n")
			result = self.insert(string: astr, at: idx)
		case .tab:
			let astr = NSAttributedString(string: "\t")
			result = self.write(string: astr, at: idx)
		case .backspace:
			result = self.string.moveCursorBackward(from: idx, number: 1)
		case .delete:
			result = self.deleteBackwardCharacters(from: idx, number: 1)
		case .cursorUp(let n):
			result = self.string.moveCursorUpOrDown(from: idx, doUp: true, number: n)
		case .cursorDown(let n):
			result = self.string.moveCursorUpOrDown(from: idx, doUp: false, number: n)
		case .cursorForward(let n):
			result = self.string.moveCursorForward(from: idx, number: n)
		case .cursorBackward(let n):
			result = self.string.moveCursorBackward(from: idx, number: n)
		case .cursorNextLine(let n):
			result = self.string.moveCursorUpOrDown(from: idx, doUp: false, number: n)
		case .cursorPreviousLine(let n):
			result = self.string.moveCursorUpOrDown(from: idx, doUp: true, number: n)
		case .cursorHolizontalAbsolute(let pos):
			result = self.string.moveCursorTo(from: idx, x: pos)
		case .cursorPoisition(let x, let y):
			result = self.string.moveCursorTo(base: baseidx, x: x, y: y)
		case .eraceFromCursorToEnd:
			result = self.deleteForwardAllCharacters(from: idx)
		case .eraceFromCursorToBegin:
			result = self.deleteBackwardAllCharacters(from: idx)
		case .eraceFromCursorToRight:
			result = self.deleteForwardAllCharacters(from: idx)
		case .eraceFromCursorToLeft:
			result = self.deleteBackwardAllCharacters(from: idx)
		case .eraceEntireLine:
			result = self.deleteEntireLine(from: idx)
		case .eraceEntireBuffer:
			self.clear()
			result = string.startIndex
		case .scrollUp:
			result = nil			// not accepted
		case .scrollDown:
			result = nil			// not accepted
		case .resetCharacterAttribute:
			result = nil			// not accepted
		case .boldCharacter(_):
			result = nil
		case .underlineCharacter(_):
			result = nil
		case .blinkCharacter(_):
			result = nil
		case .reverseCharacter(_):
			result = nil
		case .foregroundColor(_):
			result = nil
		case .defaultForegroundColor:
			result = nil
		case .backgroundColor(_):
			result = nil
		case .defaultBackgroundColor:
			result = nil
		case .requestScreenSize:
			result = nil 			// not accepted
		case .screenSize(_, _):
			result = idx			// ignore
		case .selectAltScreen(let doalt):
			if mIsAltenativeSelected != doalt {
				/* Keep current text */
				let range   = NSRange(location: 0, length: self.length)
				let curctxt = self.attributedSubstring(from: range)
				let curidx  = self.string.distance(from: self.string.startIndex, to: idx)
				/* Restor if it exist */
				self.setAttributedString(mAlternativeString)
				let altidx = self.string.index(self.string.startIndex, offsetBy: mAlternativeIndex)
				/* Update */
				mAlternativeString    = curctxt
				mAlternativeIndex     = curidx
				mIsAltenativeSelected = doalt
				result = altidx
			} else {
				result = idx
			}
		}
		return result
	}
}

