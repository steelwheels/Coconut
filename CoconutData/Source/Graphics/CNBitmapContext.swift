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
	public typealias Color = CNColor.CursesColor

	private var mCoreContext:	CGContext?
	private var mPhysicalFrame:	CGRect
	private var mColorTable:	Dictionary<Color, CGColor>
	private var mWidth:		Int
	private var mHeight:		Int
	private var mPixelSize:		CGSize

	public init() {
		mCoreContext		= nil
		mPhysicalFrame		= CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
		mWidth			= 0
		mHeight			= 0
		mPixelSize		= CGSize(width: 1.0, height: 1.0)

		mColorTable = [
			Color.black:	CNColor.black.cgColor,
			Color.red:	CNColor.red.cgColor,
			Color.green:	CNColor.green.cgColor,
			Color.yellow:	CNColor.yellow.cgColor,
			Color.blue:	CNColor.blue.cgColor,
			Color.magenta:	CNColor.magenta.cgColor,
			Color.cyan:	CNColor.cyan.cgColor,
			Color.white:	CNColor.white.cgColor
		]
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
	
	public func set(color col: Color) {
		if let cgcol = mColorTable[col], let ctxt = mCoreContext {
			ctxt.setFillColor(cgcol)
		} else {
			NSLog("Unknown color at \(#function)")
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
}

