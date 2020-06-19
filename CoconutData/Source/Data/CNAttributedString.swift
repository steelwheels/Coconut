/**
 * @file	CNAttributedString.swift
 * @brief	Extend NSAttributedString class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

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

	func lineCount(from start: String.Index, to end: String.Index) -> Int {
		var idx     = start
		var linenum = 0
		let str     = self.string
		while idx < end {
			if str[idx].isNewline {
				linenum += 1
			}
			idx = str.index(after: idx)
		}
		return linenum
	}

	func distanceFromLineStart(to index: String.Index) -> Int {
		var result = 0
		var ptr    = index
		let str    = self.string
		let start  = str.startIndex
		while start < ptr {
			let prev = str.index(before: ptr)
			if str[prev].isNewline {
				break
			}
			ptr    = prev
			result += 1
		}
		return result
	}

	func distanceToLineEnd(from index: String.Index) -> Int {
		var result = 0
		var ptr    = index
		let str    = self.string
		let end    = str.endIndex
		while ptr < end {
			if str[ptr].isNewline {
				break
			}
			ptr = str.index(after: ptr)
			result += 1
		}
		return result
	}
}

public extension NSMutableAttributedString
{
	func moveCursorForward(from index: String.Index) -> String.Index? {
		let str = self.string
		let end = str.endIndex
		if index < end {
			if !str[index].isNewline {
				return str.index(after: index)
			}
		}
		return nil
	}

	func moveCursorBackward(from index: String.Index) -> String.Index? {
		let str   = self.string
		let start = str.startIndex
		if start < index {
			let prev = str.index(before: index)
			if !str[prev].isNewline {
				return prev
			}
		}
		return nil
	}

	func moveCursorBackward(from index: String.Index, number num: Int) -> String.Index {
		var ptr = index
		for _ in 0..<num {
			if let back = moveCursorBackward(from: ptr) {
				ptr = back
			} else {
				break
			}
		}
		return ptr
	}

	func moveCursorToLineStart(from index: String.Index) -> String.Index {
		var ptr = index
		while true {
			if let back = moveCursorBackward(from: ptr) {
				ptr = back
			} else {
				break
			}
		}
		return ptr
	}

	func moveCursorForward(from index: String.Index, number num: Int) -> String.Index {
		var ptr = index
		for _ in 0..<num {
			if let next = moveCursorForward(from: ptr) {
				ptr = next
			} else {
				break
			}
		}
		return ptr
	}

	func moveCursorToLineEnd(from index: String.Index) -> String.Index {
		var ptr = index
		while true {
			if let next = moveCursorForward(from: ptr) {
				ptr = next
			} else {
				break
			}
		}
		return ptr
	}

	func moveCursorToPreviousLineEnd(from index: String.Index) -> String.Index? {
		/* Move to line head */
		let head    = moveCursorToLineStart(from: index)
		/* Skip previous newline */
		let str = self.string
		if str.startIndex < head {
			let newidx = str.index(before: head)
			return newidx
		} else {
			return nil
		}
	}

	func moveCursorToNextLineStart(from index: String.Index) -> String.Index? {
		/* Move to line end */
		let tail    = moveCursorToLineEnd(from: index)
		/* Skip next newline */
		let str = self.string
		if tail < str.endIndex {
			let newidx = str.index(after: tail)
			return newidx
		} else {
			return nil
		}
	}

	func moveCursorUpOrDown(from idx: String.Index, doUp doup: Bool, number num: Int) -> String.Index {
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

	func moveCursorTo(from index: String.Index, x xpos: Int) -> String.Index {
		let hoff = self.distanceFromLineStart(to: index)
		if hoff < xpos {
			return moveCursorForward(from: index, number: xpos - hoff)
		} else if hoff > xpos {
			return moveCursorBackward(from: index, number: hoff - xpos)
		} else {
			return index
		}
	}

	func moveCursorTo(base baseidx: String.Index, x xpos: Int, y ypos: Int) -> String.Index {
		let newidx  = moveCursorUpOrDown(from: baseidx, doUp: false, number: ypos)
		return moveCursorTo(from: newidx, x: xpos)
	}

	func write(string str: NSAttributedString, at index: String.Index) -> String.Index {
		self.beginEditing()
		let restlen  = self.distanceToLineEnd(from: index)
		let replen   = min(str.length, restlen)
		let writepos = self.string.distance(from: self.string.startIndex, to: index)
		let range    = NSRange(location: writepos, length: replen)
		self.replaceCharacters(in: range, with: str)
		self.endEditing()
		return self.moveCursorForward(from: index, number: str.length)
	}

	func insert(string str: String, at index: String.Index, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) -> String.Index {
		let astr = NSAttributedString(string: str, font: fnt, terminalInfo: terminfo)
		self.beginEditing()
		let pos = self.string.distance(from: self.string.startIndex, to: index)
		self.insert(astr, at: pos)
		self.endEditing()
		return self.string.index(index, offsetBy: astr.length)
	}

	func append(string str: String, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) -> String.Index {
		let astr = NSAttributedString(string: str, font: fnt, terminalInfo: terminfo)
		self.beginEditing()
		self.append(astr)
		self.endEditing()
		return self.string.endIndex
	}

	func scrollUp(lines lns: Int, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) -> String.Index {
		if lns > 0 {
			let newlines = String(repeating: "\n", count: lns)
			return self.append(string: newlines, font: fnt, terminalInfo: terminfo)
		} else {
			return self.string.endIndex
		}
	}

	func scrollDown(lines lns: Int, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) -> String.Index {
		if lns > 0 {
			var idx = self.string.endIndex
			for _ in 0..<lns {
				if let prev = self.moveCursorToPreviousLineEnd(from: idx) {
					idx = prev
				} else {
					break
				}
			}
			self.delete(from: idx, to: self.string.endIndex)
		}
		return self.string.endIndex
	}

	func clear(font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) {
		self.beginEditing()
		/* Clear normally */
		let range = NSRange(location: 0, length: self.length)
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

	func deleteForwardCharacters(from index: String.Index, number num: Int) -> String.Index {
		let lineend  = self.moveCursorForward(from: index, number: num)
		delete(from: index, to: lineend)
		return index
	}

	func deleteForwardAllCharacters(from index: String.Index) -> String.Index {
		let lineend  = self.moveCursorToLineEnd(from: index)
		delete(from: index, to: lineend)
		return index
	}

	func deleteBackwardCharacters(from index: String.Index, number num: Int) -> String.Index {
		let linestart = self.moveCursorBackward(from: index, number: num)
		delete(from: linestart, to: index)
		return linestart
	}

	func deleteBackwardAllCharacters(from index: String.Index) -> String.Index {
		let linestart = self.moveCursorToLineStart(from: index)
		delete(from: linestart, to: index)
		return linestart
	}

	func deleteEntireLine(from index: String.Index) -> String.Index {
		let linestart = self.moveCursorToLineStart(from: index)
		var lineend   = self.moveCursorToLineEnd(from: index)
		if lineend < self.string.endIndex {
			let next = self.string.index(after: lineend)
			if self.string[next].isNewline {
				lineend = next
			}
		}
		delete(from: linestart, to: lineend)
		return linestart
	}

	func delete(from fromidx: String.Index, to toidx: String.Index) {
		let pos = self.string.distance(from: self.string.startIndex, to: fromidx)
		let len = self.string.distance(from: fromidx, to: toidx)
		if len > 0 {
			let range = NSRange(location: pos, length: len)
			self.beginEditing()
			self.deleteCharacters(in: range)
			self.endEditing()
		}
	}

	func changeOverallFont(font newfont: CNFont){
		self.beginEditing()
		let entire = NSMakeRange(0, self.length)
		self.enumerateAttribute(.font, in: entire, options: [], using: {
			(anyobj, range, unsage) -> Void in
			removeAttribute(.font, range: entire)
			addAttribute(.font, value: newfont, range: entire)
		})
		self.endEditing()
	}

	func resize(width newwidth: Int, height newheight: Int, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) {
		var ptr	  = self.string.startIndex
		var pos   = 0
		var lines = 0
		while ptr < self.string.endIndex {
			let len = self.distanceToLineEnd(from: ptr)
			if len > newwidth {
				/* Cut line */
				ptr = deleteBackwardCharacters(from: ptr, number: len - newwidth)
			} else if len < newwidth {
				/* Fill line */
				let space = String(repeating: " ", count: newwidth - len)
				let astr  = NSAttributedString(string: space, font: fnt, terminalInfo: terminfo)
				self.insert(astr, at: pos + len)
			}
			if let next = moveCursorToNextLineStart(from: ptr) {
				ptr   =  next
				pos   += newwidth + 1 // +1 for new line
			} else {
				ptr   =  self.string.endIndex
				pos   += len
			}
			lines += 1

			if lines > newheight {
				/* Remove rest strings */
				if ptr < self.string.endIndex {
					let head  = self.string.distance(from: self.string.startIndex, to: ptr)
					let total = self.length
					let range = NSRange(location: head, length: total - head)
					self.deleteCharacters(in: range)
					return /* Exit this function */
				}
			}
		}
		if lines < newheight {
			let space    = String(repeating: " ", count: newwidth)
			let aspace   = NSAttributedString(string: space, font: fnt, terminalInfo: terminfo)
			let anewline = NSAttributedString(string: "\n", font: fnt, terminalInfo: terminfo)
			if lines == 0 {
				self.append(aspace)
				lines = 1
			}
			for _ in lines..<newheight {
				self.append(anewline)
				self.append(aspace)
			}
		}
	}

	func changeOverallTextColor(targetColor curcol: CNColor, newColor newcol: CNColor){
		let entire = NSMakeRange(0, self.length)
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
		let entire = NSMakeRange(0, self.length)
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
