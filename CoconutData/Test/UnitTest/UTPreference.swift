/**
 * @file	UTPreference.swift
 * @brief	Test function for CNPreference class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testPreference(console cons: CNConsole) -> Bool
{
	let conf = CNConfig(doVerbose: true)
	let pref = CNPreference.shared
	pref.set(config: conf)

	var result: Bool = true
	if pref.systemPreference.doVerbose {
		cons.print(string: "Verbose mode is set ... OK\n")
	} else {
		cons.print(string: "Verbose mode is NOT set ... Error\n")
		result = false
	}

	return result
}

