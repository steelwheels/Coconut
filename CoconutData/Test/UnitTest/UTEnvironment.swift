/**
 * @file	UTEnvironment.swift
 * @brief	Test function for CNEnvironment class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testEnvironment(console cons: CNFileConsole) -> Bool
{
	let env    = CNEnvironment()
	let paths  = env.paths

	if let home = env.getString(name: "HOME") {
		cons.print(string: "env(\"HOME\") = \"\(home)\"\n")
	} else {
		cons.print(string: "env(\"HOME\") = nil\n")
	}
	#if false
	for path in paths {
		cons.print(string: "env.path: \(path)\n")
	}
	return true
	#else
	return paths.count > 0
	#endif
}

