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
		.boldCharacter(true),
		.underlineCharacter(true),
		.blinkCharacter(true),
		.reverseCharacter(true),
		.foregroundColor(.red),
		.defaultForegroundColor,
		.backgroundColor(.blue),
		.defaultBackgroundColor,
		.string("COLOR"),
		.resetCharacterAttribute
	]
	for ecode in ecodes {
		let fmt  = CNStringFormat(foregroundColor: CNColor.green, backgroundColor: CNColor.black, doBold: false, doItalic: false, doUnderline: false, doReverse: false)
		let font = CNFont.systemFont(ofSize: CNFont.systemFontSize)
		idx = execute(string: str, index: idx, escapeCode: ecode, font: font, format: fmt, console: cons)
	}

	return true
}

private func execute(string str: NSMutableAttributedString, index idx: Int, escapeCode ecode: CNEscapeCode, font fnt: CNFont, format fmt: CNStringFormat, console cons: CNConsole) -> Int
{
	if let result = str.execute(index: idx, font: fnt, format: fmt, escapeCode: ecode) {
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
