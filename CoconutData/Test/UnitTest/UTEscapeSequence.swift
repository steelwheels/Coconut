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
	let res0  = dumpSequence(string: "Hello, World !!", console: cons)
	let res1  = dumpCode(code: CNEscapeCode.cursorUp(1), console: cons)
	let res2  = dumpCode(code: CNEscapeCode.cursorForward(3), console: cons)
	let res21 = dumpCode(code: CNEscapeCode.saveCursorPosition, console: cons)
	let res22 = dumpCode(code: CNEscapeCode.restoreCursorPosition, console: cons)
	let res3  = dumpCode(code: CNEscapeCode.cursorPosition(1, 2), console: cons)
	let res4  = dumpCode(code: CNEscapeCode.eraceEntireLine, console: cons)

	let res11 = dumpCode(code: CNEscapeCode.boldCharacter(true), console: cons)
	let res12 = dumpCode(code: CNEscapeCode.boldCharacter(false), console: cons)
	let res13 = dumpCode(code: CNEscapeCode.underlineCharacter(true), console: cons)
	let res14 = dumpCode(code: CNEscapeCode.underlineCharacter(false), console: cons)
	let res15 = dumpCode(code: CNEscapeCode.blinkCharacter(true), console: cons)
	let res16 = dumpCode(code: CNEscapeCode.blinkCharacter(false), console: cons)
	let res17 = dumpCode(code: CNEscapeCode.reverseCharacter(true), console: cons)
	let res18 = dumpCode(code: CNEscapeCode.reverseCharacter(false), console: cons)

	let res6  = dumpCode(code: CNEscapeCode.foregroundColor(.white), console: cons)
	let res19 = dumpCode(code: CNEscapeCode.defaultForegroundColor, console: cons)
	let res7  = dumpCode(code: CNEscapeCode.backgroundColor(.red), console: cons)
	let res20 = dumpCode(code: CNEscapeCode.defaultBackgroundColor, console: cons)
	let res8  = dumpCode(code: CNEscapeCode.resetCharacterAttribute, console: cons)
	let res9  = dumpCode(code: CNEscapeCode.requestScreenSize, console: cons)
	let res10 = dumpCode(code: CNEscapeCode.screenSize(80, 25), console: cons)

	let str0 = CNEscapeCode.cursorNextLine(1).encode()
	let str1 = CNEscapeCode.eraceEntireLine.encode()
	let str  = "Hello, " + str0 + " and " + str1 + ". Bye."
	let res5 = dumpSequence(string: str, console: cons)

	let lsstr = "Applications\r"
		    + "Desktop\r"
		    + "Development\r"
		    + "Documents\r"
		    + "Downloads\r"
		    + "Google ドライブ\r"
		    + "Library\r"
		    + "Movies\r"
		    + "Music\r"
		    + "Pictures\r"
		    + "Project\r"
		    + "Public\r"
		    + "Script\r"
		    + "Sequrity\r"
		    + "Shared\r"
		    + "Sites\r"
		    + "build\r"
		    + "iCloud Drive（アーカイブ）\r"
		    + "local\r"
		    + "tmp_dir\r"
		    + "tools\r"
		    + "アプリケーション\r"
	let res23  = dumpSequence(string: lsstr, console: cons)

	let result = res0 && res1 && res2 && res3 && res4 && res5 && res6 && res7 && res8 && res9 && res10 &&
		     res11 && res12 && res13 && res14 && res15 && res16 && res17 && res18 && res19 && res20 &&
		     res21 && res22 && res23
	if result {
		cons.print(string: "testEscapeSequence .. OK\n")
	} else {
		cons.print(string: "testEscapeSequence .. NG\n")
	}
	//cons.error(string: "Color message\n")
	return  result
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
				let desc = codes[0].description()
				cons.error(string: "[Error] Different code: \(desc)\n")
			}
		} else {
			cons.error(string: "[Error] Too many codes\n")
		}
		result = true
	case .error(let err):
		cons.error(string: "[Error] \(err.toString())\n")
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
		cons.print(string: "[Error] " + err.toString() + "\n")
		result = false
	}
	return result
}


