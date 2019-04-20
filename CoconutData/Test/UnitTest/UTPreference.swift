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
	let result = true

	let config = CNConfig()
	config.buildMode = .Release
	CNSetupPreference(config: config)

	let pref = CNPreference.shared
	let mode = pref.systemPreference.buildMode
	cons.print(string: "System Preference: buildMode=\(mode.description)\n")

	return result
}

