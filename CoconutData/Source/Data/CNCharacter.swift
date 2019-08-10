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

	func toInt() -> UInt32? {
		if self.isNumber {
			return self.unicodeScalars.first!.value - Unicode.Scalar("0").value
		}
		return nil
	}

	func isAlphaOrNum() -> Bool {
		return self.isAlpha() || self.isNumber
	}
}
