/**
 * @file	CNAttributedString.swift
 * @brief	Extend NSAttributedString class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public extension NSAttributedString {
	func character(at index: Int) -> Character? {
		if 0<=index && index<self.length {
			let range  = NSRange(location: index, length: 1)
			let substr = self.attributedSubstring(from: range)
			return substr.string.first 
		}
		return nil
	}

	/**
	 * @return
	 *    Offset from "index". Positive value
	 *    The position is placed *before* c
	 */
	func searchForward(character c: Character, from index: Int) -> Int? {
		var i   = index
		let len = self.length
		while i<len {
			if let csrc = character(at: i) {
				if c == csrc {
					return i - index
				} else {
					i += 1
				}
			} else {
				break
			}
		}
		return nil
	}

	/*
	 * @return
	 *    Offset from "index". Positive value
	 *    The position is placed *after* c
	 */
	func searchBackward(character c: Character, from index: Int) -> Int? {
		var i = index
		while 0 < i {
			if let csrc = character(at: i-1) {
				if c == csrc {
					return index - i
				} else {
					i -= 1
				}
			} else {
				break
			}
		}
		return nil
	}

	func moveCursorForward(from index: Int, number num: Int) -> Int {
		if let tonl = self.searchForward(character: "\n", from: index) {
			return min(index + num, index + tonl)
		} else {
			return min(index + num, self.length)
		}
	}

	func moveCursorToLineEnd(from index: Int) -> Int {
		if let tonl = self.searchForward(character: "\n", from: index) {
			return index + tonl
		} else {
			return self.length
		}
	}

	func moveCursorBackward(from index: Int, number num: Int) -> Int {
		if let tonl = self.searchBackward(character: "\n", from: index) {
			let off = min(num, tonl)
			return max(0, index - off)
		} else {
			return max(0, index - num)
		}
	}

	private func moveToPreviousLine(from index: Int) -> Int? {
		if let hoff = self.searchBackward(character: "\n", from: index) {
			let nextidx = index - hoff - 1 // last for newline
			if nextidx >= 0 {
				return nextidx
			}
		}
		return nil
	}

	func backspace(from index: Int) -> Int {
		if 1 <= index {
			return index - 1
		} else {
			return 0
		}
	}

	func moveCursorUp(from index: Int, number num: Int, moveToHead head: Bool) -> Int {
		/* Get current holizontal offset */
		let hoff: Int
		if let off = self.searchBackward(character: "\n", from: index) {
			hoff = off
		} else {
			hoff = index
		}
		/* Move to next line */
		var curidx = index
		for _ in 0..<num {
			if let newidx = moveToPreviousLine(from: curidx) {
				curidx = newidx
			} else {
				break
			}
		}
		/* Move to head */
		if let off = self.searchBackward(character: "\n", from: curidx) {
			curidx -= off
		} else {
			curidx = 0
		}
		/* Adjust holizontal offset */
		if !head {
			curidx = self.moveCursorForward(from: curidx, number: hoff)
		}
		return curidx
	}

	private func moveToNextLine(from index: Int) -> Int? {
		if let hoff = self.searchForward(character: "\n", from: index) {
			let nextidx = index + hoff + 1 // last for newline
			if nextidx < self.length {
				return nextidx
			}
		}
		return nil
	}

	func moveCursorDown(from index: Int, number num: Int, moveToHead head: Bool) -> Int {
		/* Get current holizontal offset */
		let hoff: Int
		if let off = self.searchBackward(character: "\n", from: index) {
			hoff = off
		} else {
			hoff = index
		}
		/* Move to next line */
		var curidx = index
		for _ in 0..<num {
			if let newidx = moveToNextLine(from: curidx) {
				curidx = newidx
			} else {
				break
			}
		}
		/* Adjust holizontal offset */
		if !head {
			curidx = self.moveCursorForward(from: curidx, number: hoff)
		}
		return curidx
	}

	func moveCursorTo(from idx: Int , x xpos: Int?, y ypos: Int?) -> Int {
		var newidx = idx
		if let x = xpos {
			/* Get current offset from list head */
			let curoff: Int
			if let h = self.searchBackward(character: "\n", from: newidx) {
				curoff = h
			} else {
				curoff = 0
			}
			/* Get offset from given x */
			let diff = x - curoff
			if diff > 0 {
				newidx = self.moveCursorForward(from: newidx,  number:  diff)
			} else {
				newidx = self.moveCursorBackward(from: newidx, number: -diff)
			}
		}
		if let y = ypos {
			NSLog("Ignored y: \(y)")
		}
		return newidx
	}
}

public extension NSMutableAttributedString
{
	func write(string str: NSAttributedString, at index: Int) -> Int {
		/* Get range to replace by string */
		let replen: Int
		if let tonl = self.searchForward(character: "\n", from: index) {
			replen = min(tonl, str.length)
		} else {
			replen = min(self.length - index, str.length)
		}
		let range = NSRange(location: index, length: replen)
		self.replaceCharacters(in: range, with: str)
		return index + str.length
	}

	func clear() {
		let range = NSRange(location: 0, length: self.length)
		self.deleteCharacters(in: range)
	}

	func deleteForwardCharacters(at index: Int, number num: Int) -> Int {
		if let tonl = self.searchForward(character: "\n", from: index) {
			let delnum   = min(num, tonl)
			let delrange = NSRange(location: index, length: delnum)
			self.deleteCharacters(in: delrange)
		} else {
			let delnum   = min(num, self.length - index)
			let delrange = NSRange(location: index, length: delnum)
			self.deleteCharacters(in: delrange)
		}
		return index
	}

	func deleteForwardLineCharacters(at index: Int) -> Int {
		if let len = self.searchForward(character: "\n", from: index) {
			return deleteForwardCharacters(at: index, number: len)
		} else {
			return deleteBackwardAllCharacters(at: index)
		}
	}

	func deleteForwardAllCharacters(at index: Int) -> Int {
		let delta = self.length - index
		if delta > 0 {
			let delrange = NSRange(location: index, length: delta)
			self.deleteCharacters(in: delrange)
		}
		return index
	}

	func deleteBackwardCharacters(at index: Int, number num: Int) -> Int {
		let result: Int
		if let tonl = self.searchBackward(character: "\n", from: index) {
			let delnum   = min(num, tonl)
			let delrange = NSRange(location: index-delnum, length: delnum)
			self.deleteCharacters(in: delrange)
			result = index - delnum
		} else {
			let delnum   = min(num, index)
			let delrange = NSRange(location: index-delnum, length: delnum)
			self.deleteCharacters(in: delrange)
			result = index - delnum
		}
		return result
	}

	func deleteBackwardLineCharacters(at index: Int) -> Int {
		if let len = self.searchBackward(character: "\n", from: index) {
			return deleteBackwardCharacters(at: index, number: len)
		} else {
			return deleteBackwardAllCharacters(at: index)
		}
	}

	func deleteBackwardAllCharacters(at index: Int) -> Int {
		if index > 0 {
			let delrange = NSRange(location: 0, length: index)
			self.deleteCharacters(in: delrange)
		}
		return 0
	}

	func deleteEntireLine(at index: Int) -> Int {
		var start: Int
		if let off = searchBackward(character: "\n", from: index) {
			start = index - off
		} else {
			start = 0
		}
		var end: Int
		if let off = searchForward(character: "\n", from: index) {
			end = index + off
		} else {
			end = self.length
		}
		let delrange = NSRange(location: start, length: end - start + 1)
		self.deleteCharacters(in: delrange)
		return start
	}
}
