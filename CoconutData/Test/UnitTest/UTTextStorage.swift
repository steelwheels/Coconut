/**
 * @file	UTTextStorage.swift
 * @brief	Test function for the extension of NSAttributedString class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testTextStorage(console cons: CNConsole) -> Bool
{
	let str = NSMutableAttributedString(string:
		  "abcdefghij\n"
		+ "0123456789\n"
		+ "abcdefghij"
	)
	let textattr = NSTextStorage.TextAttribute()

	var idx = 15

	cons.print(string: "- Initial state\n")
	dump(index: idx, string: str, console: cons)

	let ecodes: Array<CNEscapeCode> = [
		.string("Hello"),
		.string("Good-morning!!"),
		.cursorBackward(14),		// len("Good-morning!!")
		//.newline,
		//.tab,
		.backspace,
		.newline,
		.backspace,
		.delete,
		.cursorUp(1),
		.cursorDown(1),
		.cursorForward(1),
		.cursorBackward(1),
		.cursorForward(20),
		.cursorBackward(20),
		.cursorForward(5),
		.cursorNextLine(2),
		.cursorPreviousLine(2),
		.cursorHolizontalAbsolute(4),
		.cursorHolizontalAbsolute(2),
		.eraceFromCursorToEnd,
		.eraceFromCursorToBegin,
		.string(str.string),		// set again
		.cursorBackward(5),
		.eraceEntireBuffer,
		.string(str.string),		// set again
		.cursorBackward(5),
		.cursorUp(1),
		.eraceFromCursorToRight,
		.eraceFromCursorToLeft,
		.string("inserted"),
		.cursorBackward(5),
		.eraceEntireLine,
		.foregroundColor(.Red),
		.backgroundColor(.Blue),
		.string("COLOR"),
		.setNormalAttributes
	]
	for ecode in ecodes {
		idx = execute(string: str, index: idx, escapeCode: ecode, attribute: textattr, console: cons)
	}

	return true
}

private func execute(string str: NSMutableAttributedString, index idx: Int, escapeCode ecode: CNEscapeCode, attribute attr: NSTextStorage.TextAttribute, console cons: CNConsole) -> Int
{
	if let result = str.execute(index: idx, attribute: attr, escapeCode: ecode) {
		cons.print(string: "- Execute:\(ecode.description())\n")
		dump(index: result, string: str, console: cons)
		return result
	} else {
		cons.print(string: "- Execute:\(ecode.description())\n")
		return idx
	}
}

private func dump(index idx: Int, string str: NSAttributedString, console cons: CNConsole)
{
	let	len = str.length
	for i in 0..<len {
		if i == idx {
			cons.print(string: "*")
		} else {
			cons.print(string: "_")

		}
		if let c = str.character(at: i) {
			cons.print(string: "\(c)")
		} else {
			cons.print(string: "?")
		}
	}
	if idx == len {
		cons.print(string: "*")
	}
	cons.print(string: "\n")
}
