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
	static let ClassName = "Image"

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

	func toValue() -> CNStruct {
		let stype: CNStructType
		if let typ = CNStructTable.currentStructTable().search(byTypeName: CNImage.ClassName) {
			stype = typ
		} else {
			stype = CNStructType(typeName: "dummy")
		}
		let values: Dictionary<String, CNValue> = [
			"size":		.structValue(self.size.toValue())
		]
		return CNStruct(type: stype, values: values)
	}
}

#if os(OSX)
extension NSImage
{
	/* https://stackoverflow.com/questions/11949250/how-to-resize-nsimage */
	public func resize(to _size: NSSize) -> NSImage? {
		let targetsize = self.size.resizeWithKeepingAscpect(inSize: _size)

		if let bitmapRep = NSBitmapImageRep(
		    bitmapDataPlanes: nil, pixelsWide: Int(targetsize.width), pixelsHigh: Int(targetsize.height),
		    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
		    colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
		) {
		    bitmapRep.size = targetsize
		    NSGraphicsContext.saveGraphicsState()
		    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
		    draw(in: NSRect(x: 0, y: 0, width: targetsize.width, height: targetsize.height), from: .zero, operation: .copy, fraction: 1.0)
		    NSGraphicsContext.restoreGraphicsState()

		    let resizedImage = NSImage(size: targetsize)
		    resizedImage.addRepresentation(bitmapRep)
		    return resizedImage
		}
	    return nil
	}
}
#endif

#if os(iOS)
extension UIImage
{
	public func resize(to _size: CGSize) -> UIImage? {
		/* Copied from https://develop.hateblo.jp/entry/iosapp-uiimage-resize */

		let targetsize = self.size.resizeWithKeepingAscpect(inSize: _size)
		UIGraphicsBeginImageContextWithOptions(targetsize, false, 0.0)
		draw(in: CGRect(origin: .zero, size: targetsize))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return resizedImage
	}
}
#endif

