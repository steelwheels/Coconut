/**
 * @file	UTURL.swift
 * @brief	Test function for URL class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testURL(console cons: CNConsole) -> Bool
{
	var result = true

	let nullurl = URL(fileURLWithPath: "/dev/null")
	cons.print(string: "nullURL = \(nullurl.absoluteString)\n")
	if nullurl.isValid {
		result = false
	}
	return result
}

