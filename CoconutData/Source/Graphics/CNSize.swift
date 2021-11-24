/**
 * @file	CNSize.swift
 * @brief	Extend CGSize class
 * @par Copyright
 *   Copyright (C) 2016-2021 Steel Wheels Project
 */

import CoreGraphics
import Foundation

public extension CGSize
{
	var description: String {
		get {
			let wstr = NSString(format: "%.2lf", self.width)
			let hstr = NSString(format: "%.2lf", self.height)
			return "{width:\(wstr), height:\(hstr)}"
		}
	}
}

public func CNMaxSize(sizeA a: CGSize, sizeB b: CGSize) -> CGSize
{
	let width  = max(a.width,  b.width)
	let height = max(a.height, b.height)
	return CGSize(width: width, height: height)
}

public func CNMinSize(sizeA a: CGSize, sizeB b: CGSize) -> CGSize
{
	let width  = min(a.width,  b.width)
	let height = min(a.height, b.height)
	return CGSize(width: width, height: height)
}

public func CNExpandSize(size sz: CGSize, byInsets insets: CNEdgeInsets) -> CGSize {
	let width  = insets.left + sz.width  + insets.right
	let height = insets.top  + sz.height + insets.bottom
	return CGSize(width: width, height: height)
}

public func CNShrinkSize(size sz: CGSize, delta dlt: CGFloat) -> CGSize {
	let width  = max(sz.width  - dlt * 2.0, 0.0)
	let height = max(sz.height - dlt * 2.0, 0.0)
	return CGSize(width: width, height: height)
}

public func CNUnionSize(sizeA a: CGSize, sizeB b: CGSize, doVertical vert: Bool, spacing space: CGFloat) -> CGSize
{
	if vert {
		let width  = max(a.width, b.width)
		let height = a.height + b.height + space
		return CGSize(width: width, height: height)
	} else {
		let width  = a.width + b.width + space
		let height = max(a.height, b.height)
		return CGSize(width: width, height: height)
	}
}

