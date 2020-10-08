/**
 * @file	UTObserver.swift
 * @brief	Test function for CNObservedValueTable class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testObserver(console cons: CNConsole) -> Bool
{
	let vtable  = CNObservedValueTable()
	var updated = false

	vtable.setValue(NSNumber(booleanLiteral: false), forKey: "isExecuting")
	vtable.addObserver(forKey: "isExecuting", listnerFunction: {
		(_ value: Any?) -> Void in
		if let num = value as? NSNumber {
			cons.print(string: "isExecuting -> \(num.boolValue)\n")
			updated = true
		} else {
			cons.print(string: "isExecuting -> Unknown\n")
		}
	})

	vtable.setValue(NSNumber(booleanLiteral: true), forKey: "isExecuting")

	return updated
}

