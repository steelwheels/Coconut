/**
 * @file	CNCharacter.h
 * @brief	Extend character class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public extension Character
{
	var isLetterOrNumber: Bool {
		get { return self.isLetter || self.isNumber }
	}

	func toInt() -> UInt32? {
		if self.isNumber {
			return self.unicodeScalars.first!.value - Unicode.Scalar("0").value
		}
		return nil
	}
}
