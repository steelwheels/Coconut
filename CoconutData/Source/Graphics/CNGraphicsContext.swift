/*
 * @file	CNGraphicsContext.swift
 * @brief	Define CNGraphicsContext class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import Foundation

public class CNGraphicsContext
{
	private var mCoreCotext:	CGContext?
	private var mLogicalFrame:	CGRect
	private var mPhysicalFrame:	CGRect

	private var mAffineMatrix:	CNMatrix3D

	public init() {
		mCoreCotext 	= nil
		mLogicalFrame	= CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
		mPhysicalFrame	= mLogicalFrame
		mAffineMatrix	= CNMatrix3D()
	}

	public var logicalFrame: CGRect { get { return mLogicalFrame }}

	public func begin(context ctxt: CGContext?, logicalFrame lframe: CGRect, physicalFrame pframe: CGRect) {
		mCoreCotext	= ctxt
		mLogicalFrame	= lframe
		mPhysicalFrame	= pframe
		updateAffineMatrix()
		if let c = ctxt {
			c.beginPath()
		}
	}

	private func updateAffineMatrix() {
		let x = mPhysicalFrame.size.width  / mLogicalFrame.size.width
		let y = mPhysicalFrame.size.height / mLogicalFrame.size.height
		mAffineMatrix = CNMatrix3D(scalars: [
			[x,   0.0, 0.0],
			[0.0, y,   0.0],
			[0.0, 0.0, 0.0]
		])
	}

	public func end() {
		if let ctxt = mCoreCotext {
			ctxt.strokePath()
		} else {
			NSLog("No context at \(#function)")
		}
	}

	public func setFillColor(color col: CGColor) {
		if let ctxt = mCoreCotext {
			ctxt.setFillColor(col)
		} else {
			NSLog("No context at \(#function)")
		}
	}

	public func setStrokeColor(color col: CGColor) {
		if let ctxt = mCoreCotext {
			ctxt.setStrokeColor(col)
		} else {
			NSLog("No context at \(#function)")
		}
	}

	public func setLineWidth(width val: CGFloat) {
		if let ctxt = mCoreCotext {
			let pwid = logicalToPhysical(width: val)
			//NSLog("width = \(pwid)")
			ctxt.setLineWidth(pwid)
		} else {
			NSLog("No context at \(#function)")
		}
	}

	public func move(to point: CGPoint) {
		if let ctxt = mCoreCotext {
			let ppt = logicalToPhysical(point: point)
			//NSLog("move = (\(point.x),\(point.y)) -> (\(ppt.x), \(ppt.y))")
			ctxt.move(to: ppt)
		}
	}

	public func line(to point: CGPoint) {
		if let ctxt = mCoreCotext {
			let ppt = logicalToPhysical(point: point)
			//NSLog("line = (\(point.x),\(point.y)) -> (\(ppt.x), \(ppt.y))")
			ctxt.addLine(to: ppt)
		}
	}

	public func circle(center pt: CGPoint, radius rad: CGFloat) {
		let pcenter = logicalToPhysical(point: pt)
		let psize   = logicalToPhysical(size: CGSize(width: rad, height: rad))
		let pbounds = CGRect(origin: pcenter, size: psize)
		if let ctxt = mCoreCotext {
			ctxt.addEllipse(in: pbounds)
		}
	}

	public func logicalToPhysical(point pt: CGPoint) -> CGPoint {
		let lvec = CNVector3D(scalars: [
			pt.x - mLogicalFrame.origin.x,
			pt.y - mLogicalFrame.origin.y,
			0.0
		])
		let pvec = mAffineMatrix * lvec
		let (rx, ry, _) = pvec.scalars
		return CGPoint(x: rx, y: ry)
	}

	public func logicalToPhysical(size sz: CGSize) -> CGSize {
		let width  = logicalToPhysical(width:  sz.width)
		let height = logicalToPhysical(height: sz.height)
		return CGSize(width: width, height: height)
	}

	public func logicalToPhysical(width val: CGFloat) -> CGFloat {
		return val  * mPhysicalFrame.size.width  / mLogicalFrame.size.width
	}

	public func logicalToPhysical(height val: CGFloat) -> CGFloat {
		return val  * mPhysicalFrame.size.height  / mLogicalFrame.size.height
	}
}
