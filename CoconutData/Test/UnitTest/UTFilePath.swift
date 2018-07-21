/**
 * @file	UTFilePath.swift
 * @brief	Test function for CNFilePass class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testFilePath(console cons: CNConsole) -> Bool
{
	let url = URL(fileURLWithPath: "/System//Library/WidgetResources/AppleClasses/AppleButton.js")
	if let uti = CNFilePath.UTIForFile(URL: url) {
		cons.print(string: "UTI: \(uti) \n")
		return true
	} else {
		cons.print(string: "Error: No UTI\n")
		return false
	}
}

