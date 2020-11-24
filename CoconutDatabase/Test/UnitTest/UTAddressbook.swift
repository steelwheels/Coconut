/**
 * @file	UTAddressbook.swift
 * @brief	Define UTAddressbook function to test CNAddressBook class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutDatabase
import CoconutData
import Foundation

public func UTAddressbook(console cons: CNConsole) -> Bool
{
	var result = false
	let adbook = CNAddressBook()

	var docont = true
	while docont {
		switch adbook.authorize() {
		case .Authorized:
			cons.print(string: "authorize: done\n")
			result = true
			result = true
		case .Denied:
			cons.print(string: "authorize: denyed\n")
			docont = false
		case .Examinating:
			cons.print(string: "authorize: examinating\n")
		case .Undetermined:
			cons.print(string: "authorize: undetermined\n")
			docont = false
		@unknown default:
			cons.print(string: "authorize: undefined (Internal error)\n")
			docont = false
		}
	}

	return result
}

