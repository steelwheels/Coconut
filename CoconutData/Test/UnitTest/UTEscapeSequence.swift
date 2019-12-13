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
	let res4 = dumpCode(code: CNEscapeCode.eraceEntireLine, console: cons)
	let res6 = dumpCode(code: CNEscapeCode.foregroundColor(.White), console: cons)
	let res7 = dumpCode(code: CNEscapeCode.backgroundColor(.Red), console: cons)
	let res8 = dumpCode(code: CNEscapeCode.setNormalAttributes, console: cons)
	let res9 = dumpCode(code: CNEscapeCode.requestScreenSize, console: cons)
	let res10 = dumpCode(code: CNEscapeCode.screenSize(80, 25), console: cons)

	let str0 = CNEscapeCode.cursorNextLine(1).encode()
	let str1 = CNEscapeCode.eraceEntireLine.encode()
	let str  = "Hello, " + str0 + " and " + str1 + ". Bye."
	let res5 = dumpSequence(string: str, console: cons)

	cons.error(string: "Color message\n")

	return res0 && res1 && res2 && res3 && res4 && res5 && res6 && res7 && res8 && res9 && res10
}

private func dumpCode(code ecode: CNEscapeCode, console cons: CNConsole) -> Bool {
	cons.print(string: "* dumpCode\n")
	let result: Bool
	let str = ecode.encode()
	switch CNEscapeCode.decode(string: str) {
	case .ok(let codes):
		for code in codes {
			cons.print(string: code.description())
			cons.print(string: "\n")
		}
		if codes.count == 1 {
			if ecode.compare(code: codes[0]) {
				cons.print(string: "Same code\n")
			} else {
				cons.error(string: "[Error] Different code\n")
			}
		} else {
			cons.error(string: "[Error] Too many codes\n")
		}
		result = true
	case .error(let err):
		cons.error(string: "[Error] \(err.description())\n")
		result = false
	}
	return result
}

private func dumpSequence(string src: String, console cons: CNConsole) -> Bool {
	cons.print(string: "* dumpSequence\n")

	let result: Bool
	switch CNEscapeCode.decode(string: src) {
	case .ok(let codes):
		for code in codes {
			cons.print(string: code.description())
			cons.print(string: "\n")
		}
		result = true
	case .error(let err):
		cons.print(string: "[Error] " + err.description() + "\n")
		result = false
	}
	return result
}
