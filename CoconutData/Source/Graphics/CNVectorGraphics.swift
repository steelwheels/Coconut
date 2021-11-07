/*
 * @file	CNVectorGraphics.swift
 * @brief	Define CNVectorGraphics class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import Foundation

private func normalizePoint(source src: CGPoint, in rect: CGRect) -> CGPoint {
	let origin = rect.origin
	let size   = rect.size
	let x = origin.x + (size.width  * src.x)
	let y = origin.y + (size.height * src.y)
	return CGPoint(x: x, y: y)
}

open class CNVectorObject
{
	public var lineWidth:		CGFloat
	public var strokeColor:		CNColor
	public var fillColor:		CNColor

	public init(lineWidth width: CGFloat, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		lineWidth	= width
		strokeColor	= scolor
		fillColor	= fcolor
	}
}

public class CNVectorPath: CNVectorObject
{
	private var mPoints:	Array<CGPoint>

	public override init(lineWidth width: CGFloat, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		mPoints		= []
		super.init(lineWidth: width, strokeColor: scolor, fillColor: fcolor)
	}

	public var points: Array<CGPoint> {
		get { return mPoints }
	}

	public func add(point pt: CGPoint){
		mPoints.append(pt)
	}

	public func normalize(inRect rect: CGRect) -> Array<CGPoint> {
		var result: Array<CGPoint> = []
		for pt in mPoints {
			let p = normalizePoint(source: pt, in: rect)
			result.append(p)
		}
		return result
	}
}

public class CNVectorRect: CNVectorObject
{
	public var originPoint:		CGPoint
	public var endPoint:		CGPoint

	public override init(lineWidth width: CGFloat, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		originPoint	= CGPoint.zero
		endPoint	= CGPoint.zero
		super.init(lineWidth: width, strokeColor: scolor, fillColor: fcolor)
	}

	public func normalize(inRect rect: CGRect) -> CGRect? {
		let norigin = normalizePoint(source: originPoint, in: rect)
		let nend    = normalizePoint(source: endPoint, in: rect)
		let x = min(norigin.x, nend.x)
		let y = min(norigin.y, nend.y)
		let width  = abs(nend.x - norigin.x)
		let height = abs(nend.y - norigin.y)
		if width > 0 && height > 0 {
			return CGRect(x: x, y: y, width: width, height: height)
		} else {
			return nil
		}
	}
}

public enum CNVectorGraphics
{
	case path(CNVectorPath)
	case rect(CNVectorRect)
}

public enum CNVectorGraphicsType {
	case path
	case rect
}

public class CNVecroGraphicsGenerator
{
	private var mCurrentType:	CNVectorGraphicsType
	private var mGraphics:		Array<CNVectorGraphics>
	private var mLineWidth:		CGFloat
	private var mStrokeColor:	CNColor
	private var mFillColor:		CNColor

	public init(type typ: CNVectorGraphicsType){
		mCurrentType	= typ
		mGraphics	= []
		mLineWidth	= 1.0
		mStrokeColor	= CNColor.black
		mFillColor	= CNColor.black
	}

	public var contents: Array<CNVectorGraphics> { get { return mGraphics }}

	public var currentType: CNVectorGraphicsType {
		get 	    { return mCurrentType	}
		set(newval) { mCurrentType = newval	}
	}

	public var lineWidth: CGFloat {
		get	    { return mLineWidth }
		set(newval) { mLineWidth = newval }
	}

	public var strokeColor: CNColor {
		get         { return mStrokeColor }
		set(newval) { mStrokeColor = newval }
	}

	public var fillColor: CNColor {
		get         { return mFillColor }
		set(newval) { mFillColor = newval }
	}

	public func addDown(point pt: CGPoint, in area: CGSize) {
		switch mCurrentType {
		case .path:
			let newpath = CNVectorPath(lineWidth: mLineWidth, strokeColor: mStrokeColor, fillColor: mFillColor)
			newpath.add(point: convert(point: pt, in: area))
			mGraphics.append(.path(newpath))
		case .rect:
			let newrect = CNVectorRect(lineWidth: mLineWidth, strokeColor: mStrokeColor, fillColor: mFillColor)
			newrect.originPoint = convert(point: pt, in: area)
			newrect.endPoint    = newrect.originPoint
			mGraphics.append(.rect(newrect))
		}
	}

	public func addDrag(point pt: CGPoint, in area: CGSize){
		switch mCurrentType {
		case .path:
			addPath(point: pt, in: area)
		case .rect:
			addRect(point: pt, in: area)
		}
	}

	public func addUp(point pt: CGPoint, in area: CGSize){
		switch mCurrentType {
		case .path:
			addPath(point: pt, in: area)
		case .rect:
			addRect(point: pt, in: area)
		}
	}

	private func addPath(point pt: CGPoint, in area: CGSize){
		if let gr = mGraphics.last {
			switch gr {
			case .path(let path):
				path.add(point: convert(point: pt, in: area))
			case .rect(_):
				CNLog(logLevel: .error, message: "Unexpected object", atFunction: #function, inFile: #file)
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		}
	}

	private func addRect(point pt: CGPoint, in area: CGSize){
		if let gr = mGraphics.last {
			switch gr {
			case .path(_):
				CNLog(logLevel: .error, message: "Unexpected object", atFunction: #function, inFile: #file)
			case .rect(let rect):
				rect.endPoint = convert(point: pt, in: area)
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


