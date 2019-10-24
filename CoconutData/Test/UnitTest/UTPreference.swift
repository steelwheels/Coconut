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
	let conf = CNConfig(logLevel: .flow)
	let pref = CNPreference.shared
	pref.set(config: conf)

	var result: Bool = false
	switch pref.systemPreference.logLevel {
	case .error:	cons.print(string: "LogLevel: error\n")
	case .warning:	cons.print(string: "LogLevel: warning\n")
	case .flow:	cons.print(string: "LogLevel: flow\n")
			result = true
	case .detail:	cons.print(string: "LogLevel: detail\n")
	}

	return result
}

