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
	let conf = CNConfig(logLevel: .debug)
	let pref = CNPreference.shared
	pref.systemPreference.set(config: conf)

	var result: Bool = false
	switch pref.systemPreference.logLevel {
	case .nolog:	cons.print(string: "LogLevel: noLog\n")
	case .error:	cons.print(string: "LogLevel: error\n")
	case .warning:	cons.print(string: "LogLevel: warning\n")
	case .debug:	cons.print(string: "LogLevel: debug\n")
			result = true
	case .detail:	cons.print(string: "LogLevel: detail\n")
	}

	if result {
		cons.print(string: "testPreference .. OK\n")
	} else {
		cons.print(string: "testPreference .. NG\n")
	}

	return result
}

