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
	private var mCoreContext:	CGContext?
	private var mPhysicalFrame:	CGRect
	private var mWidth:		Int
	private var mHeight:		Int
	private var mPixelSize:		CGSize

	public init() {
		mCoreContext		= nil
		mPhysicalFrame		= CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
		mWidth			= 0
		mHeight			= 0
		mPixelSize		= CGSize(width: 1.0, height: 1.0)
	}

	public var width:  Int { get { return mWidth	}}
	public var height: Int { get { return mHeight	}}

	public func begin(context ctxt: CGContext?, physicalFrame pframe: CGRect, width wdt: Int, height hgt: Int) {
		assert(wdt > 0 && hgt > 0, "Invalid parameter \(wdt)x\(hgt)")
		mCoreContext	= ctxt
		mPhysicalFrame	= pframe
		mWidth		= wdt
		mHeight		= hgt
		mPixelSize	= CGSize(width:  CGFloat(pframe.size.width  / CGFloat(wdt)),
					 height: CGFloat(pframe.size.height / CGFloat(hgt)))
	}

	public func end() {
		if let ctxt = mCoreContext {
			ctxt.strokePath()
		} else {
			NSLog("No context at \(#function)")
		}
	}
	
	public func set(color col: CNColor) {
		if let ctxt = mCoreContext {
			ctxt.setFillColor(col.cgColor)
		} else {
			NSLog("No context at \(#function)")
		}
	}

	public func drawPoint(x x0: Int, y y0: Int) {
		let x   = mPixelSize.width  * CGFloat(x0)
		let y   = mPixelSize.height * CGFloat(y0)
		let rct = CGRect(x: x, y: y, width: mPixelSize.width, height: mPixelSize.height)
		if let ctxt = mCoreContext {
			ctxt.fill(rct)
		} else {
			NSLog("No context")
		}
	}

	public func drawRect(x x0: Int, y y0: Int, width wdt: Int, height hgt: Int) {
		let xorg   = mPixelSize.width  * CGFloat(x0)
		let yorg   = mPixelSize.height * CGFloat(y0)
		let width  = mPixelSize.width  * CGFloat(wdt)
		let height = mPixelSize.height * CGFloat(hgt) 
		let rct    = CGRect(x: xorg, y: yorg, width: width, height: height)
		if let ctxt = mCoreContext {
			ctxt.fill(rct)
		} else {
			NSLog("No context")
		}
	}

	public func drawData(x xp: Int, y yp: Int, bitmap bm: CNBitmapData){
		let xstart, xend, xoffset: Int
		if xp >= 0 {
			xoffset = 0
			xstart  = xp
			xend    = min(xp + bm.width, mWidth)
		} else { // xp < 0
			xoffset = -xp
			xstart  = 0
			xend    = min(xp + bm.width, mWidth)
		}
		let ystart, yend, yoffset: Int
		if yp >= 0 {
			yoffset = 0
			ystart  = yp
			yend    = min(yp + bm.height, mHeight)
		} else {
			yoffset = -xp
			ystart  = 0
			yend    = min(yp + bm.height, mHeight)
		}
		for x in xoffset..<xend {
			for y in yoffset..<yend {
				let c = bm.data[y][x]
				set(color: c)
				drawPoint(x: xstart + x, y: ystart + y)
			}
		}
	}
}

