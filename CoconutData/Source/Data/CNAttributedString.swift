/**
 * @file	CNAttributedString.swift
 * @brief	Extend NSAttributedString class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import Foundation

public class CNTerminalInfo
{
	public var	isAlternative	: Bool

	public var 	width		: Int
	public var	height		: Int

	public var	foregroundColor	: CNColor
	public var	backgroundColor	: CNColor

	public var	doBold		: Bool
	public var	doItalic	: Bool
	public var	doUnderLine	: Bool
	public var	doReverse	: Bool

	public var	reservedIndex:	Int
	public var	reservedText:	NSAttributedString

	public init(width widthval: Int, height heightval: Int) {
		isAlternative		= false
		width			= widthval
		height			= heightval

		foregroundColor		= CNColor.black
		backgroundColor		= CNColor.white
		doBold			= false
		doItalic		= false
		doUnderLine		= false
		doReverse		= false

		reservedIndex		= 0
		reservedText		= NSAttributedString(string: "")
	}

	public func reset() {
		foregroundColor		= CNColor.black
		backgroundColor		= CNColor.white
		doBold			= false
		doItalic		= false
		doUnderLine		= false
		doReverse		= false
	}
}

public extension NSAttributedString
{
	convenience init(string str: String, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) {
		let newfont = CNFontManager.shared.convert(font: fnt, terminalInfo: terminfo)

		let fcol = terminfo.doReverse ? terminfo.backgroundColor : terminfo.foregroundColor
		let bcol = terminfo.doReverse ? terminfo.foregroundColor : terminfo.backgroundColor
		var attrs: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.foregroundColor: fcol,
			NSAttributedString.Key.backgroundColor:	bcol,
			NSAttributedString.Key.font:		newfont
		]
		if terminfo.doUnderLine {
			attrs[NSAttributedString.Key.underlineStyle] = NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue)
		}
		self.init(string: str, attributes: attrs)
	}

	func character(at index: Int) -> Character? {
		let str = self.string
		if index < str.count {
			let idx = str.index(str.startIndex, offsetBy: index)
			return str[idx]
		}
		return nil
	}

	func lineCount(from start: Int, to end: Int) -> Int {
		let str    = self.string
		let last   = str.endIndex
		var idx    = str.index(str.startIndex, offsetBy: start)
		var diff   = end - start
		var result = 0
		while idx < last && diff > 0 {
			if str[idx].isNewline {
				result += 1
			}
			idx   = str.index(after: idx)
			diff -= 1
		}
		return result
	}

	func distanceFromLineStart(to index: Int) -> Int {
		var result = 0
		let str    = self.string
		var idx    = str.index(str.startIndex, offsetBy: index)
		let start  = str.startIndex
		while start < idx {
			let prev = str.index(before: idx)
			if str[prev].isNewline {
				break
			}
			idx     = prev
			result += 1
		}
		return result
	}

	func distanceToLineEnd(from index: Int) -> Int {
		var result = 0
		let str    = self.string
		var idx    = str.index(str.startIndex, offsetBy: index)
		let end    = str.endIndex
		while idx < end {
			if str[idx].isNewline {
				break
			}
			idx     = str.index(after: idx)
			result += 1
		}
		return result
	}

	func moveCursorForward(from index: Int) -> Int? {
		let str = self.string
		let idx = str.index(str.startIndex, offsetBy: index)
		let end = str.endIndex
		if idx < end {
			if !str[idx].isNewline {
				return index + 1
			}
		}
		return nil
	}

	func moveCursorForward(from index: Int, number num: Int) -> Int {
		let str    = self.string
		var result = index
		var idx    = str.index(str.startIndex, offsetBy: index)
		let end    = str.endIndex
		for _ in 0..<num {
			if idx < end {
				if str[idx].isNewline {
					break
				}
				idx = str.index(after: idx)
				result += 1
			} else {
				break
			}
		}
		return result
	}

	func moveCursorToLineEnd(from index: Int) -> Int {
		let str    = self.string
		var result = index
		var idx    = str.index(str.startIndex, offsetBy: index)
		let end    = str.endIndex
		while idx < end {
			if str[idx].isNewline {
				break
			}
			idx = str.index(after: idx)
			result += 1
		}
		return result
	}

	func moveCursorBackward(from index: Int) -> Int? {
		let str   = self.string
		let idx   = str.index(str.startIndex, offsetBy: index)
		let start = str.startIndex
		if start < idx {
			let prev = str.index(before: idx)
			if !str[prev].isNewline {
				return index - 1
			}
		}
		return nil
	}

	func moveCursorBackward(from index: Int, number num: Int) -> Int {
		let str    = self.string
		var result = index
		var idx    = str.index(str.startIndex, offsetBy: index)
		let start  = str.startIndex
		for _ in 0..<num {
			if start < idx {
				let prev = str.index(before: idx)
				if str[prev].isNewline {
					break
				}
				result -= 1
				idx     = prev
			} else {
				break
			}
		}
		return result
	}

	func moveCursorToLineStart(from index: Int) -> Int {
		let str    = self.string
		var result = index
		var idx    = str.index(str.startIndex, offsetBy: index)
		let start  = str.startIndex
		while start < idx {
			let prev = str.index(before: idx)
			if str[prev].isNewline {
				break
			}
			result -= 1
			idx     = prev
		}
		return result
	}

	func moveCursorToPreviousLineEnd(from index: Int) -> Int? {
		/* Move to line head */
		let head = moveCursorToLineStart(from: index)
		/* Skip previous newline */
		if 0 < head {
			return head - 1
		} else {
			return nil
		}
	}

	func moveCursorToNextLineStart(from index: Int) -> Int? {
		/* Move to line end */
		let tail = moveCursorToLineEnd(from: index)
		/* Skip next newline */
		if tail < self.string.count {
			return tail + 1
		} else {
			return nil
		}
	}

	func moveCursorToPreviousLineStart(from index: Int, number num: Int) -> Int {
		var curidx = index
		for _ in 0..<num {
			if let newidx = moveCursorToPreviousLineEnd(from: curidx) {
				curidx = newidx
			} else {
				break
			}
		}
		return moveCursorToLineStart(from: curidx)
	}

	func moveCursorToNextLineStart(from index: Int, number num: Int) -> (Int, Bool) {
		var curidx    = index
		var donewline = false
		for _ in 0..<num {
			if let newidx = moveCursorToNextLineStart(from: curidx) {
				curidx = newidx
			} else {
				donewline = true
				break
			}
		}
		return (curidx, donewline)
	}

	func moveCursorUpOrDown(from idx: Int, doUp doup: Bool, number num: Int) -> Int {
		var ptr   = idx
		/* Keep holizontal offset */
		let orgoff = self.distanceFromLineStart(to: ptr)
		/* up/down num lines */
		if doup {
			for _ in 0..<num {
				if let newptr = moveCursorToPreviousLineEnd(from: ptr) {
					ptr = newptr
				} else {
					break
				}
			}
		} else {
			for _ in 0..<num {
				if let newptr = moveCursorToNextLineStart(from: ptr) {
					ptr = newptr
				} else {
					break
				}
			}
		}
		/* get current offset */
		let curoff = self.distanceFromLineStart(to: ptr)
		/* adjust holizontal offset */
		if curoff < orgoff {
			ptr = moveCursorForward(from: ptr, number: orgoff - curoff)
		} else if orgoff < curoff {
			ptr = moveCursorBackward(from: ptr, number: curoff - orgoff)
		}
		return ptr
	}

	func moveCursorTo(from index: Int, x xpos: Int) -> Int {
		var result: Int
		let hoff = self.distanceFromLineStart(to: index)
		if hoff < xpos {
			result = moveCursorForward(from: index, number: xpos - hoff)
		} else if hoff > xpos {
			result = moveCursorBackward(from: index, number: hoff - xpos)
		} else {
			result = index
		}
		return result
	}

	func moveCursorTo(x xpos: Int, y ypos: Int) -> Int {
		var newidx: Int = 0
		if ypos > 0 {
			newidx = moveCursorUpOrDown(from: newidx, doUp: false, number: ypos)
		}
		if xpos > 0 {
			newidx = moveCursorForward(from: newidx, number: xpos)
		}
		return newidx
	}
}

