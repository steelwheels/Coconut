/**
 * @file	CNTimeModel.swift
 * @brief	Define CNYearModel  class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNYearModel
{
	public static let days : Double = 365.242194	// day

	public static func seconds() -> Double {
		return CNDayModel.seconds() * CNYearModel.days
	}
}

public class CNDayModel
{
	public static let hours : Double = 24.0		// hour

	public static func seconds() -> Double {	// second
		return 86164 // 23hour, 56 minutes 54 seconds
	}
}
