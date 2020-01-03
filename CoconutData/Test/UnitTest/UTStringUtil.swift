/**
 * @file	UTStringUtil.swift
 * @brief	Test function for CNStringUtil
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testStringUtil(console cons: CNConsole) -> Bool
{
	testPadding(console: cons)

	testTrace(string: " * ", console: cons)
	testTrace(string: "* ", console: cons)
	testTrace(string: " *", console: cons)
	testTrace(string: "*", console: cons)
	testTrace(string: " ", console: cons)
	testTrace(string: "", console: cons)

	cons.print(string: "// test CNStringUtil.divideBySpaces\n")
	testDivideBySpaces(string: "", console: cons)
	testDivideBySpaces(string: "a", console: cons)
	testDivideBySpaces(string: "12 23", console: cons)
	testDivideBySpaces(string: " 23 34 ", console: cons)
	testDivideBySpaces(string: " 34      4 5 ", console: cons)
	return true
}

private func testPadding(console cons: CNConsole)
{
	let src0 = "01234"
	let src1 = src0.pad(char: "-", toLength: 10, align: .left)
	let src2 = src0.pad(char: "-", toLength: 10, align: .right)
	let src3 = src0.pad(char: "-", toLength: 10, align: .center)

	cons.print(string: "\"padding---\"\n")
	cons.print(string: "\"0123456789\"\n")
	cons.print(string: "\"" + src1 + "\"\n")
	cons.print(string: "\"" + src2 + "\"\n")
	cons.print(string: "\"" + src3 + "\"\n")
}

private func testTrace(string str: String, console cons: CNConsole) {
	let skipfunc = {
		(_ c: Character) -> Bool in
		return c.isWhitespace
	}

	let fptr = CNStringUtil.traceForward(string: str, pointer: str.startIndex, doSkipFunc: skipfunc)
	let fstr = str.suffix(from: fptr)
	cons.print(string: "* traceForward:  \"\(str)\" -> \"\(fstr)\"\n")

	let bptr = CNStringUtil.traceBackward(string: str, pointer: str.endIndex, doSkipFunc: skipfunc)
	let bstr = str.prefix(upTo: bptr)
	cons.print(string: "* traceBackward: \"\(str)\" -> \"\(bstr)\"\n")

}

private func testDivideBySpaces(string str: String, console cons: CNConsole) {
	cons.print(string: "\"\(str)\" => [")
	let words = CNStringUtil.divideBySpaces(string: str)
	for word in words {
		cons.print(string: "\"\(word)\" ")
	}
	cons.print(string: "]\n")
}

