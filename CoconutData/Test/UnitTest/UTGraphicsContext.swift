/**
 * @file	UTGraphicsContext.swift
 * @brief	Test function for CNGraphicsContext datastructure
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testGraphicsContext(console cons: CNConsole) -> Bool
{
	let lframe0 = CGRect(x: -1.0, y: -1.0, width:   2.0, height: 2.0)
	let pframe0 = CGRect(x:  0.0, y:  0.0, width: 128.0, height: 128.0)
	let context = CNGraphicsContext()
	context.begin(context: nil, logicalFrame: lframe0, physicalFrame: pframe0)
	convert(point: CGPoint(x: 0.0, y: 0.0), in: context, console: cons)

	let lframe1 = CGRect(x: -1.0, y: -1.0, width:   2.0, height:   2.0)
	let pframe1 = CGRect(x:  0.0, y:  0.0, width: 100.0, height: 200.0)
	context.begin(context: nil, logicalFrame: lframe1, physicalFrame: pframe1)
	convert(point: CGPoint(x: 1.0, y: 1.0), in: context, console: cons)
	convert(point: CGPoint(x: -1.0, y: -1.0), in: context, console: cons)

	return true
}

private func convert(point pt: CGPoint, in ctxt: CNGraphicsContext, console cons: CNConsole) {
	let ppt = ctxt.logicalToPhysical(point: pt)
	cons.print(string: "(\(pt.x), \(pt.y)) -> (\(ppt.x), \(ppt.y))\n")
}

