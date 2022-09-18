/*
 * @file	CNImage.swift
 * @brief	Extend CNImage class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

public extension CNImage
{
	private static let ClassName = "Image"

	#if os(OSX)
	func pngData() -> Data? {
		if let cgimg = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
			let repl  = NSBitmapImageRep(cgImage: cgimg)
			return repl.representation(using: .png, properties: [:])
		} else {
			return nil
		}
	}
	#endif

	#if os(iOS)
	convenience init?(contentsOf url: URL) {
		self.init(contentsOfFile: url.path)
	}
	#endif

	func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"class":	.stringValue(CNImage.ClassName),
			"size":		.dictionaryValue(self.size.toValue())
		]
		return result
	}
}