public extension NSMutableAttributedString
{
	func write(string str: String, at index: Int, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) -> Int {
		let astr = NSAttributedString(string: str, font: fnt, terminalInfo: terminfo)
		self.beginEditing()
		/* Get length to replace */
		let restlen  = self.distanceToLineEnd(from: index)
		let replen   = min(restlen, str.count)
		if replen > 0 {
			self.delete(from: index, length: replen)
		}
		/* Insert new string */
		self.insert(astr, at: index)
		self.endEditing()
		return index + str.count
	}

	func insert(string str: String, at index: Int, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) -> Int {
		let astr = NSAttributedString(string: str, font: fnt, terminalInfo: terminfo)
		self.beginEditing()
		self.insert(astr, at: index)
		self.endEditing()
		return index + str.count
	}

	func append(string str: String, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) -> Int {
		let astr = NSAttributedString(string: str, font: fnt, terminalInfo: terminfo)
		self.beginEditing()
		self.append(astr)
		self.endEditing()
		return self.string.count
	}

	func clear(font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) {
		self.beginEditing()
		/* Clear normally */
		let range = NSRange(location: 0, length: self.string.count)
		self.deleteCharacters(in: range)
		if terminfo.isAlternative {
			/* Fill by spaces */
			let space    = String(repeating: " ", count: terminfo.width)
			let aspace   = NSAttributedString(string: space, font: fnt, terminalInfo: terminfo)
			let anewline = NSAttributedString(string: "\n", font: fnt, terminalInfo: terminfo)
			for i in 0..<terminfo.height {
				if i > 0 { self.append(anewline) }
				self.append(aspace)
			}
		}
		self.endEditing()
	}

