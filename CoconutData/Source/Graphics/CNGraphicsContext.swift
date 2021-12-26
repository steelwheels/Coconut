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
	private var mCoreContext:	CGContext?
	private var mLogicalFrame:	CGRect
	private var mPhysicalFrame:	CGRect

	private var mAffineMatrix:	CNMatrix3D

	public init() {
		mCoreContext 	= nil
		mLogicalFrame	= CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
		mPhysicalFrame	= mLogicalFrame
		mAffineMatrix	= CNMatrix3D()
	}

	public var logicalFrame: CGRect { get { return mLogicalFrame }}

	public func begin(context ctxt: CGContext?, logicalFrame lframe: CGRect, physicalFrame pframe: CGRect) {
		mCoreContext	= ctxt
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
		if let ctxt = mCoreContext {
			ctxt.strokePath()
		} else {
			CNLog(logLevel: .error, message: "No context", atFunction: #function, inFile: #file)
		}
	}

	public func setFillColor(color col: CNColor) {
		if let ctxt = mCoreContext {
			ctxt.setFillColor(col.cgColor)
		} else {
			CNLog(logLevel: .error, message: "No context", atFunction: #function, inFile: #file)
		}
	}

	public func setStrokeColor(color col: CNColor) {
		if let ctxt = mCoreContext {
			ctxt.setStrokeColor(col.cgColor)
		} else {
			CNLog(logLevel: .error, message: "No context", atFunction: #function, inFile: #file)
		}
	}

	public func setPenSize(width val: CGFloat) {
		if let ctxt = mCoreContext {
			let pwid = logicalToPhysical(width: val)
			ctxt.setLineWidth(pwid)
		} else {
			CNLog(logLevel: .error, message: "No context", atFunction: #function, inFile: #file)
		}
	}

	public func move(to point: CGPoint) {
		if let ctxt = mCoreContext {
			let ppt = logicalToPhysical(point: point)
			ctxt.move(to: ppt)
		}
	}

	public func line(to point: CGPoint) {
		if let ctxt = mCoreContext {
			let ppt = logicalToPhysical(point: point)
			ctxt.addLine(to: ppt)
		}
	}

	public func rect(rect rct: CGRect, doFill fill: Bool) {
		if let ctxt = mCoreContext {
			let prct = logicalToPhysical(rect: rct)
			if fill {
				ctxt.fill(prct)
			} else {
				ctxt.addRect(prct)
			}
		}
	}

	public func circle(center pt: CGPoint, radius rad: CGFloat, doFill fill: Bool) {
		let pcenter = logicalToPhysical(point: pt)
		let psize   = logicalToPhysical(size: CGSize(width: rad, height: rad))
		let pbounds = CGRect(origin: pcenter, size: psize)
		if let ctxt = mCoreContext {
			if fill {
				ctxt.fillEllipse(in: pbounds)
			} else {
				ctxt.addEllipse(in: pbounds)
			}
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

	private func logicalToPhysical(size sz: CGSize) -> CGSize {
		let width  = logicalToPhysical(width:  sz.width)
		let height = logicalToPhysical(height: sz.height)
		return CGSize(width: width, height: height)
	}

	private func logicalToPhysical(rect rct: CGRect) -> CGRect {
		let neworg  = logicalToPhysical(point: rct.origin)
		let newsize = logicalToPhysical(size:  rct.size)
		return CGRect(origin: neworg, size: newsize)
	}

	private func logicalToPhysical(width val: CGFloat) -> CGFloat {
		return val  * mPhysicalFrame.size.width  / mLogicalFrame.size.width
	}

	private func logicalToPhysical(height val: CGFloat) -> CGFloat {
		return val  * mPhysicalFrame.size.height  / mLogicalFrame.size.height
	}
}
