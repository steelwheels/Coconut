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

	open func contains(point pt: CGPoint, in area: CGSize) -> Bool {
		NSLog("Must be override")
		return false
	}
}

public class CNPathObject: CNVectorObject
{
	private var mBezierPath: CNBezierPath?

	public override init(lineWidth width: CGFloat, doFill fill: Bool, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		mBezierPath = nil
		super.init(lineWidth: width, doFill: fill, strokeColor: scolor, fillColor: fcolor)
	}

	public func allocateBezierPath() -> CNBezierPath {
		let bezier = CNBezierPath()
		bezier.lineWidth     = self.lineWidth
		bezier.lineJoinStyle = .round
		bezier.lineCapStyle  = .round
		self.fillColor.setFill()
		self.strokeColor.setStroke()
		mBezierPath = bezier
		return bezier
	}

	public override func contains(point pt: CGPoint, in area: CGSize) -> Bool {
		if let path = mBezierPath {
			return path.contains(pt)
		} else {
			return false
		}
	}
}

public class CNVectorPath: CNPathObject
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

public class CNVectorRect: CNPathObject
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

public class CNVectorOval: CNPathObject
{
	public var centerPoint:		CGPoint
	public var endPoint:		CGPoint

	public override init(lineWidth width: CGFloat, doFill fill: Bool, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		centerPoint	= CGPoint.zero
		endPoint	= CGPoint.zero
		super.init(lineWidth: width, doFill: fill, strokeColor: scolor, fillColor: fcolor)
	}

	public func normalize(in area: CGSize) -> (CGPoint, CGFloat)? { // (center, radius)
		let ncenter = normalizePoint(source: centerPoint, in: area)
		let nend    = normalizePoint(source: endPoint, in: area)

		let diffx   = ncenter.x - nend.x
		let diffy   = ncenter.y - nend.y
		let radius  = sqrt(diffx * diffx + diffy * diffy)

		if radius > 0.0 {
			return (ncenter, radius)
		} else {
			return nil
		}
	}
}

public class CNVectorString: CNVectorObject
{
	public var originPoint:		CGPoint
	public var string:		String
	public var font:		CNFont

	private var mAttributedString:	NSAttributedString?

	public init(lineWidth width: CGFloat, font fnt: CNFont, color col: CNColor) {
		originPoint 		= CGPoint.zero
		string 	   		= ""
		font	    		= fnt
		mAttributedString	= nil
		super.init(lineWidth: width, doFill: false, strokeColor: col, fillColor: CNColor.clear)
	}

	public var isEmpty: Bool {
		get { return self.string.isEmpty }
	}

	public func normalize(in area: CGSize) -> CGPoint? {
		return normalizePoint(source: originPoint, in: area)
	}

	public func attributedString() -> NSAttributedString {
		let attrs: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.foregroundColor: self.strokeColor,
			NSAttributedString.Key.backgroundColor:	CNColor.clear,
			NSAttributedString.Key.font:		self.font
		]
		let astr = NSAttributedString(string: self.string, attributes: attrs)
		mAttributedString = astr
		return astr
	}

	public override func contains(point pt: CGPoint, in area: CGSize) -> Bool {
		if let orgpt = normalize(in: area) {
			let x0 = orgpt.x ; let x1 = orgpt.x + area.width
			let y0 = orgpt.y ; let y1 = orgpt.y + area.height
			if x0<=pt.x && pt.x<x1 && y0<=pt.y && pt.y<y1 {
				return true
			} else {
				return false
			}
		} else {
			return false
		}
	}
}

public enum CNVectorGraphics
{
	case path(CNVectorPath)
	case rect(CNVectorRect)
	case oval(CNVectorOval)
	case string(CNVectorString)
}

public enum CNVectorGraphicsType {
	case path(Bool)			// (doFill)
	case rect(Bool, Bool)		// (doFill, isRounded)
	case oval(Bool)			// (doFill)
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

	public func loadString() -> String? {
		var result: String? = nil
		if let gr = mGraphics.last {
			switch gr {
			case .path(_), .rect(_), .oval(_):
				result = nil
			case .string(let vstr):
				result = vstr.string
			}
		}
		return result
	}

	public func storeString(string str: String) {
		if let gr = mGraphics.last {
			switch gr {
			case .path(_), .rect(_), .oval(_):
				break
			case .string(let vstr):
				vstr.string = str
			}
		}
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
		case .oval(let dofill):
			let newoval = CNVectorOval(lineWidth: mLineWidth, doFill: dofill, strokeColor: mStrokeColor, fillColor: mFillColor)
			newoval.centerPoint = convert(point: pt, in: area)
			newoval.endPoint    = newoval.centerPoint
			mGraphics.append(.oval(newoval))
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
		addEndPoint(point: pt, in: area)
	}

	public func addUp(point pt: CGPoint, in area: CGSize){
		addEndPoint(point: pt, in: area)
	}

	private func addEndPoint(point pt: CGPoint, in area: CGSize){
		if let gr = mGraphics.last {
			let cpt = convert(point: pt, in: area)
			switch gr {
			case .path(let path):
				path.add(point: cpt)
			case .rect(let rect):
				rect.endPoint = cpt
			case .string(let vstr):
				vstr.originPoint = cpt
			case .oval(let oval):
				oval.endPoint = cpt
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


