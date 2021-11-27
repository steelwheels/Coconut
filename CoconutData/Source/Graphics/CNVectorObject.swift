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

public class CNGripPoint
{
	public enum VerticalPosition {
		case top
		case middle
		case bottom
	}

	public enum HorizontalPosition {
		case left
		case center
		case right
	}

	public struct Position {
		var verticalPosition:	VerticalPosition
		var horizontalPosition:	HorizontalPosition

		public init(verticalPosition vpos: VerticalPosition, horizontalPosition hpos: HorizontalPosition){
			verticalPosition	= vpos
			horizontalPosition	= hpos
		}
	}

	private var mBezierPath: CNBezierPath?
	private var mPosition:   Position

	public init(){
		mBezierPath	= nil
		mPosition	= Position(verticalPosition: .middle, horizontalPosition: .center)
	}

	public var bezierPath: CNBezierPath?	{ get { return mBezierPath	}}
	public var position: Position		{ get { return mPosition	}}

	public func setBezierPath(bezierPath path: CNBezierPath){
		mBezierPath = path
	}

	public func setPosition(position pos: Position){
		mPosition = pos
	}

	public func contains(point pt: CGPoint) -> Bool {
		if let bezier = mBezierPath {
			return bezier.contains(pt)
		} else {
			return false
		}
	}

	public func clear(){
		if let bezier = mBezierPath {
			bezier.removeAllPoints()
		}
	}
}

open class CNVectorObject
{
	public var lineWidth:		CGFloat
	public var doFill:		Bool
	public var strokeColor:		CNColor
	public var fillColor:		CNColor

	private var mGripPoints:	Array<CNGripPoint>

	public init(lineWidth width: CGFloat, doFill fill: Bool, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		lineWidth	= width
		doFill		= fill
		strokeColor	= scolor
		fillColor	= fcolor
		mGripPoints	= []
	}

	public var gripPoints: Array<CNGripPoint> {
		get { return mGripPoints }
	}

	public func allocateGripPoint() -> CNGripPoint {
		let newpt = CNGripPoint()
		mGripPoints.append(newpt)
		return newpt
	}

	public func clearGripPoints() {
		mGripPoints = []
	}

	open func contains(point pt: CGPoint, in area: CGSize) -> Bool {
		NSLog("Must be override")
		return false
	}

	open func move(_ dx: CGFloat, _ dy: CGFloat) {
		NSLog("Must be override")
	}
}

public class CNPathObject: CNVectorObject
{
	private var mBezierPath: CNBezierPath?

	public override init(lineWidth width: CGFloat, doFill fill: Bool, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		mBezierPath = nil
		super.init(lineWidth: width, doFill: fill, strokeColor: scolor, fillColor: fcolor)
	}

	public var bezierPath: CNBezierPath? {
		get { return mBezierPath }
	}

	public func setBezierPath(bezierPath path: CNBezierPath){
		mBezierPath = path
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

	open override func move(_ dx: CGFloat, _ dy: CGFloat) {
		var newpoints: Array<CGPoint> = []
		for orgpt in mPoints {
			let newpt = CGPoint(x: orgpt.x + dx, y: orgpt.y + dy)
			newpoints.append(newpt)
		}
		mPoints = newpoints
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

	open override func move(_ dx: CGFloat, _ dy: CGFloat) {
		let neworign = CGPoint(x: originPoint.x + dx, y: originPoint.y + dy)
		let newend   = CGPoint(x: endPoint.x + dx, y: endPoint.y + dy)
		originPoint  = neworign
		endPoint     = newend
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

	public var radius: CGFloat { get {
		let dx: CGFloat = abs(endPoint.x - centerPoint.x)
		let dy: CGFloat = abs(endPoint.y - centerPoint.y)
		return sqrt(dx*dx + dy*dy)
	}}

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

	open override func move(_ dx: CGFloat, _ dy: CGFloat) {
		let newcenter = CGPoint(x: centerPoint.x + dx, y: centerPoint.y + dy)
		let newend    = CGPoint(x: endPoint.x + dx, y: endPoint.y + dy)
		centerPoint   = newcenter
		endPoint      = newend
	}
}

public class CNVectorString: CNVectorObject
{
	public var originPoint:		CGPoint
	public var frame:		CGRect
	public var string:		String
	public var font:		CNFont

	private var mAttributedString:	NSAttributedString?

	public init(lineWidth width: CGFloat, font fnt: CNFont, color col: CNColor) {
		originPoint 		= CGPoint.zero
		frame			= CGRect.zero
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
			return frame.contains(orgpt)
		} else {
			return false
		}
	}

	open override func move(_ dx: CGFloat, _ dy: CGFloat) {
		let neworigin = CGPoint(x: originPoint.x + dx, y: originPoint.y + dy)
		originPoint   = neworigin
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

	public var description: String { get {
		let result: String
		switch self {
		case .path(let dofill):
			result = "path(doFill:\(dofill))"
		case .rect(let dofill, let isrounded):
			result = "rect(doFill:\(dofill), isRounded:\(isrounded))"
		case .oval(let dofill):
			result = "oval(doFill:\(dofill))"
		case .string:
			result = "string"
		}
		return result
	}}
}


