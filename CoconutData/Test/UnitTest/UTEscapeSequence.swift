/**
 * @file	UTEscapeSequence.swift
 * @brief	Test function for CNEscapeSequence
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testEscapeSequence(console cons: CNConsole) -> Bool
{
	let res0 = dumpSequence(string: "Hello, World !!", console: cons)
	let res1 = dumpCode(code: CNEscapeCode.cursorUp(1), console: cons)
	let res2 = dumpCode(code: CNEscapeCode.cursorForward(3), console: cons)
	let res3 = dumpCode(code: CNEscapeCode.cursorPoisition(1, 2), console: cons)
	let res4 = dumpCode(code: CNEscapeCode.eraceFromBeginToEnd, console: cons)

	let str0 = CNEscapeCode.cursorNextLine(1).encode()
	let str1 = CNEscapeCode.eraceFromBeginToEnd.encode()
	let str  = "Hello, " + str0 + " and " + str1 + ". Bye."
	let res5 = dumpSequence(string: str, console: cons)

	return res0 && res1 && res2 && res3 && res4 && res5
}

private func dumpCode(code ecode: CNEscapeCode, console cons: CNConsole) -> Bool {
	cons.print(string: "* dumpCode\n")
	let str = ecode.encode()
	cons.print(string: "code: \"\(str)\"\n")
	let (err, codes) = CNEscapeCode.decode(string: str)

	var result = false
	if let e = err {
		cons.error(string: "[Error] \(e.description())\n")
	} else {
		for code in codes {
			cons.print(string: code.description())
			cons.print(string: "\n")
		}
		if codes.count == 1 {
			if ecode.compare(code: codes[0]) {
				cons.print(string: "Same code\n")
				result = true
			} else {
				cons.error(string: "[Error] Different code\n")
			}
		} else {
			cons.error(string: "[Error] Too many codes\n")
		}
	}
	return result
}

private func dumpSequence(string src: String, console cons: CNConsole) -> Bool {
	cons.print(string: "* dumpSequence\n")
	let (err, codes) = CNEscapeCode.decode(string: src)
	if let e = err {
		cons.print(string: "[Error] " + e.description() + "\n")
		return false
	} else {
		for code in codes {
			cons.print(string: code.description())
			cons.print(string: "\n")
		}
		return true
	}
}
