/**
 * @file	UTVectorGraphics.swift
 * @brief	Test function for vector graphics dlasses
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testVectorGraphics(console cons: CNConsole) -> Bool
{
	cons.print(string: "Decode/ecode graphics objects")
	return valueTest(console: cons)
}

private func valueTest(console cons: CNConsole) -> Bool {
	var result = true

	/* CGPoint */
	let point0 = CGPoint(x: 12.0, y: 34.0)
	let point0val = point0.toValue()
	printValue(message: "point0:", value: .interfaceValue(point0val), console: cons)
	if let point0rev = CGPoint.fromValue(value: point0val) {
		if point0.equalTo(point0rev) {
			cons.print(string: "OK: point0 (0)\n")
		} else {
			cons.print(string: "Error: point0 (0)\n")
			result = false
		}
	} else {
		cons.print(string: "Error: point0 (1)\n")
		result = false
	}

	/* CGSize */
	let size0 = CGSize(width: 12.0, height: 34.0)
	let size0val = size0.toValue()
	printValue(message: "size0:", value: .interfaceValue(size0val), console: cons)
	if let size0rev = CGSize.fromValue(value: size0val) {
		if size0.equalTo(size0rev) {
			cons.print(string: "OK: size0 (0)\n")
		} else {
			cons.print(string: "Error: size0 (0)\n")
			result = false
		}
	} else {
		cons.print(string: "Error: size0 (1)\n")
		result = false
	}


	return result
}

private func printValue(message msg: String, value val: CNValue, console cons: CNConsole){
	let txt = val.toScript()
	let lines = txt.toStrings().joined(separator: "\n")
	cons.print(string: msg + ": " + lines)
}
