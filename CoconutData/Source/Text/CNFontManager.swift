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
}

#endif

