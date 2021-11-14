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

private func normalizePoint(source src: CGPoint, in area: CGSize) -> CGPoint {
	let x = area.width  * src.x
	let y = area.height * src.y
	return CGPoint(x: x, y: y)
}

open class CNVectorObject
{
	public var lineWidth:		CGFloat
	public var doFill:		Bool
	public var strokeColor:		CNColor
	public var fillColor:		CNColor

	public init(lineWidth width: CGFloat, doFill fill: Bool, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		lineWidth	= width
		doFill		= fill
		strokeColor	= scolor
		fillColor	= fcolor
	}
}

public class CNVectorPath: CNVectorObject
{
	private var mPoints:	Array<CGPoint>

	public override init(lineWidth width: CGFloat, doFill fill: Bool, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		mPoints		= []
		super.init(lineWidth: width, doFill: fill, strokeColor: scolor, fillColor: fcolor)
	}

	public var points: Array<CGPoint> {
		get { return mPoints }
	}

	public func add(point pt: CGPoint){
		mPoints.append(pt)
	}

	public func normalize(in area: CGSize) -> Array<CGPoint> {
		var result: Array<CGPoint> = []
		for pt in mPoints {
			let p = normalizePoint(source: pt, in: area)
			result.append(p)
		}
		return result
	}
}

public class CNVectorRect: CNVectorObject
{
	public var originPoint:		CGPoint
	public var endPoint:		CGPoint
	public var isRounded:		Bool

	public init(lineWidth width: CGFloat, doFill fill: Bool, isRounded isrnd: Bool, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		originPoint	= CGPoint.zero
		endPoint	= CGPoint.zero
		isRounded	= isrnd
		super.init(lineWidth: width, doFill: fill, strokeColor: scolor, fillColor: fcolor)
	}

	public func normalize(in area: CGSize) -> CGRect? {
		let norigin = normalizePoint(source: originPoint, in: area)
		let nend    = normalizePoint(source: endPoint, in: area)
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

public class CNVectorString: CNVectorObject
{
	public var originPoint:		CGPoint
	public var string:		NSAttributedString
	private var mFont:		CNFont

	public init(lineWidth width: CGFloat, font fnt: CNFont, color col: CNColor) {
		originPoint = CGPoint.zero
		string 	    = NSAttributedString(string: "")
		mFont	    = fnt
		super.init(lineWidth: width, doFill: false, strokeColor: col, fillColor: CNColor.clear)
	}

	public var isEmpty: Bool {
		get { return string.string.isEmpty }
	}

	public func set(string str: String){
		let attrs: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.foregroundColor: strokeColor,
			NSAttributedString.Key.font:		mFont
		]
		string = NSAttributedString(string: str, attributes: attrs)
	}

	public func normalize(in area: CGSize) -> CGPoint? {
		return normalizePoint(source: originPoint, in: area)
	}
}

public enum CNVectorGraphics
{
	case path(CNVectorPath)
	case rect(CNVectorRect)
	case string(CNVectorString)
}

public enum CNVectorGraphicsType {
	case path(Bool)			// (doFill)
	case rect(Bool, Bool)		// (doFill, isRounded)
	case string			// (font)
}

public class CNVecroGraphicsGenerator
{
	private var mCurrentType:	CNVectorGraphicsType
	private var mGraphics:		Array<CNVectorGraphics>
	private var mLineWidth:		CGFloat
	private var mStrokeColor:	CNColor
	private var mFillColor:		CNColor
	private var mFont:		CNFont

	public init(){
		mCurrentType	= .path(false)
		mGraphics	= []
		mLineWidth	= 1.0
		mStrokeColor	= CNColor.black
		mFillColor	= CNColor.black
		mFont		= CNFont.systemFont(ofSize: CNFont.systemFontSize)
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
		case .path(let dofill):
			let newpath = CNVectorPath(lineWidth: mLineWidth, doFill: dofill, strokeColor: mStrokeColor, fillColor: mFillColor)
			newpath.add(point: convert(point: pt, in: area))
			mGraphics.append(.path(newpath))
		case .rect(let dofill, let isround):
			let newrect = CNVectorRect(lineWidth: mLineWidth, doFill: dofill, isRounded: isround, strokeColor: mStrokeColor, fillColor: mFillColor)
			newrect.originPoint = convert(point: pt, in: area)
			newrect.endPoint    = newrect.originPoint
			mGraphics.append(.rect(newrect))
		case .string:
			let origin = convert(point: pt, in: area)
			if let lastelm = mGraphics.last {
				switch lastelm {
				case .string(let vstr):
					vstr.originPoint = origin
				default:
					let newstr = CNVectorString(lineWidth: mLineWidth, font: mFont, color: mStrokeColor)
					newstr.originPoint = origin
					mGraphics.append(.string(newstr))
				}
			} else {
				let newstr = CNVectorString(lineWidth: mLineWidth, font: mFont, color: mStrokeColor)
				newstr.originPoint = origin
				mGraphics.append(.string(newstr))
			}
		}
	}

	public func addDrag(point pt: CGPoint, in area: CGSize){
		switch mCurrentType {
		case .path:
			addPath(point: pt, in: area)
		case .rect:
			addRect(point: pt, in: area)
		case .string:
			addString(point: pt, in: area)
		}
	}

	public func addUp(point pt: CGPoint, in area: CGSize){
		switch mCurrentType {
		case .path:
			addPath(point: pt, in: area)
		case .rect:
			addRect(point: pt, in: area)
		case .string:
			addString(point: pt, in: area)
		}
	}

	private func addPath(point pt: CGPoint, in area: CGSize){
		if let gr = mGraphics.last {
			switch gr {
			case .path(let path):
				path.add(point: convert(point: pt, in: area))
			case .rect(_), .string(_):
				CNLog(logLevel: .error, message: "Unexpected object", atFunction: #function, inFile: #file)
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		}
	}

	private func addRect(point pt: CGPoint, in area: CGSize){
		if let gr = mGraphics.last {
			switch gr {
			case .path(_), .string(_):
				CNLog(logLevel: .error, message: "Unexpected object", atFunction: #function, inFile: #file)
			case .rect(let rect):
				rect.endPoint = convert(point: pt, in: area)
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		}
	}

	private func addString(point pt: CGPoint, in area: CGSize){
		if let gr = mGraphics.last {
			switch gr {
			case .string(let str):
				str.originPoint = convert(point: pt, in: area)
			case .rect(_), .path(_):
				CNLog(logLevel: .error, message: "Unexpected object", atFunction: #function, inFile: #file)
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


