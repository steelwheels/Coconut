/*
 * @file	CNBitmapContext.swift
 * @brief	Define CNBitmapContext class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import Foundation

public class CNBitmapContext
{
	private var mPhysicalFrame:	CGRect
	private var mContents:		CNBitmapData

	public init() {
		mPhysicalFrame		= CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
		mContents		= CNBitmapData(width: 1, height: 1)
	}

	public var width:	Int		{ get { return mContents.width  }}
	public var height:	Int		{ get { return mContents.height }}
	public var data: 	CNBitmapData	{ get { return mContents	}}

	public func draw(context ctxt: CGContext, physicalFrame pframe: CGRect, width wdt: Int, height hgt: Int) {
		assert(wdt > 0 && hgt > 0, "Invalid parameter \(wdt)x\(hgt)")
		mPhysicalFrame	= pframe
		mContents.resize(width: wdt, height: hgt)

		/* Draw pixels */
		let pixsize = CGSize(width:  CGFloat(pframe.size.width  / CGFloat(wdt)),
				     height: CGFloat(pframe.size.height / CGFloat(hgt)))
		for y in 0..<hgt {
			for x in 0..<wdt {
				if let c = mContents.get(x: x, y: y) {
					drawElement(x: x, y: y, pixelSize: pixsize, color: c, context: ctxt)
				}
			}
		}

		/* Finish drawing */
		ctxt.strokePath()
	}

	private func drawElement(x x0: Int, y y0: Int, pixelSize pixsize: CGSize, color col: CNColor, context ctxt: CGContext) {
		let x   = pixsize.width  * CGFloat(x0)
		let y   = pixsize.height * CGFloat(y0)
		let rct = CGRect(x: x, y: y, width: pixsize.width, height: pixsize.height)
		ctxt.setFillColor(col.cgColor)
		ctxt.fill(rct)
	}

	public func set(x posx: Int, y posy: Int, color col: CNColor) {
		mContents.set(x: posx, y: posy, color: col)
	}

	public func set(x posx: Int, y posy: Int, bitmap bm: CNBitmapData){
		mContents.set(x: posx, y: posy, bitmap: bm)
	}

	public func clean() {
		mContents.clean()
	}

	public func get(x posx: Int, y posy: Int) -> CNColor? {
		return mContents.get(x: posx, y: posy)
	}

	public func toText() -> CNText {
		return mContents.toText()
	}
}

