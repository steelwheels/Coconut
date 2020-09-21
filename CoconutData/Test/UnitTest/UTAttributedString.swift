/**
 * @file	UTAttrobutedString.swift
 * @brief	Test function for CNAttributedString
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#endif
import CoconutData
import Foundation

private struct TestString {
	var	text:		NSMutableAttributedString
	var	index:		Int

	public init(text txt: String, index idx: Int) {
		let t = NSMutableAttributedString(string: txt)
		self.text 	= t
		self.index	= idx
	}

	public func dump(console cons: CNConsole) {
		var ptr = 0
		let end = text.string.count
		cons.print(string: "-------- [begin]\n")
		while ptr < end {
			if ptr == index {
				cons.print(string: "*")
			} else {
				cons.print(string: ".")
			}
			if let c = text.character(at: ptr) {
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
		if index == end {
			cons.print(string: "*<")
		}
		cons.print(string: "\n-------- [end]\n")
	}
}

public func testAttributedString(console cons: CNConsole) -> Bool
{
	let vectors: Array<TestString> = [
		TestString(text: "abc", index: 1),
		TestString(text: "abc\ndef\nghi\n", index: 6),
		TestString(text: "ドライブ", index: 3),
		TestString(text: "ドライブ1\nドライブ2\n", index: 4)
	]

	var result0 = true
	for vector in vectors {
		let terminfo = CNTerminalInfo(width: 40, height: 10)
		if !testVector(vector: vector, console: cons, terminalInfo: terminfo) {
			result0 = false
		}
	}

	let result1 = testPadding(console: cons)

	return result0 && result1
}

private func testVector(vector src: TestString, console cons: CNConsole, terminalInfo terminfo: CNTerminalInfo) -> Bool
{
	cons.print(string: "Start Vector Test --------------\n")
	let fnt = NSFont.systemFont(ofSize: 10.0)

	var vec = src
	vec.dump(console: cons)

	let cnt = vec.text.lineCount(from: 0, to: vec.text.string.count)
	cons.print(string: "Line count = \(cnt)\n")

	let hoff = vec.text.distanceFromLineStart(to: vec.index)
	cons.print(string: "holizOffset = \(hoff)\n")

	let hroff = vec.text.distanceToLineEnd(from: vec.index)
	cons.print(string: "holizReverseOffset = \(hroff)\n")

	cons.print(string: "moveCursorBackward(1)\n")
	vec.index = vec.text.moveCursorBackward(from: vec.index, number: 1)
	vec.dump(console: cons)

	cons.print(string: "moveCursorBackward(2)\n")
	vec.index = vec.text.moveCursorBackward(from: vec.index, number: 2)
	vec.dump(console: cons)

	cons.print(string: "moveCursorForward(3)\n")
	vec.index = vec.text.moveCursorForward(from: vec.index, number: 3)
	vec.dump(console: cons)

	cons.print(string: "moveCursorForward(4)\n")
	vec.index = vec.text.moveCursorForward(from: vec.index, number: 4)
	vec.dump(console: cons)

	cons.print(string: "moveCursorToLineStart\n")
	vec.index = vec.text.moveCursorToLineStart(from: vec.index)
	vec.dump(console: cons)

	cons.print(string: "moveCursorToLineEnd\n")
	vec.index = vec.text.moveCursorToLineEnd(from: vec.index)
	vec.dump(console: cons)

	cons.print(string: "moveCursorUpOrDown(up, 1)\n")
	vec.index = vec.text.moveCursorUpOrDown(from: vec.index, doUp: true, number: 1)
	vec.dump(console: cons)

	cons.print(string: "moveCursorUpOrDown(down, 2)\n")
	vec.index = vec.text.moveCursorUpOrDown(from: vec.index, doUp: false, number: 2)
	vec.dump(console: cons)

	cons.print(string: "moveCursorTo(x=1)\n")
	vec.index = vec.text.moveCursorTo(from: vec.index, x: 1)
	vec.dump(console: cons)

	cons.print(string: "moveCursorTo(x=0, y=1)\n")
	vec.index = vec.text.moveCursorTo(base: 0, x: 0, y: 1)
	vec.dump(console: cons)

	cons.print(string: "moveCursorForward(2)\n")
	vec.index = vec.text.moveCursorForward(from: vec.index, number: 2)
	vec.dump(console: cons)

	cons.print(string: "insert(\"ドライブ\", \(vec.index)\n")
	vec.text.insert(NSAttributedString(string: "ドライブ"), at: vec.index)
	vec.dump(console: cons)

	cons.print(string: "write(\"ABCD\")\n")
	vec.index = vec.text.write(string: "ABCD", at: vec.index, font: fnt, terminalInfo: terminfo)
	vec.dump(console: cons)

	cons.print(string: "moveCursorBackward(2)\n")
	vec.index = vec.text.moveCursorBackward(from: vec.index, number: 2)
	vec.dump(console: cons)

	cons.print(string: "deleteForwardCharacters(1)\n")
	vec.index = vec.text.deleteForwardCharacters(from: vec.index, number: 1)
	vec.dump(console: cons)

	cons.print(string: "deleteBackwardCharacters(1)\n")
	vec.index = vec.text.deleteBackwardCharacters(from: vec.index, number: 1)
	vec.dump(console: cons)

	cons.print(string: "delete(1 to 2)\n")
	vec.text.delete(from: 1, to: 2)
	vec.index = 0
	vec.dump(console: cons)

	cons.print(string: "delete(1 len 2)\n")
	vec.text.delete(from: 1, length: 2)
	vec.dump(console: cons)

	cons.print(string: "deleteEntireLine\n")
	vec.index = vec.text.deleteEntireLine(from: vec.index)
	vec.dump(console: cons)

	return true
}

private func testPadding(console cons: CNConsole) -> Bool
{
	let str1 = TestString(text: "aaa\nbb", index: 0)
	let str2 = TestString(text: "aaa\nbb", index: 0)
	let str3 = TestString(text: "a\n-b\n--c\n---d\n----e", index: 0)
	let str4 = TestString(text: "", index: 0)
	//let str5 = TestString(text: "\n", index: 0, xPos: 0, yPos: 0)
	//let str6 = TestString(text: "a", index: 0, xPos: 0, yPos: 0)
	//let str7 = TestString(text: "a\n", index: 0, xPos: 0, yPos: 0)
	let strs = [str1, str2, str3, str4] //, str5] //, str6, str7]

	for str in strs {
		cons.print(string: "*** Test padding\n")
		testPadding(string: str, console: cons)
	}
	return true
}

private func testPadding(string str: TestString, console cons: CNConsole) {
	let terminfo = CNTerminalInfo(width: 5, height: 5)
	let font     = CNFont.systemFont(ofSize: 10.0)
	str.text.resize(width: 5, height: 5, font: font, terminalInfo: terminfo)
	str.dump(console: cons)
}

