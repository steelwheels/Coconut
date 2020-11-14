/**
 * @file	UTColor.swift
 * @brief	Test function for the extension of NSColor class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testColor(console cons: CNConsole) -> Bool
{
	let res0 = testColorConvert(name: "black",   color: CNColor.black, console: cons)
	let res1 = testColorConvert(name: "red",     color: CNColor.red, console: cons)
	let res2 = testColorConvert(name: "green",   color: CNColor.green, console: cons)
	let res3 = testColorConvert(name: "yellow",  color: CNColor.yellow, console: cons)
	let res4 = testColorConvert(name: "blue",    color: CNColor.blue, console: cons)
	let res5 = testColorConvert(name: "magenta", color: CNColor.magenta, console: cons)
	let res6 = testColorConvert(name: "cyan",    color: CNColor.cyan, console: cons)
	let res7 = testColorConvert(name: "white",   color: CNColor.white, console: cons)
	return res0 && res1 && res2 && res3 && res4 && res5 && res6 && res7
}

private func testColorConvert(name nm: String, color col: CNColor, console cons: CNConsole) -> Bool
{
	var result = false
	let code   = col.escapeCode()
	if let dupcol = CNColor.color(withEscapeCode: code) {
		if nm == col.rgbName && nm == dupcol.rgbName {
			cons.print(string: "\(nm) : OK\n")
			result = true
		} else {
			cons.print(string: "\(nm) : NG \(nm) \(col.rgbName) \(dupcol.rgbName)\n")
		}
	} else {
		cons.print(string: "Failed to allocate: \(code)\n")
	}
	if result {
		cons.print(string: "testColorConvert .. OK\n")
	} else {
		cons.print(string: "testColorConvert .. NG\n")
	}
	return result
}

