/**
 * @file	CNColor.swift
 * @brief	Define CNColor class
 * @par Copyright
 *   Copyright (C) 2015-2018 Steel Wheels Project
 */

import CoconutData
import Foundation
import Darwin.ncurses

extension CNColor
{
	public func toDarwinColor() -> Int32 {
		var result: Int32
		switch self {
		case .Black:	result = Darwin.COLOR_BLACK
		case .Red:	result = Darwin.COLOR_RED
		case .Green:	result = Darwin.COLOR_GREEN
		case .Yellow:	result = Darwin.COLOR_YELLOW
		case .Blue:	result = Darwin.COLOR_BLUE
		case .Magenta:	result = Darwin.COLOR_MAGENTA
		case .Cyan:	result = Darwin.COLOR_CYAN
		case .White:	result = Darwin.COLOR_WHITE
		}
		return result
	}
}

