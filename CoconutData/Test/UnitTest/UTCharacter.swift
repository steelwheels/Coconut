/**
 * @file	UTStringUtil.swift
 * @brief	Test function for CNStringUtil
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testCharacter(console cons: CNConsole) -> Bool
{
	for i in stride(from: 0x0, to: 0x80, by: 8){
		for j in 0..<8 {
			let code = i + j
			let name: String
			if let str = Character.asciiCodeName(code: code) {
				name = str
			} else {
				name = "<unknown>"
			}
			let hexval = String(format: "0x%02x", arguments: [code])
			cons.print(string: "\"\(name)\":\(hexval) ")
		}
		cons.print(string: "\n")
	}
	return true
}

