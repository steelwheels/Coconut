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

#else

public class CNFontManager
{
	public static let shared = CNFontManager()

	private init() {

	}
}

#endif

extension CNFontManager
{
	#if os(iOS)
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
	#endif

	#if os(OSX)
	public var availableFixedPitchFonts: Array<String> {
		get {
			if let names = self.availableFontNames(with: .fixedPitchFontMask) {
				return names
			} else {
				return []
			}
		}
	}
	#else
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
	#endif

	public func convert(font fnt: CNFont, format fmt: CNStringFormat) -> CNFont {
		#if os(OSX)
			var trait = NSFontTraitMask(rawValue: 0)
			if fmt.doBold {
				trait = NSFontTraitMask(rawValue: trait.rawValue | NSFontTraitMask.boldFontMask.rawValue)
			}
			if fmt.doItalic {
				trait = NSFontTraitMask(rawValue: trait.rawValue | NSFontTraitMask.italicFontMask.rawValue)
			}
			return self.convert(fnt, toHaveTrait: trait)
		#else
			var trait: UInt32 = 0
			if fmt.doBold {
				trait |= UIFontDescriptor.SymbolicTraits.traitBold.rawValue
			}
			if fmt.doItalic {
				trait |= UIFontDescriptor.SymbolicTraits.traitItalic.rawValue
			}
			if let desc = fnt.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(rawValue: trait)) {
				return UIFont(descriptor: desc, size: fnt.pointSize)
			} else {
				NSLog("Failed to convert")
				return fnt
			}
		#endif
	}
}

