/*
 * @file	UTEarth.swift
 * @brief	Unit test for earth model in CoconutModel framework
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */


import CoconutData
import CoconutModel
import Foundation

public func testEarth(console cons: CNConsole) -> Bool
{
	let ospeed = CNEarthModel.orbitalSpeed()
	cons.print(string: "[earth] orbital-speed: \(ospeed)\n")
	return true
}

