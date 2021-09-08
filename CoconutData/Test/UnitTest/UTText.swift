/**
 * @file	UTText.swift
 * @brief	Test for CNText class
 * @par Copyright
 *   Copyright (C) 20121Steel Wheels Project
 */

import CoconutData
import Foundation

public func testText(console cons: CNConsole) -> Bool
{
	let sect0 = CNTextSection()
	sect0.header = "header: {"
	sect0.footer = "}"

	let line0 = CNTextLine(string: "1 + 1")
	line0.append(string: "= 2")
	line0.prepend(string: "EXP:")
	sect0.add(text: line0)

	let rec0 = CNTextRecord()
	rec0.append(string: "A0")
	rec0.append(string: "A1")
	rec0.append(string: "A2")

	let rec1 = CNTextRecord()
	rec1.prepend(string: "B10")
	rec1.prepend(string: "B09")
	rec1.prepend(string: "B08")

	let rec2 = CNTextRecord()
	rec2.prepend(string: "")
	rec2.prepend(string: "C0\nC1")
	rec2.prepend(string: "C2")

	let table0 = CNTextTable()
	table0.add(record: rec0)
	table0.add(record: rec1)
	table0.add(record: rec2)
	sect0.add(text: table0)

	cons.print(string: "Result of toString:\n")
	let lines = sect0.toStrings(indent: 0)
	for line in lines {
		cons.print(string: line + "\n")
	}
	return true
}

