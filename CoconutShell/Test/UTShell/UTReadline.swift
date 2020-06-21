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

	public init(environment env: CNEnvironment, console cons: CNFileConsole) {
		messages = [
			"This is first message",
			CNEscapeCode.cursorUp(1).encode(),
			CNEscapeCode.cursorDown(2).encode(),
			CNEscapeCode.cursorForward(3).encode(),
			CNEscapeCode.cursorBackward(4).encode(),
			CNEscapeCode.cursorForward(3).encode(),
			CNEscapeCode.cursorBackward(2).encode(),
			CNEscapeCode.cursorNextLine(5).encode(),
			CNEscapeCode.cursorPreviousLine(6).encode(),
			CNEscapeCode.cursorPosition(7, 8).encode(),
			"<INSERTED>",
			CNEscapeCode.eraceFromCursorToBegin.encode(),
			CNEscapeCode.eraceFromCursorToBegin.encode(),	// not changed
			CNEscapeCode.eraceFromCursorToEnd.encode(),
			"<NEW-ADDED>",
			"<MORE-ADDED>",
			CNEscapeCode.backspace.encode(),
			CNEscapeCode.cursorBackward(2).encode(),
			CNEscapeCode.backspace.encode(),
			CNEscapeCode.tab.encode(),
			"This\ris\rmulti\rlines\nmessage.",
			CNEscapeCode.eot.encode()	// End of transmission
		]
		messageIndex = 0
		super.init(environment: env)
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


public func testReadline(environment env: CNEnvironment, console cons: CNFileConsole) -> Bool
{
	let readline = UTReadline(environment: env, console: cons)

	var docont = true
	while docont {
		switch readline.readLine(console: cons) {
		case .commandLine(let cmdline, let determined):
			let (cmdstr, cmdpos) = cmdline.getAndClear(didDetermined: determined)
			cons.print(string: "CMDLINE: \(cmdpos) \(cmdstr) \(determined)\n")
		case .escapeCode(let code):
			switch code {
			case .eot:
				docont = false
			default:
				cons.print(string: "ECODE: \(code.description())\n")
			}
		case .none:
			break
		}
	}
	return true
}

