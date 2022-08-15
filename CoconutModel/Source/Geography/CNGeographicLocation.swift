/**
 * @file	CNGeographicsLocation.swift
 * @brief	Define CNGeographicLocation  class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public struct CNGeographicLocation
{
	public var	latitude:	Double		// [degree]
	public var 	longitude:	Double		// [degree]

	public init(latitude lat: Double, longitude lng: Double){
		latitude	= lat
		longitude	= lng
	}

	// unit: [deg, minute, second] -> deg
	static func normalize(degree deg: Double, minutes min: Double, seconds sec: Double) -> Double {
		return deg + (min / 60.0) + (sec / (60.0 * 60.0))
	}
}

public class CNJapanGeograpicLocations
{
	public static let Tokyo = CNGeographicLocation(latitude:  CNGeographicLocation.normalize(degree: 139, minutes: 41, seconds: 30),
						       longitude: CNGeographicLocation.normalize(degree:  35, minutes: 41, seconds: 22))
}
