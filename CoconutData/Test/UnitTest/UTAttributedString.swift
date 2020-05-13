/**
 * @file	UTAttrobutedString.swift
 * @brief	Test function for CNAttributedString
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

private struct TestString {
	var	text:		NSMutableAttributedString
	var	index:		String.Index

	public init(text txt: String, index idx: Int) {
		let t = NSMutableAttributedString(string: txt)
		self.text 	= t
		self.index	= t.string.index(t.string.startIndex, offsetBy: idx)
	}

	public var string: String { get { return text.string }}

	public func dump(console cons: CNConsole) {
		var ptr = text.string.startIndex
		let end = text.string.endIndex
		cons.print(string: "-------- [begin]\n")
		while ptr < end {
			if ptr == index {
				cons.print(string: "*")
			} else {
				cons.print(string: ".")
			}
			let c = text.string[ptr]
			if c == " " {
				cons.print(string: "_")
			} else if c.isNewline {
				cons.print(string: "$\n")
			} else {
				cons.print(string: "\(c)")
			}
			ptr = text.string.index(after: ptr)
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
		TestString(text: "abc\ndef\nghi\n", index: 6)
	]

	var result0 = true
	for vector in vectors {
		if !testVector(vector: vector, console: cons) {
			result0 = false
		}
	}

	let result1 = testPadding(console: cons)

	return result0 && result1
}

private func testVector(vector src: TestString, console cons: CNConsole) -> Bool
{
	cons.print(string: "Start Vector Test --------------\n")
	var vec = src
	vec.dump(console: cons)

	let cnt = vec.string.lineCount(from: vec.string.startIndex, to: vec.string.endIndex)
	cons.print(string: "Line count = \(cnt)\n")

	let hoff = vec.string.holizontalOffset(from: vec.index)
	cons.print(string: "holizOffset = \(hoff)\n")

	let hroff = vec.string.holizontalReverseOffset(from: vec.index)
	cons.print(string: "holizReverseOffset = \(hroff)\n")

	cons.print(string: "moveCursorBackward(1)\n")
	vec.index = vec.string.moveCursorBackward(from: vec.index, number: 1)
	vec.dump(console: cons)

	cons.print(string: "moveCursorBackward(2)\n")
	vec.index = vec.string.moveCursorBackward(from: vec.index, number: 2)
	vec.dump(console: cons)

	cons.print(string: "moveCursorForward(3)\n")
	vec.index = vec.string.moveCursorForward(from: vec.index, number: 3)
	vec.dump(console: cons)

	cons.print(string: "moveCursorForward(4)\n")
	vec.index = vec.string.moveCursorForward(from: vec.index, number: 4)
	vec.dump(console: cons)

	cons.print(string: "moveCursorToLineStart\n")
	vec.index = vec.string.moveCursorToLineStart(from: vec.index)
	vec.dump(console: cons)

	cons.print(string: "moveCursorToLineEnd\n")
	vec.index = vec.string.moveCursorToLineEnd(from: vec.index)
	vec.dump(console: cons)

	cons.print(string: "moveCursorUpOrDown(up, 1)\n")
	vec.index = vec.string.moveCursorUpOrDown(from: vec.index, doUp: true, number: 1)
	vec.dump(console: cons)

	cons.print(string: "moveCursorUpOrDown(down, 2)\n")
	vec.index = vec.string.moveCursorUpOrDown(from: vec.index, doUp: false, number: 2)
	vec.dump(console: cons)

	cons.print(string: "moveCursorTo(x=1)\n")
	vec.index = vec.string.moveCursorTo(from: vec.index, x: 1)
	vec.dump(console: cons)

	cons.print(string: "moveCursorTo(x=0, y=1)\n")
	vec.index = vec.string.moveCursorTo(base: vec.string.startIndex, x: 0, y: 1)
	vec.dump(console: cons)

	cons.print(string: "write(\"ABCD\")\n")
	vec.index = vec.text.write(string: NSAttributedString(string: "ABCD"), at: vec.index)
	vec.dump(console: cons)

	cons.print(string: "moveCursorBackward(2)\n")
	vec.index = vec.string.moveCursorBackward(from: vec.index, number: 2)
	vec.dump(console: cons)

	cons.print(string: "deleteForwardCharacters(1)\n")
	vec.index = vec.text.deleteForwardCharacters(from: vec.index, number: 1)
	vec.dump(console: cons)

	cons.print(string: "deleteBackwardCharacters(1)\n")
	vec.index = vec.text.deleteBackwardCharacters(from: vec.index, number: 1)
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
	let strs = [str1, str2, str3, str4]

	for str in strs {
		cons.print(string: "*** Test padding")
		testPadding(string: str, console: cons)
	}
	return true
}

private func testPadding(string str: TestString, console cons: CNConsole) {
	let format = CNStringFormat(foregroundColor: CNColor.black, backgroundColor: CNColor.white, doBold: false, doItalic: false, doUnderline: false, doReverse: false)
	str.text.insertPadding(width: 5, height: 5, format: format)
	str.dump(console: cons)
}

/*
public func testAttributedString(console cons: CNConsole) -> Bool
{
	let res1 = testMoveHolizFunction(console: cons)
	let res2 = testMoveVertFunction(console: cons)
	let res3 = testDeleteFunction(console: cons)
	let res4 = testWriteFunction(console: cons)
	let res5 = testJapaneseFunction(console: cons)
	return res1 && res2 && res3 && res4 && res5
}

private func testMoveHolizFunction(console cons: CNConsole) -> Bool
{
	var result = true

	let pos0 = 13

	cons.print(string: "**** Original String   -> ")
	let str1 = NSMutableAttributedString(string: "abcdefg\n0123456789\nabcdefg")
	printAttributedString(string: str1, cursor: pos0, console: cons)

	cons.print(string: "**** Move forward: 1 -> ")
	let pos2 = str1.string.moveCursorForward(from: pos0, number: 1)
	printAttributedString(string: str1, cursor: pos2, console: cons)

	cons.print(string: "**** Move forward: 10 -> ")
	let pos3 = str1.moveCursorForward(from: pos2, number: 10)
	printAttributedString(string: str1, cursor: pos3, console: cons)

	cons.print(string: "**** Move backward: 2 -> ")
	let pos4 = str1.moveCursorBackward(from: pos3, number: 2)
	printAttributedString(string: str1, cursor: pos4, console: cons)

	cons.print(string: "**** Move backward: 10 -> ")
	let pos5 = str1.moveCursorBackward(from: pos4, number: 10)
	printAttributedString(string: str1, cursor: pos5, console: cons)

	if pos5 == 8 {
		cons.print(string: "Expected last position: \(pos5)\n")
	} else {
		cons.print(string: "Expected last position 8, But result is \(pos5)\n")
		result = false
	}

	let pos10 = 4

	let str2 = NSMutableAttributedString(string: "0123456789")
	printAttributedString(string: str2, cursor: pos10, console: cons)

	cons.print(string: "**** Move forward: 1 -> ")
	let pos11 = str2.moveCursorForward(from: pos10, number: 1)
	printAttributedString(string: str2, cursor: pos11, console: cons)

	cons.print(string: "**** Move forward: 10 -> ")
	let pos12 = str2.moveCursorForward(from: pos11, number: 10)
	printAttributedString(string: str2, cursor: pos12, console: cons)

	cons.print(string: "**** Move backward: 3 -> ")
	let pos13 = str2.moveCursorBackward(from: pos12, number: 3)
	printAttributedString(string: str2, cursor: pos13, console: cons)

	cons.print(string: "**** Move backward: 10 -> ")
	let pos14 = str2.moveCursorBackward(from: pos13, number: 10)
	printAttributedString(string: str2, cursor: pos14, console: cons)

	if pos14 == 0 {
		cons.print(string: "Expected last position: \(pos14)\n")
	} else {
		cons.print(string: "Expected last position 0, But result is \(pos14)\n")
		result = false
	}

	return result
}

private func testMoveVertFunction(console cons: CNConsole) -> Bool
{
	let pos0 = 12

	cons.print(string: "**** Original String   -> ")
	let str1 = NSMutableAttributedString(string: "abcdefg\n0123456789\nabcdefg")
	printAttributedString(string: str1, cursor: pos0, console: cons)

	cons.print(string: "**** Move down: 1(true) -> ")
	let pos2 = str1.moveCursorDown(from: pos0, number: 1, moveToHead: true)
	printAttributedString(string: str1, cursor: pos2, console: cons)

	cons.print(string: "**** Move down: 1(false) -> ")
	let pos3 = str1.moveCursorDown(from: pos0, number: 1, moveToHead: false)
	printAttributedString(string: str1, cursor: pos3, console: cons)

	cons.print(string: "**** Move up: 1(true) -> ")
	let pos4 = str1.moveCursorUp(from: pos0, number: 1, moveToHead: true)
	printAttributedString(string: str1, cursor: pos4, console: cons)

	cons.print(string: "**** Move up: 1(false) -> ")
	let pos5 = str1.moveCursorUp(from: pos0, number: 1, moveToHead: false)
	printAttributedString(string: str1, cursor: pos5, console: cons)

	return true
}

private func testDeleteFunction(console cons: CNConsole) -> Bool
{
	cons.print(string: "**** Original String   -> ")
	let str1 = NSMutableAttributedString(string: "abcdefg\n0123456789\nabcdefg")
	printAttributedString(string: str1, cursor: 13, console: cons)

	cons.print(string: "**** Delete forward: 1 -> ")
	let pos2 = str1.deleteForwardCharacters(at: 13, number: 1)
	printAttributedString(string: str1, cursor: pos2, console: cons)

	cons.print(string: "**** Delete backward: 1 -> ")
	let pos3 = str1.deleteBackwardCharacters(at: pos2, number: 1)
	printAttributedString(string: str1, cursor: pos3, console: cons)

	cons.print(string: "**** Delete forward: 10 -> ")
	let pos4 = str1.deleteForwardCharacters(at: pos3, number: 10)
	printAttributedString(string: str1, cursor: pos4, console: cons)

	cons.print(string: "**** Delete backward: 10 -> ")
	let pos5 = str1.deleteBackwardCharacters(at: pos4, number: 10)
	printAttributedString(string: str1, cursor: pos5, console: cons)

	cons.print(string: "**** Delete forward: 5 -> ")
	let pos6 = str1.deleteForwardCharacters(at: pos5, number: 5)
	printAttributedString(string: str1, cursor: pos6, console: cons)

	cons.print(string: "**** Delete backward: 5 -> ")
	let pos7 = str1.deleteBackwardCharacters(at: pos6, number: 5)
	printAttributedString(string: str1, cursor: pos7, console: cons)

	cons.print(string: "**** Delete entire-line -> ")
	let pos8 = str1.deleteEntireLine(at: pos7)
	printAttributedString(string: str1, cursor: pos8, console: cons)

	return true
}

private func testWriteFunction(console cons: CNConsole) -> Bool
{
	let pos0 = 12

	cons.print(string: "**** Original String   -> ")
	let str1 = NSMutableAttributedString(string: "abcdefg\n0123456789\nabcdefg")
	printAttributedString(string: str1, cursor: pos0, console: cons)

	cons.print(string: "**** Write String  -> ")
	let pos1 = str1.write(string: NSAttributedString(string: "Hello"), at: pos0)
	printAttributedString(string: str1, cursor: pos1, console: cons)

	cons.print(string: "**** Write String  -> ")
	let pos2 = str1.write(string: NSAttributedString(string: ",Good-Morning"), at: pos1)
	printAttributedString(string: str1, cursor: pos2, console: cons)

	cons.print(string: "**** Write String  -> ")
	let pos3 = str1.write(string: NSAttributedString(string: ",Goot-Night"), at: pos2)
	printAttributedString(string: str1, cursor: pos3, console: cons)

	if pos3 == 41 {
		cons.print(string: "Expected last position: \(pos3)\n")
		return true
	} else {
		cons.print(string: "Expected last position 41, But result is \(pos3)\n")
		return false
	}
}

private func testJapaneseFunction(console cons: CNConsole) -> Bool
{
	let pos0 = 9

	cons.print(string: "**** Original String   -> ")
	let str1 = NSMutableAttributedString(string: "アイウエオ\nあ1い2う3え4お5\nかきくけこ")
	printAttributedString(string: str1, cursor: pos0, console: cons)

	cons.print(string: "Delete forward 1 char ->" )
	let pos2 = str1.deleteForwardCharacters(at: pos0, number: 1)
	printAttributedString(string: str1, cursor: pos2, console: cons)

	cons.print(string: "Delete forward 1 char ->" )
	let pos3 = str1.deleteForwardCharacters(at: pos2, number: 1)
	printAttributedString(string: str1, cursor: pos3, console: cons)

	cons.print(string: "Delete backword 1 char ->" )
	let pos4 = str1.deleteBackwardCharacters(at: pos3, number: 1)
	printAttributedString(string: str1, cursor: pos4, console: cons)

	return true
}

private func printAttributedString(string str: NSAttributedString, cursor pos: Int, console cons: CNConsole) {
	var index: Int = 0
	var docont     = true
	cons.print(string: "\"")
	while docont {
		if index == pos {
			cons.print(string: "*")
		}
		if let c = str.character(at: index) {
			cons.print(string: "\(c)")
		} else {
			docont = false
		}
		index += 1
	}
	cons.print(string: "\"\n")
}

private func printOffset(offset ofst: Int?, console cons: CNConsole) {
	if let o = ofst {
		cons.print(string: "Offset = \(o)\n")
	} else {
		cons.print(string: "Offset = nil\n")
	}
}

*/

