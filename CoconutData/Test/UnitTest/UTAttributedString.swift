/**
 * @file	UTAttrobutedString.swift
 * @brief	Test function for CNAttributedString
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testAttributedString(console cons: CNConsole) -> Bool
{
	let res0 = testSearchFunction(console: cons)
	let res1 = testMoveHolizFunction(console: cons)
	let res2 = testMoveVertFunction(console: cons)
	let res3 = testDeleteFunction(console: cons)
	let res4 = testWriteFunction(console: cons)
	let res5 = testJapaneseFunction(console: cons)
	return res0 && res1 && res2 && res3 && res4 && res5
}

private func testSearchFunction(console cons: CNConsole) -> Bool
{
	let str1 = NSAttributedString(string: "0123456789")
	printAttributedString(string: str1, cursor: 4, console: cons)

	cons.print(string: "**** Search forward  5 -> ")
	let off2 = str1.searchForward(character: "5", from: 4)
	printOffset(offset: off2, console: cons)

	cons.print(string: "**** Search forward  X -> ")
	let off3 = str1.searchForward(character: "X", from: 4)
	printOffset(offset: off3, console: cons)

	cons.print(string: "**** Search backward 1 -> ")
	let off4 = str1.searchBackward(character: "1", from: 4)
	printOffset(offset: off4, console: cons)

	cons.print(string: "**** Search backward 3 -> ")
	let off5 = str1.searchBackward(character: "3", from: 4)
	printOffset(offset: off5, console: cons)

	cons.print(string: "**** Search backward X -> ")
	let off6 = str1.searchBackward(character: "X", from: 4)
	printOffset(offset: off6, console: cons)

	return true
}

private func testMoveHolizFunction(console cons: CNConsole) -> Bool
{
	var result = true

	let pos0 = 13

	cons.print(string: "**** Original String   -> ")
	let str1 = NSMutableAttributedString(string: "abcdefg\n0123456789\nabcdefg")
	printAttributedString(string: str1, cursor: pos0, console: cons)

	cons.print(string: "**** Move forward: 1 -> ")
	let pos2 = str1.moveCursorForward(from: pos0, number: 1)
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

