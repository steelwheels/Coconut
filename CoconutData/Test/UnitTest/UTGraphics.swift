/**
 * @file	UTGraphics.swift
 * @brief	Test function for CNGraphics
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testGraphics(console cons: CNConsole) -> Bool
{
	let mapper  = CNGraphicsMapper(physicalSize: CGSize(width: 100.0, height: 100.0))
	let result0 = testMapper(graphicsMapper: mapper, logicalSize: CGSize(width: 200.0, height: 200), console: cons)
	return result0
}

private func testMapper(graphicsMapper mapper: CNGraphicsMapper, logicalSize lsize: CGSize, console cons: CNConsole) -> Bool
{
	mapper.logicalSize = lsize

	let l0pt = CGPoint(x: 10.0, y: 10.0)
	let p0pt = mapper.logicalToPhysical(point: l0pt)
	let r0pt = mapper.physicalToLogical(point: p0pt)
	cons.print(string: "point: \(l0pt.debugDescription) -> \(p0pt.debugDescription) -> \(r0pt.debugDescription) ... ")
	let result0 = (l0pt.x == r0pt.x) && (l0pt.y == r0pt.y)
	if result0 {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG\n")
	}

	let l1sz = CGSize(width: 5.0, height: 5.0)
	let p1sz = mapper.logicalToPhysical(size: l1sz)
	let r1sz = mapper.physicalToLogical(size: p1sz)
	cons.print(string: "size: \(l1sz.debugDescription) -> \(p1sz.debugDescription) -> \(r1sz.debugDescription) ... ")
	let result1 = (l1sz.width == r1sz.width) && (l1sz.height == r1sz.height)
	if result1 {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG\n")
	}

	return result0 && result1
}

