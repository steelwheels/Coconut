/*
 * @file	CNGraphics.swift
 * @brief	Define data type for graphics
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNAlignment: Int32 {
	case Left
	case Center
	case Right

	case Top
	case Middle
	case Bottom

	public var isVertical: Bool {
		get {
			let result: Bool
			switch self {
			case .Left, .Center, .Right:
				result = false
			case .Top, .Middle, .Bottom:
				result = true
			}
			return result
		}
	}

	public init(nsTextAlignment align: NSTextAlignment) {
		switch align {
		case .left:	self = .Left
		case .center:	self = .Center
		case .right:	self = .Right
		default:	self = .Left
		}
	}

	public func toNSTextAlignment() -> NSTextAlignment {
		let result: NSTextAlignment
		switch self {
		case .Left,   .Top:		result = .left
		case .Center, .Middle:		result = .center
		case .Right,  .Bottom:		result = .right
		}
		return result
	}
}

