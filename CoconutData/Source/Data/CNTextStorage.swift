/**
 * @file	CNTextStorage.swift
 * @brief	Extend NSAttributedString class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public extension NSMutableAttributedString
{
	func execute(base baseidx: String.Index, index idx: String.Index, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo, escapeCode code: CNEscapeCode) -> String.Index? { /* -> Next index */
		var result: String.Index?
		switch code {
		case .string(let str):
			let astr = NSAttributedString(string: str, font: fnt, terminalInfo: terminfo)
			result = self.write(string: astr, at: idx, terminalInfo: terminfo)
		case .eot:
			result = idx // ignore
		case .newline:
			let astr = NSAttributedString(string: "\n")
			result = self.insert(string: astr, at: idx, terminalInfo: terminfo)
		case .tab:
			let astr = NSAttributedString(string: "\t")
			result = self.write(string: astr, at: idx, terminalInfo: terminfo)
		case .backspace:
			result = self.moveCursorBackward(from: idx, number: 1, terminalInfo: terminfo)
		case .delete:
			result = self.deleteBackwardCharacters(from: idx, number: 1, terminalInfo: terminfo)
		case .cursorUp(let n):
			result = self.moveCursorUpOrDown(from: idx, doUp: true, number: n, terminalInfo: terminfo)
		case .cursorDown(let n):
			result = self.moveCursorUpOrDown(from: idx, doUp: false, number: n, terminalInfo: terminfo)
		case .cursorForward(let n):
			result = self.moveCursorForward(from: idx, number: n, terminalInfo: terminfo)
		case .cursorBackward(let n):
			result = self.moveCursorBackward(from: idx, number: n, terminalInfo: terminfo)
		case .cursorNextLine(let n):
			result = self.moveCursorUpOrDown(from: idx, doUp: false, number: n, terminalInfo: terminfo)
		case .cursorPreviousLine(let n):
			result = self.moveCursorUpOrDown(from: idx, doUp: true, number: n, terminalInfo: terminfo)
		case .cursorHolizontalAbsolute(let pos):
			result = self.moveCursorTo(from: idx, x: pos, terminalInfo: terminfo)
		case .cursorPoisition(let x, let y):
			result = self.moveCursorTo(base: baseidx, x: x, y: y, terminalInfo: terminfo)
		case .eraceFromCursorToEnd:
			result = self.deleteForwardAllCharacters(from: idx, terminalInfo: terminfo)
		case .eraceFromCursorToBegin:
			result = self.deleteBackwardAllCharacters(from: idx, terminalInfo: terminfo)
		case .eraceFromCursorToRight:
			result = self.deleteForwardAllCharacters(from: idx, terminalInfo: terminfo)
		case .eraceFromCursorToLeft:
			result = self.deleteBackwardAllCharacters(from: idx, terminalInfo: terminfo)
		case .eraceEntireLine:
			result = self.deleteEntireLine(from: idx, terminalInfo: terminfo)
		case .eraceEntireBuffer:
			self.clear(terminalInfo: terminfo)
			result = string.startIndex
		case .scrollUp:
			result = nil			// not accepted
		case .scrollDown:
			result = nil			// not accepted
		case .resetAll:
			self.clear(terminalInfo: terminfo)
			terminfo.reset()
			result = string.startIndex
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
		case .screenSize(let width, let height):
			if terminfo.width != width || terminfo.height != height {
				/* Update padding */
				if terminfo.isAlternative {
					self.resize(width: width, height: height, font: fnt, terminalInfo: terminfo)
				}
				terminfo.width  = width
				terminfo.height = height
			}
			result = idx			// ignore
		case .selectAltScreen(let doalt):
			if terminfo.isAlternative != doalt {
				/* Keep current text */
				let range   = NSRange(location: 0, length: self.length)
				let curctxt = self.attributedSubstring(from: range)
				let curidx  = self.string.distance(from: self.string.startIndex, to: idx)
				/* Restore reserved text */
				self.setAttributedString(terminfo.reservedText)
				result = self.string.index(self.string.startIndex, offsetBy: terminfo.reservedIndex)
				/* Update padding */
				if doalt {
					self.resize(width: terminfo.width, height: terminfo.height, font: fnt, terminalInfo: terminfo)
				}
				/* Reserve current text */
				terminfo.reservedText	= curctxt
				terminfo.reservedIndex	= curidx
				/* Switch mode */
				terminfo.isAlternative = doalt
			} else {
				result = idx
			}
		}
		return result
	}
}

