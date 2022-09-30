/**
 * @file	UTFile.swift
 * @brief	Test function for CNFile classs
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testFile(console cons: CNConsole) -> Bool
{
	let res0 = readTest(console: cons)
	cons.print(string: "testFile: read test : \(res0 ? "OK" : "Error")\n")

	let res1 = writeTest(console: cons)
	cons.print(string: "testFile: write test: \(res1 ? "OK" : "Error")\n")

	return res0 && res1
}

private func readTest(console cons: CNConsole) -> Bool
{
	let url    = URL(fileURLWithPath: "CoconutData.framework/Resources/Info.plist")
	do {
		cons.print(string: "testFile: Start\n")
		let handle = try FileHandle(forReadingFrom: url)
		let file   = CNFile(access: .reader, fileHandle: handle)
		var docont = true
		while docont {
			switch file.getc() {
			case .char(let c):
				cons.print(string: String(c))
				/* Give close timing */
				file.close()
			case .endOfFile:
				docont = false
			case .null:
				break ; // continue
			}
		}
		//cons.print(string: "[Error] Failed to read Info.plist\n")
		cons.print(string: "ReadDone: \(file.readDone)\n")
		cons.print(string: "testFile: OK\n")
		return true
	} catch {
		cons.print(string: "[Error] Failed to read Info.plist\n")
	}
	cons.print(string: "testFile: NG\n")
	return false
}

private func writeTest(console cons: CNConsole) -> Bool
{
	let url  = URL(fileURLWithPath: "unit_test.txt")
	guard let file = CNFile.open(access: .writer, for: url) else {
		cons.print(string: "[Error] Faiiled to open for writing\n")
		return false
	}
	file.put(string: "Hello, world !!")
	file.close()
	return true
}

