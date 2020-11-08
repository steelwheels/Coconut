/**
 * @file	CNTextStorage.swift
 * @brief	Extend NSAttributedString class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public extension NSMutableAttributedString
{
	func execute(base baseidx: Int, index idx: Int, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo, escapeCode code: CNEscapeCode) -> Int? { /* -> Next index */
		var result: Int?
		switch code {
		case .string(let str):
			result = self.write(string: str, at: idx, font: fnt, terminalInfo: terminfo)
		case .eot:
			result = idx // ignore
		case .newline:
			result = self.insert(string: "\n", at: idx, font: fnt, terminalInfo: terminfo)
		case .tab:
			result = self.write(string: "\t", at: idx, font: fnt, terminalInfo: terminfo)
		case .backspace:
			result = self.moveCursorBackward(from: idx, number: 1)
		case .delete:
			result = self.deleteBackwardCharacters(from: idx, number: 1)
		case .cursorUp(let n):
			result = self.moveCursorUpOrDown(from: idx, doUp: true, number: n)
		case .cursorDown(let n):
			result = self.moveCursorUpOrDown(from: idx, doUp: false, number: n)
		case .cursorForward(let n):
			result = self.moveCursorForward(from: idx, number: n)
		case .cursorBackward(let n):
			result = self.moveCursorBackward(from: idx, number: n)
		case .cursorNextLine(let n):
			result = self.moveCursorUpOrDown(from: idx, doUp: false, number: n)
		case .cursorPreviousLine(let n):
			result = self.moveCursorUpOrDown(from: idx, doUp: true, number: n)
		case .cursorHolizontalAbsolute(let pos):
			if pos >= 1 {
				result = self.moveCursorTo(from: idx, x: pos-1)
			} else {
				NSLog("cursorHolizontalAbsolute: Underflow")
				result = idx	// ignore
			}
		case .saveCursorPosition:
			result = nil		// not accepted
		case .restoreCursorPosition:
			result = nil 		// not accepted
		case .cursorPosition(let row, let column):
			if row>=1 && column>=1 {
				result = self.moveCursorTo(base: baseidx, x: column-1, y: row-1)
			} else {
				NSLog("cursorHolizontalAbsolute: Underflow")
				result = idx	// ignore
			}
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
			self.clear(font: fnt, terminalInfo: terminfo)
			result = 0
		case .scrollUp(let lines):
			result = self.scrollUp(lines: lines, font: fnt, terminalInfo: terminfo)
		case .scrollDown(let lines):
			result = self.scrollDown(lines: lines, font: fnt, terminalInfo: terminfo)
		case .resetAll:
			self.clear(font: fnt, terminalInfo: terminfo)
			terminfo.reset()
			result = 0
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
				let range   = NSRange(location: 0, length: self.string.count)
				let curctxt = self.attributedSubstring(from: range)
				let curidx  = idx
				/* Restore reserved text */
				self.beginEditing()
				self.setAttributedString(terminfo.reservedText)
				self.endEditing()
				result = terminfo.reservedIndex
				/* Clear context */
				if doalt {
					terminfo.isAlternative = doalt // update mode before executing
					self.clear(font: fnt, terminalInfo: terminfo)
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

