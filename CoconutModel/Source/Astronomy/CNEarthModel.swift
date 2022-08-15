/**
 * @file	CNEarthModel.swift
 * @brief	Define CNEarthModel class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNEarthModel
{
	/* Reference: https://en.wikipedia.org/wiki/Semi-major_and_semi-minor_axes */
	public static let	SemiMajorAxis : Double = 1.496e8	// [km]

	public static let	radius:		  Double = 6371.0	// [km] (Normalized)
	public static let	equatorialRadius: Double = 6378.16	// [km]
	public static let	polarRadius:      Double = 6356.775	// [km]

	public static func orbitalSpeed() -> Double {			// [km/sec]
		return 2.0 * Double.pi * CNEarthModel.SemiMajorAxis / CNYearModel.seconds()
	}

	public static func rotationSpeed(longitude lgt: Double) -> Double { // [km/sec]
		return (2.0 * Double.pi * CNEarthModel.radius * cos(lgt)) / CNDayModel.seconds()
	}
}


