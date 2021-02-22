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
	private var mContents:		CNBitmapContents

	public init() {
		mCoreContext		= nil
		mPhysicalFrame		= CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
		mWidth			= 0
		mHeight			= 0
		mPixelSize		= CGSize(width: 1.0, height: 1.0)
		mContents		= CNBitmapContents(width: 1, height: 1)
	}

	public var width:       Int 		{ get { return mWidth	   }}
	public var height:      Int 		{ get { return mHeight	   }}

	public func begin(context ctxt: CGContext?, physicalFrame pframe: CGRect, width wdt: Int, height hgt: Int) {
		assert(wdt > 0 && hgt > 0, "Invalid parameter \(wdt)x\(hgt)")
		mCoreContext	= ctxt
		mPhysicalFrame	= pframe
		mWidth		= wdt
		mHeight		= hgt
		mPixelSize	= CGSize(width:  CGFloat(pframe.size.width  / CGFloat(wdt)),
					 height: CGFloat(pframe.size.height / CGFloat(hgt)))
		mContents.resize(width: wdt, height: hgt)
	}

	public func end() {
		if let ctxt = mCoreContext {
			self.draw()
			ctxt.strokePath()
		} else {
			NSLog("No context at \(#function)")
		}
	}

	private func draw(){
		let width  = mContents.width
		let height = mContents.height
		for y in 0..<height {
			for x in 0..<width {
				let c = mContents.data[y][x]
				draw(x: x, y: y, color: c)
			}
		}
	}

	private func draw(x x0: Int, y y0: Int, color col: CNColor) {
		let x   = mPixelSize.width  * CGFloat(x0)
		let y   = mPixelSize.height * CGFloat(y0)
		let rct = CGRect(x: x, y: y, width: mPixelSize.width, height: mPixelSize.height)
		if let ctxt = mCoreContext {
			ctxt.setFillColor(col.cgColor)
			ctxt.fill(rct)
		} else {
			NSLog("No context")
		}
	}

	public func set(x posx: Int, y posy: Int, color col: CNColor) {
		mContents.set(x: posx, y: posy, color: col)
	}

	public func set(x posx: Int, y posy: Int, bitmap data: Array<Array<CNColor>>){
		mContents.set(x: posx, y: posy, bitmap: data)
	}

	public func clear() {
		mContents.clear()
	}

	public func get(x posx: Int, y posy: Int) -> CNColor? {
		return mContents.get(x: posx, y: posy)
	}

	public func toText() -> CNText {
		return mContents.toText()
	}
}

