/**
 * @file	CNColor.swift
 * @brief	Define CNColor class
 * @par Copyright
 *   Copyright (C) 2015-2016 Steel Wheels Project
 */

import Foundation

public enum CNColor: Int32 {
	case Black	= 0
	case Red	= 1
	case Green	= 2
	case Yellow	= 3
	case Blue	= 4
	case Magenta	= 5
	case Cyan	= 6
	case White	= 7

	public static let Min: CNColor = CNColor.Black
	public static let Max: CNColor = CNColor.White

	public func description() -> String {
		let result: String
		switch self {
		case .Black:	result = "Black"
		case .Red:	result = "Red"
		case .Green:	result = "Green"
		case .Yellow:	result = "Yellow"
		case .Blue:	result = "Blue"
		case .Magenta:	result = "Magenta"
		case .Cyan:	result = "Cyan"
		case .White:	result = "White"
		}
		return result
	}
}

