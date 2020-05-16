/**
 * @file	CNAttributedString.swift
 * @brief	Extend NSAttributedString class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public struct CNStringAttribute {
	public var 	width	: Int
	public var	height	: Int

	public var	foregroundColor	: CNColor
	public var	backgroundColor	: CNColor

	public var	doBold		: Bool
	public var	doItalic	: Bool
	public var	doUnderLine	: Bool
	public var	doReverse	: Bool

	public var	reservedIndex:	Int
	public var	reservedText:	NSAttributedString

	public init(width widthval: Int, height heightval: Int) {
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

	public mutating func reset() {
		foregroundColor		= CNColor.black
		backgroundColor		= CNColor.white
		doBold			= false
		doItalic		= false
		doUnderLine		= false
		doReverse		= false
	}
}

public extension String
{
	func intToIndex(_ val: Int) -> String.Index {
		return self.index(self.startIndex, offsetBy: val)
	}

	func lineCount(from start: String.Index, to end: String.Index) -> Int {
		var idx     = start
		var linenum = 0
		while idx < end {
			if self[idx].isNewline {
				linenum += 1
			}
			idx = self.index(after: idx)
		}
		return linenum
	}

	func moveCursorForward(from index: String.Index) -> String.Index? {
		let end = self.endIndex
		if index < end {
			if !self[index].isNewline {
				return self.index(after: index)
			}
		}
		return nil
	}

	func moveCursorBackward(from index: String.Index) -> String.Index? {
		let start = self.startIndex
		if start < index {
			let prev = self.index(before: index)
			if !self[prev].isNewline {
				return prev
			}
		}
		return nil
	}

	func holizontalOffset(from index: String.Index) -> Int {
		var result = 0
		var ptr    = index
		while true {
			if let prev = moveCursorBackward(from: ptr) {
				ptr = prev
				result += 1
			} else {
				break
			}
		}
		return result
	}

	func holizontalReverseOffset(from index: String.Index) -> Int {
		var result = 0
		var ptr    = index
		while true {
			if let next = moveCursorForward(from: ptr) {
				ptr = next
				result += 1
			} else {
				break
			}
		}
		return result
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

	private func moveCursorToPreviousLineEnd(from index: String.Index) -> String.Index? {
		/* Move to line head */
		let head = moveCursorToLineStart(from: index)
		/* Skip previous newline */
		if self.startIndex < head {
			return self.index(before: head)
		} else {
			return nil
		}
	}

	private func moveCursorToNextLineStart(from index: String.Index) -> String.Index? {
		/* Move to line end */
		let tail = moveCursorToLineEnd(from: index)
		/* Move to next newline */
		if tail < self.endIndex {
			return self.index(after: tail)
		} else {
			return nil
		}
	}

	func moveCursorUpOrDown(from idx: String.Index, doUp doup: Bool, number num: Int) -> String.Index {
		var ptr   = idx
		/* Keep holizontal offset */
		let orgoff = holizontalOffset(from: ptr)
		/* up/down num lines */
		if doup {
			for _ in 0..<num {
				if let prev = moveCursorToPreviousLineEnd(from: ptr) {
					ptr = prev
				}
			}
		} else {
			for _ in 0..<num {
				if let next = moveCursorToNextLineStart(from: ptr) {
					ptr = next
				}
			}
		}
		/* get current offset */
		let curoff = holizontalOffset(from: ptr)
		/* adjust holizontal offset */
		if curoff < orgoff {
			ptr = moveCursorForward(from: ptr, number: orgoff - curoff)
		} else if orgoff < curoff {
			ptr = moveCursorBackward(from: ptr, number: curoff - orgoff)
		}
		return ptr
	}

	func moveCursorTo(from index: String.Index, x xpos: Int) -> String.Index {
		let hoff = holizontalOffset(from: index)
		if hoff < xpos {
			return moveCursorForward(from: index, number: xpos - hoff)
		} else if hoff > xpos {
			return moveCursorBackward(from: index, number: hoff - xpos)
		} else {
			return index
		}
	}

	func moveCursorTo(base baseidx: String.Index, x xpos: Int, y ypos: Int) -> String.Index {
		let newidx = moveCursorUpOrDown(from: baseidx, doUp: false, number: ypos)
		return moveCursorTo(from: newidx, x: xpos)
	}
}

public extension NSAttributedString
{
	convenience init(string str: String, font fnt: CNFont, attributes attr: CNStringAttribute) {
		let newfont = CNFontManager.shared.convert(font: fnt, attribute: attr)

		let fcol = attr.doReverse ? attr.backgroundColor : attr.foregroundColor
		let bcol = attr.doReverse ? attr.foregroundColor : attr.backgroundColor
		var attrs: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.foregroundColor: fcol,
			NSAttributedString.Key.backgroundColor:	bcol,
			NSAttributedString.Key.font:		newfont
		]
		if attr.doUnderLine {
			attrs[NSAttributedString.Key.underlineStyle] = NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue)
		}
		self.init(string: str, attributes: attrs)
	}
}

