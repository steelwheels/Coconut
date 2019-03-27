/**
 * @file	CNCharacter.h
 * @brief	Extend character class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public extension Character {
	func isSpace() -> Bool {
		let result: Bool
		switch self {
		case " ", "\t", "\n", "\r":
			result = true
		default:
			result = false
		}
		return result
	}

	func isAlpha() -> Bool {
		return ("a"<=self && self<="z") || ("A"<=self && self<="Z")
	}

	func isDigit() -> Bool {
		return ("0"<=self && self<="9")
	}

	func isHex() -> Bool {
		return ("0"<=self && self<="9") || ("a"<=self && self<="f") || ("A"<=self && self<="F")
	}

	func isAlphaOrNum() -> Bool {
		return isAlpha() || isDigit()
	}
}
