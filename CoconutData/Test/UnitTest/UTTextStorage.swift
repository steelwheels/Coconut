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

	var idx = str.string.index(str.string.startIndex, offsetBy: 15)

	cons.print(string: "- Initial state\n")
	dump(index: idx, string: str, console: cons)

	let ecodes: Array<CNEscapeCode> = [
		.string("Hello"),
		.string("Good-morning!!"),
		//.string("Good\nevening!!"),
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
		.resetCharacterAttribute,
		.selectAltScreen(true),
		.cursorPosition(2, 5),
		.string("2x5"),
		.selectAltScreen(false),
		.scrollUp(2),
		.string("\n>"),
		.scrollDown(2),
		.string("\n<")
	]
	let terminfo = CNTerminalInfo(width: 20, height: 10)
	terminfo.foregroundColor	= CNColor.green
	terminfo.backgroundColor	= CNColor.black
	for ecode in ecodes {
		let font = CNFont.systemFont(ofSize: CNFont.systemFontSize)
		idx = execute(string: str, index: idx, escapeCode: ecode, font: font, terminalInfo: terminfo, console: cons)
	}

	return true
}

private func execute(string str: NSMutableAttributedString, index idx: String.Index, escapeCode ecode: CNEscapeCode, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo, console cons: CNConsole) -> String.Index
{
	cons.print(string: "- Execute:\(ecode.description())\n")
	if let result = str.execute(base: str.string.startIndex, index: idx, font: fnt, terminalInfo: terminfo, escapeCode: ecode) {
		dump(index: result, string: str, console: cons)
		return result
	} else {
		return idx
	}
}

private func dump(index idx: String.Index, string astr: NSAttributedString, console cons: CNConsole)
{
	let str = astr.string
	var ptr = str.startIndex
	let end = str.endIndex
	cons.print(string: "-------- [begin]\n")
	while ptr < end {
		if ptr == idx {
			cons.print(string: "*")
		} else {
			cons.print(string: ".")
		}
		let c = str[ptr]
		if c == " " {
			cons.print(string: "_")
		} else if c.isNewline {
			cons.print(string: "$\n")
		} else {
			cons.print(string: "\(c)")
		}
		ptr = str.index(after: ptr)
	}
	if idx == end {
		cons.print(string: "*$")
	}
	cons.print(string: "\n-------- [end]\n")
}