	func deleteForwardCharacters(from index: Int, number num: Int) -> Int {
		let lineend  = self.moveCursorForward(from: index, number: num)
		delete(from: index, to: lineend)
		return index
	}

	func deleteForwardAllCharacters(from index: Int) -> Int {
		let lineend  = self.moveCursorToLineEnd(from: index)
		delete(from: index, to: lineend)
		return index
	}

	func deleteBackwardCharacters(from index: Int, number num: Int) -> Int {
		let linestart = self.moveCursorBackward(from: index, number: num)
		delete(from: linestart, to: index)
		return linestart
	}

	func deleteBackwardAllCharacters(from index: Int) -> Int {
		let linestart = self.moveCursorToLineStart(from: index)
		delete(from: linestart, to: index)
		return linestart
	}

	func deleteEntireLine(from index: Int) -> Int {
		let linestart = self.moveCursorToLineStart(from: index)
		var lineend   = self.moveCursorToLineEnd(from: index)
		if lineend < self.string.count - 1 {
			if let c = self.character(at: lineend) {
				if c.isNewline {
					lineend += 1
				}
			}
		}
		delete(from: linestart, to: lineend)
		return linestart
	}

	func delete(from fromidx: Int, to toidx: Int) {
		let len = toidx - fromidx
		if len > 0 {
			let range = NSRange(location: fromidx, length: len)
			self.beginEditing()
			self.deleteCharacters(in: range)
			self.endEditing()
		}
	}

	func delete(from fromidx: Int, length len: Int) {
		if len > 0 {
			let range = NSRange(location: fromidx, length: len)
			self.beginEditing()
			self.deleteCharacters(in: range)
			self.endEditing()
		}
	}

	func changeOverallFont(font newfont: CNFont){
		self.beginEditing()
		let entire = NSMakeRange(0, self.string.count)
		self.enumerateAttribute(.font, in: entire, options: [], using: {
			(anyobj, range, unsage) -> Void in
			removeAttribute(.font, range: entire)
			addAttribute(.font, value: newfont, range: entire)
		})
		self.endEditing()
	}

	func resize(width newwidth: Int, height newheight: Int, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) {
		var ptr	  = 0
		var pos   = 0
		var lines = 0
		while ptr < self.string.count {
			let len = self.distanceToLineEnd(from: ptr)
			if len > newwidth {
				/* Cut line */
				ptr = deleteBackwardCharacters(from: ptr, number: len - newwidth)
			} else if len < newwidth {
				/* Fill line */
				let space = String(repeating: "_", count: newwidth - len)
				let astr  = NSAttributedString(string: space, font: fnt, terminalInfo: terminfo)
				self.beginEditing()
					self.insert(astr, at: pos + len)
				self.endEditing()
			}
			if let next = moveCursorToNextLineStart(from: ptr) {
				ptr   =  next
				pos   += newwidth + 1 // +1 for new line
			} else {
				ptr   =  self.string.count
				pos   += len
			}
			lines += 1

			if lines > newheight {
				/* Remove rest strings */
				if ptr < self.string.count {
					let head  = ptr
					let total = self.string.count
					let range = NSRange(location: head, length: total - head)
					self.beginEditing()
						self.deleteCharacters(in: range)
					self.endEditing()
				}
			}
		}
		if lines < newheight {
			let space    = String(repeating: "_", count: newwidth - 1)
			let aspace   = NSAttributedString(string: space, font: fnt, terminalInfo: terminfo)
			let anewline = NSAttributedString(string: "\n", font: fnt, terminalInfo: terminfo)
			if lines == 0 {
				self.beginEditing()
					self.append(aspace)
				self.endEditing()
				lines = 1
			}
			for _ in lines..<newheight {
				self.beginEditing()
					self.append(anewline)
					self.append(aspace)
				self.endEditing()
			}
		}
	}

	func changeOverallTextColor(targetColor curcol: CNColor, newColor newcol: CNColor){
		let entire = NSMakeRange(0, self.string.count)
		self.beginEditing()
		self.enumerateAttribute(.foregroundColor, in: entire, options: [], using: {
			(anyobj, range, unsage) -> Void in
			/* Replace current foreground color attribute by new color */
			if let colobj = anyobj as? CNColor {
				if colobj.isEqual(curcol) {
					removeAttribute(.foregroundColor, range: range)
					addAttribute(.foregroundColor, value: newcol, range: range)
				}
			}
		})
		self.endEditing()
	}

	func changeOverallBackgroundColor(targetColor curcol: CNColor, newColor newcol: CNColor){
		let entire = NSMakeRange(0, self.string.count)
		self.beginEditing()
		self.enumerateAttribute(.backgroundColor, in: entire, options: [], using: {
			(anyobj, range, unsage) -> Void in
			/* Replace current background color attribute by new color */
			if let colobj = anyobj as? CNColor {
				if colobj.isEqual(curcol) {
					removeAttribute(.backgroundColor, range: range)
					addAttribute(.backgroundColor, value: newcol, range: range)
				}
			}
		})
		self.endEditing()
	}
}
