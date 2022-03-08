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
	let res0 = testObserverTable(console: cons)
	return res0
}

private func testObserverTable(console cons: CNConsole) -> Bool
{
	let vtable  = CNObserverDictionary()
	var updated = false

	vtable.setValue(NSNumber(booleanLiteral: false), forKey: "isExecuting")
	let lid = vtable.addObserver(forKey: "isExecuting", listnerFunction: {
		(_ value: Any?) -> Void in
		if let num = value as? NSNumber {
			cons.print(string: "isExecuting -> \(num.boolValue)\n")
			updated = true
		} else {
			cons.print(string: "isExecuting -> Unknown\n")
		}
	})

	vtable.setValue(NSNumber(booleanLiteral: true), forKey: "isExecuting")
	Thread.sleep(forTimeInterval: 1.0)

	vtable.removeObserver(listnerHolder: lid)

	let result = updated
	if result {
		cons.print(string: "testObserver (d) .. OK\n")
	} else {
		cons.print(string: "testObserver (d) .. NG\n")
	}

	return result
}
