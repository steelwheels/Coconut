/**
 * @file	UTReadline.swift
 * @brief	Test function for CNReadline
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutShell
import CoconutData
import Foundation

private class UTReadline: CNReadline {
	private var messages: 		Array<String>
	private var messageIndex:	Int

	public var didFinished: Bool {
		get { return messageIndex >= messages.count }
	}

	public init(console cons: CNFileConsole) {
		messages = [
			"This is first message",
			CNEscapeCode.cursorUp(1).encode(),
			CNEscapeCode.cursorDown(2).encode(),
			CNEscapeCode.cursorForward(3).encode(),
			CNEscapeCode.cursorBack(4).encode(),
			CNEscapeCode.cursorForward(3).encode(),
			CNEscapeCode.cursorBack(2).encode(),
			CNEscapeCode.cursorNextLine(5).encode(),
			CNEscapeCode.cursorPreviousLine(6).encode(),
			CNEscapeCode.cursorPoisition(7, 8).encode(),
			"<INSERTED>",
			CNEscapeCode.eraceFromCursorToBegin.encode(),
			CNEscapeCode.eraceFromCursorToBegin.encode(),	// not changed
			CNEscapeCode.eraceFromCursorToEnd.encode(),
			"<NEW-ADDED>",
			"<MORE-ADDED>",
			CNEscapeCode.backspace.encode(),
			CNEscapeCode.cursorBack(2).encode(),
			CNEscapeCode.backspace.encode(),
			CNEscapeCode.tab.encode()
		]
		messageIndex = 0
		super.init()
	}

	public override func scan(console cons: CNConsole) -> String? {
		if messageIndex < messages.count {
			let msg = messages[messageIndex]
			messageIndex += 1
			return msg
		} else {
			return nil
		}
	}
}


public func testReadline(console cons: CNFileConsole) -> Bool
{
	let readline = UTReadline(console: cons)

	var docont = true
	while docont {
		if !readline.didFinished {
			switch readline.readLine(console: cons) {
			case .commandLine(let cmdline):
				//if cmdline.didDetermined {
					let (cmdstr, cmdpos) = cmdline.get()
					cons.print(string: "CTXT: \(cmdpos) \(cmdstr)\n")
				//}
			case .escapeCode(let code):
				cons.print(string: "ECODE: \(code.description())\n")
			case .none:
				break
			}
		} else {
			docont = false
		}
	}
	return true
}

