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
	cons.print(string: "** testEarth\n")
	let ospeed  = CNEarthModel.orbitalSpeed()
	let rspeed0 = CNEarthModel.rotationSpeed(longitude: degreeToRadian(degree: CNJapanGeograpicLocations.Tokyo.longitude))
	let rspeed1 = CNEarthModel.rotationSpeed(longitude: 0.0)
	cons.print(string: "orbital-speed:  \(ospeed) [km/s]\n")
	cons.print(string: "rotation-speed: \(rspeed0) [km/s] at Tokyo \n")
	cons.print(string: "rotation-speed: \(rspeed1) [km/s] on Equator \n")
	return true
}

