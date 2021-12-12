/**
 * @file	UTBitmap.swift
 * @brief	Test function for CNBitmapContext, CNBitmapData
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#endif
import CoconutData
import Foundation

public func testBitmap(console cons: CNConsole) -> Bool
{
	cons.print(string: "* Init state\n")
	let base = CNBitmapData(width: 10, height: 10)
	dump(bitmap: base, console: cons)

	cons.print(string: "* Set 3 points\n")
	base.set(x: 1, y: 1, color: CNColor.red)
	base.set(x: 2, y: 2, color: CNColor.green)
	base.set(x: 3, y: 3, color: CNColor.blue)
	dump(bitmap: base, console: cons)

	cons.print(string: "* Set 3x3 bitmap\n")
	let yellow = CNColor.yellow
	let data = [
		[yellow, yellow, yellow],
		[yellow, yellow, yellow],
		[yellow, yellow, yellow]
	]
	base.set(x: 4, y: 4, bitmap: CNBitmapData(colorData: data))
	dump(bitmap: base, console: cons)

	return true
}

private func dump(bitmap bm: CNBitmapData, console cons: CNConsole)
{
	let text = bm.toText()
	let str  = text.toStrings().joined(separator: "\n")
	cons.print(string: str + "\n")
}


