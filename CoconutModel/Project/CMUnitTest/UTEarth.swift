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
	let rspeed = CNEarthModel.rotationSpeed(longitude: degreeToRadian(degree: 35.39))
	cons.print(string: "[earth] orbital-speed:  \(ospeed) [km/s]\n")
	cons.print(string: "        rotation-speed: \(rspeed) [km/s]\n")
	return true
}

