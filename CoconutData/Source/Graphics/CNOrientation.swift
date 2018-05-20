/**
 * @file	CNOrientation.swift
 * @brief	Define CNOrientation type
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNOrientation: Int32 {
	case Horizontal			= 0
	case Vertical			= 1

	public var description: String {
		get {
			let result: String
			switch self {
			case .Horizontal: result = "horizontal"
			case .Vertical:   result = "vertical"
			}
			return result
		}
	}
}
