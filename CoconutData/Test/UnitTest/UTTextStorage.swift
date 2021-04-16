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

private func execute(string storage: NSMutableAttributedString, index idx: Int, escapeCode ecode: CNEscapeCode, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo, console cons: CNConsole) -> Int
{
	cons.print(string: "- Execute:\(ecode.description())\n")

	var nextidx = idx
	switch ecode {
	case .string(let str):
		nextidx = storage.write(string: str, at: idx, font: fnt, terminalInfo: terminfo)
	case .eot:
		cons.print(string: "[EOT]")
	case .newline:
		nextidx = storage.write(string: "\n", at: idx, font: fnt, terminalInfo: terminfo)
	case .tab:
		nextidx = storage.write(string: "\t", at: idx, font: fnt, terminalInfo: terminfo)
	case .backspace:
		if let nidx = storage.moveCursorBackward(from: 1) {
			nextidx = nidx
		} else {
			cons.print(string: "[BS]")
		}
	case .delete:
		nextidx = storage.deleteBackwardCharacters(from: idx, number: 1)
	case .cursorUp(_):
		let hpos  = storage.distanceFromLineStart(to: idx)
		if let nidx1 = storage.moveCursorToPreviousLineEnd(from: idx) {
			nextidx = storage.moveCursorTo(from: nidx1, x: hpos)
		} else {

		}
	default:
		cons.print(string: "[\(ecode.description())]")

	}
	dump(index: nextidx, string: storage, console: cons)
	return nextidx

	/*
	case 	cursorUp(Int)
	case 	cursorDown(Int)
	case	cursorForward(Int)
	case	cursorBackward(Int)
	case	cursorNextLine(Int)			/* Moves cursor to beginning of the line n	*/
	case	cursorPreviousLine(Int)			/* Moves cursor to beginning of the line n	*/
	case	cursorHolizontalAbsolute(Int)		/* (Column) started from 1			*/
	case	saveCursorPosition			/* Save current cursor position			*/
	case	restoreCursorPosition			/* Update cursor position by saved one		*/
	case	cursorPosition(Int, Int)		/* (Row, Column) started from 1		 	*/
	case	eraceFromCursorToEnd			/* Clear from cursor to end of buffer 		*/
	case 	eraceFromCursorToBegin			/* Clear from begining of buffer to cursor	*/
	case	eraceEntireBuffer			/* Clear entire buffer				*/
	case 	eraceFromCursorToRight			/* Clear from cursor to end of line		*/
	case	eraceFromCursorToLeft			/* Clear from cursor to beginning of line	*/
	case	eraceEntireLine				/* Clear entire line				*/
	case	scrollUp(Int)				/* Scroll up n lines				*/
	case	scrollDown(Int)				/* Scroll down n lines				*/
	case	resetAll				/* Clear text, reset cursor postion and tabstop	*/
	case	resetCharacterAttribute			/* Reset all arributes for character		*/
	case	boldCharacter(Bool)			/* Set/reset bold font				*/
	case	underlineCharacter(Bool)		/* Set/reset underline font			*/
	case	blinkCharacter(Bool)			/* Set/reset blink font 			*/
	case	reverseCharacter(Bool)			/* Set/reset reverse character			*/
	case	foregroundColor(CNColor)		/* Set foreground color				*/
	case	defaultForegroundColor			/* Set default foreground color			*/
	case	backgroundColor(CNColor)		/* Set background color				*/
	case	defaultBackgroundColor			/* Reset default background color		*/

	case	requestScreenSize			/* Send request to receive screen size
							 * Ps = 18 -> Report the size of the text area in characters as CSI 8 ; height ; width t
							 */
	case	screenSize(Int, Int)			/* Set screen size (Width, Height)		*/
	case	selectAltScreen(Bool)			/* Do switch alternative screen (Yes/No) 	*/

	*/
}

private func dump(index idx: Int, string astr: NSAttributedString, console cons: CNConsole)
{
	var ptr = 0
	let end = astr.string.count
	cons.print(string: "-------- [begin]\n")
	while ptr < end {
		if ptr == idx {
			cons.print(string: "*")
		} else {
			cons.print(string: ".")
		}
		if let c = astr.character(at: ptr) {
			if c == " " {
				cons.print(string: "_")
			} else if c.isNewline {
				cons.print(string: "$\n")
			} else {
				cons.print(string: "\(c)")
			}
		} else {
			cons.print(string: "Invalid-index")
		}
		ptr += 1
	}
	if idx == end {
		cons.print(string: "*$")
	}
	cons.print(string: "\n-------- [end]\n")
}
