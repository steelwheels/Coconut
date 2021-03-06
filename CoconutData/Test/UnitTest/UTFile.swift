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
	let url    = URL(fileURLWithPath: "CoconutData.framework/Resources/Info.plist")
	do {
		cons.print(string: "testFile: Start\n")
		let handle = try FileHandle(forReadingFrom: url)
		let file   = CNFile(fileHandle: handle)
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
				break
			}
		}
		//cons.print(string: "[Error] Failed to read Info.plist\n")
		cons.print(string: "ReadDone: \(file.readDone)\n")
		cons.print(string: "testFile: OK\n")
		return true
	}
	catch {
		cons.print(string: "[Error] Failed to read Info.plist\n")
	}
	cons.print(string: "testFile: NG\n")
	return false
}

