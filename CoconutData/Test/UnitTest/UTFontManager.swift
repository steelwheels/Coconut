/**
 * @file	UTFontManager.swift
 * @brief	Test function for CNFontManager class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testFontManager(console cons: CNConsole) -> Bool
{
	let names = CNFontManager.shared.availableFixedPitchFonts
	//for name in names {
	//	cons.print(string: "fixed-pitch-font: \(name)\n")
	//}

	let result = names.count > 0
	if result {
		cons.print(string: "testFontManager .. OK\n")
	} else {
		cons.print(string: "testFontManager .. NG\n")
	}
	return result
}

