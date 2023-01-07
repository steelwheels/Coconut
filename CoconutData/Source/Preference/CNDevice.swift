/**
 * @file	CNDevice.swift
 * @brief	Define CNDevice class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public enum CNDevice: Int, Comparable
{
	case mac
	case phone
	case ipad
	case tv
	case carPlay
	
	public static func device() -> CNDevice {
		let result: CNDevice
		#if os(OSX)
		result = .mac
		#else
		switch UIDevice.current.userInterfaceIdiom {
		case .mac:
			result = .mac
		case .pad:
			result = .ipad
		case .phone:
			result = .phone
		case .carPlay:
			result = .carPlay
		case .tv:
			result = .tv
		case .unspecified:
			NSLog("[Error] Unspecified device")
			result = .phone
		@unknown default:
			NSLog("[Error] Unknown device")
			result = .phone
		}
		#endif
		return result
	}
	
	public static func < (lhs: CNDevice, rhs: CNDevice) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
	
	public static func > (lhs: CNDevice, rhs: CNDevice) -> Bool {
		return lhs.rawValue > rhs.rawValue
	}
	
	public static func == (lhs: CNDevice, rhs: CNDevice) -> Bool {
		return lhs.rawValue == rhs.rawValue
	}
	
	public static func != (lhs: CNDevice, rhs: CNDevice) -> Bool {
		return lhs.rawValue != rhs.rawValue
	}
}

