/*
 * @file	CNBezierPath.swift
 * @brief	Define CNBezierPath class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import Foundation

public class CNVectorPath
{
	private var mLineWidth:	CGFloat
	private var mPoints:	Array<CGPoint>

	public init(lineWidth width: CGFloat){
		mLineWidth	= width
		mPoints		= []
	}

	public var width: CGFloat {
		get { return mLineWidth }
	}

	public var points: Array<CGPoint> {
		get { return mPoints }
	}

	public func add(point pt: CGPoint){
		mPoints.append(pt)
	}

	public func points(inRect rect: CGRect) -> Array<CGPoint> {
		let origin = rect.origin
		let size   = rect.size
		var result: Array<CGPoint> = []
		for pt in mPoints {
			let x = origin.x + (size.width  * pt.x)
			let y = origin.y + (size.height * pt.y)
			let p = CGPoint(x: x, y: y)
			result.append(p)
		}
		return result
	}
}

public enum CNVectorGraphics
{
	case path(CNVectorPath)
}

public class CNVecroGraphicsGenerator
{
	private var mGraphics:	Array<CNVectorGraphics>
	private var mLineWidth:	CGFloat
	public init(){
		mGraphics	= []
		mLineWidth	= 1.0
	}

	public var contents: Array<CNVectorGraphics> { get { return mGraphics }}

	public func addDown(point pt: CGPoint, in area: CGSize) {
		let newpath = CNVectorPath(lineWidth: mLineWidth)
		newpath.add(point: convert(point: pt, in: area))
		mGraphics.append(.path(newpath))
	}

	public func addDrag(point pt: CGPoint, in area: CGSize){
		addPoint(point: pt, in: area)
	}

	public func addUp(point pt: CGPoint, in area: CGSize){
		addPoint(point: pt, in: area)
	}

	public var lineWidth: CGFloat {
		get	    { return mLineWidth }
		set(newval) { mLineWidth = newval }
	}

	public func setLineWidth(width wid: CGFloat) {
		mLineWidth = wid
	}

	private func addPoint(point pt: CGPoint, in area: CGSize){
		if let gr = mGraphics.last {
			switch gr {
			case .path(let path):
				path.add(point: convert(point: pt, in: area))
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		}
	}

	private func convert(point pt: CGPoint, in area: CGSize) -> CGPoint {
		guard area.width > 0.0 && area.height > 0.0 else {
			CNLog(logLevel: .error, message: "Can not accept empty frame", atFunction: #function, inFile: #file)
			return CGPoint.zero
		}
		let x = pt.x / area.width
		let y = pt.y / area.height
		return CGPoint(x: x, y: y)
	}
}


