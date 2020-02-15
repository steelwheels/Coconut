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
	for name in names {
		cons.print(string: "fixed-pitch-font: \(name)\n")
	}
	
	return true
}