public extension NSMutableAttributedString
{
	func write(string str: NSAttributedString, at index: String.Index) -> String.Index {
		let restlen  = self.string.holizontalReverseOffset(from: index)
		let replen   = min(str.length, restlen)
		let writepos = self.string.distance(from: self.string.startIndex, to: index)
		let range    = NSRange(location: writepos, length: replen)
		self.replaceCharacters(in: range, with: str)
		return self.string.moveCursorForward(from: index, number: str.length)
	}

	func insert(string str: NSAttributedString, at index: String.Index) -> String.Index {
		let pos = self.string.distance(from: self.string.startIndex, to: index)
		self.insert(str, at: pos)
		return self.string.index(index, offsetBy: str.length)
	}

	func clear() {
		let range = NSRange(location: 0, length: self.length)
		self.deleteCharacters(in: range)
	}

	func deleteForwardCharacters(from index: String.Index, number num: Int) -> String.Index {
		let lineend  = self.string.moveCursorForward(from: index, number: num)
		let linepos  = self.string.distance(from: self.string.startIndex, to: index)
		let dellen   = self.string.distance(from: index, to: lineend)
		let delrange = NSRange(location: linepos, length: dellen)
		self.deleteCharacters(in: delrange)
		return index
	}

	func deleteForwardAllCharacters(from index: String.Index) -> String.Index {
		let lineend  = self.string.moveCursorToLineEnd(from: index)
		let linepos  = self.string.distance(from: self.string.startIndex, to: index)
		let dellen   = self.string.distance(from: index, to: lineend)
		let delrange = NSRange(location: linepos, length: dellen)
		self.deleteCharacters(in: delrange)
		return index
	}

	func deleteBackwardCharacters(from index: String.Index, number num: Int) -> String.Index {
		let linestart = self.string.moveCursorBackward(from: index, number: num)
		let linepos   = self.string.distance(from: self.string.startIndex, to: linestart)
		let dellen    = self.string.distance(from: linestart, to: index)
		let delrange = NSRange(location: linepos, length: dellen)
		self.deleteCharacters(in: delrange)
		return linestart
	}

	func deleteBackwardAllCharacters(from index: String.Index) -> String.Index {
		let linestart = self.string.moveCursorToLineStart(from: index)
		let linepos   = self.string.distance(from: self.string.startIndex, to: linestart)
		let dellen    = self.string.distance(from: linestart, to: index)
		let delrange = NSRange(location: linepos, length: dellen)
		self.deleteCharacters(in: delrange)
		return linestart
	}

	func deleteEntireLine(from index: String.Index) -> String.Index {
		let linestart = self.string.moveCursorToLineStart(from: index)
		var lineend   = self.string.moveCursorToLineEnd(from: index)
		if lineend < self.string.endIndex {
			let next = self.string.index(after: lineend)
			if self.string[next].isNewline {
				lineend = next
			}
		}
		let linepos   = self.string.distance(from: self.string.startIndex, to: linestart)
		let dellen    = self.string.distance(from: linestart, to: lineend)
		let delrange = NSRange(location: linepos, length: dellen)
		self.deleteCharacters(in: delrange)
		return linestart
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

	func insertPadding(width widthval: Int, height heightval: Int, attribute attr: CNStringAttribute) {
		var ptr	       = self.string.startIndex
		var lines      = 0
		var hasnewline = false
		while ptr < self.string.endIndex {
			/* Characters count until newline */
			let len = self.string.holizontalReverseOffset(from: ptr)
			if len < widthval {
				/* Insert spaces until newline */
				let diff  = widthval - len
				ptr = self.string.index(ptr, offsetBy: len)
				let space = String(repeating: " ", count: diff)
				self.insert(NSAttributedString(string: space), at: self.string.distance(from: self.string.startIndex, to: ptr))
				ptr = self.string.index(ptr, offsetBy: diff)
			} else {
				ptr = self.string.index(ptr, offsetBy: len)
			}
			/* Skip newline */
			hasnewline = false
			if ptr < self.string.endIndex {
				if self.string[ptr].isNewline {
					ptr = self.string.index(after: ptr)
					/* Count newline */
					lines      += 1
					hasnewline = true
				}
			}
		}
		/* Append last newline */
		if self.string.startIndex < ptr && !hasnewline {
			self.append(NSAttributedString(string: "\n"))
			lines += 1
		}

		/* Appendlines */
		if heightval > lines {
			let diff   = heightval - lines
			var spaces = ""
			let line   = String(repeating: " ", count: widthval)
			var is1st  = true
			for  _ in 0..<diff {
				if is1st {
					is1st = !is1st
				} else {
					spaces += "\n"
				}
				spaces += line
			}
			self.append(NSAttributedString(string: spaces))
		}
	}
}
