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
	testTrace(string: " * ", console: cons)
	testTrace(string: "* ", console: cons)
	testTrace(string: " *", console: cons)
	testTrace(string: "*", console: cons)
	testTrace(string: " ", console: cons)
	testTrace(string: "", console: cons)
	return true
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
