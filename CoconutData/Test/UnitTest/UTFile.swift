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
	let url    = URL(fileURLWithPath: "Info.plist")
	do {
		let handle = try FileHandle(forReadingFrom: url)
		let file   = CNTextFile(fileHandle: handle)
		var docont = true
		while docont {
			#if false
				if let c = file.getc() {
					cons.print(string: String(c))
				} else {
					docont = false
				}
			#else
				if let line = file.getl() {
					cons.print(string: line)
				} else {
					docont = false
				}
			#endif
		}
		return true
	}
	catch {
		cons.print(string: "[Error] Failed to read Info.plist")
	}
	return false
}

