/**
 * @file	CNFontManager.h
 * @brief	Define CNFontManager class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

#if os(OSX)
import Cocoa
#else
import UIKit
#endif

#if os(OSX)

public typealias CNFontManager = NSFontManager

extension CNFontManager
{
	public var availableFixedPitchFonts: Array<String> {
		get {
			if let names = self.availableFontNames(with: .fixedPitchFontMask) {
				return names
			} else {
				return []
			}
		}
	}
}

#else

public class CNFontManager
{
	public static let shared = CNFontManager()

	private init() {
		
	}

	public var availableFonts: Array<String> {
		get {
			var result: Array<String> = []
			let families = UIFont.familyNames
			for family in families {
				let names = UIFont.fontNames(forFamilyName: family)
				result.append(contentsOf: names)
			}
			return result
		}
	}

	public var availableFixedPitchFonts: Array<String> {
		get {
			/* Reference: https://stackoverflow.com/questions/9962994/what-is-a-monospace-font-in-ios/12592984 */
			let result: Array<String> = [
				"Courier",
				"Courier-Bold",
				"Courier-BoldOblique",
				"Courier-Oblique",
				"CourierNewPS-BoldItalicMT",
				"CourierNewPS-BoldMT",
				"CourierNewPS-ItalicMT",
				"CourierNewPSMT",
				"Menlo-Bold",
				"Menlo-BoldItalic",
				"Menlo-Italic",
				"Menlo-Regular"
			]
			return result
		}
	}
}

#endif

