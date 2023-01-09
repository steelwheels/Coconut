/*
 * @file	CNVectorGraphics.swift
 * @brief	Define CNVectorGraphics class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 * @par reference
 *   https://developer.mozilla.org/ja/docs/Web/SVG	(Japanese)
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import Foundation

private func floatToValue(value val: CGFloat) -> CNValue {
	let num = NSNumber(floatLiteral: Double(val))
	return CNValue.numberValue(num)
}

private func boolToValue(value val: Bool) -> CNValue {
	let num = NSNumber(booleanLiteral: val)
	return CNValue.numberValue(num)
}

private func floatInDictionary(dictionary dict: Dictionary<String, CNValue>, forKey key: String) -> CGFloat? {
	if let val = dict[key] {
		if let num = val.toNumber() {
			return CGFloat(num.doubleValue)
		}
	}
	return nil
}

private func boolInDictionary(dictionary dict: Dictionary<String, CNValue>, forKey key: String) -> Bool? {
	if let val = dict[key] {
		if let num = val.toNumber() {
			return num.boolValue
		}
	}
	return nil
}

private func pointInDictionary(dictionary dict: Dictionary<String, CNValue>, forKey key: String) -> CGPoint? {
	if let val = dict[key] {
		switch val {
		case .interfaceValue(let ifval):
			return CGPoint.fromValue(value: ifval)
		default:
			break
		}
	}
	return nil
}

private func sizeInDictionary(dictionary dict: Dictionary<String, CNValue>, forKey key: String) -> CGSize? {
	if let val = dict[key] {
		switch val {
		case .interfaceValue(let ifval):
			return CGSize.fromValue(value: ifval)
		default:
			break
		}
	}
	return nil
}

private func objectInDictionary(dictionary dict: Dictionary<String, CNValue>, forKey key: String) -> AnyObject? {
	if let val = dict[key] {
		switch val {
		case .objectValue(let obj):
			return obj
		default:
			break
		}
	}
	return nil
}

public class CNGripPoint
{
	private var mBezierPath: CNBezierPath?
	private var mPosition:   CNPosition

	public init(){
		mBezierPath	= nil
		mPosition	= CNPosition(horizontal: .center, vertical: .middle)
	}

	public var bezierPath: CNBezierPath?	{ get { return mBezierPath	}}
	public var position:   CNPosition       { get { return mPosition	}}

	public func setBezierPath(bezierPath path: CNBezierPath){
		mBezierPath = path
	}

	public func setPosition(position pos: CNPosition){
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

	public static func setColors(){
		CNColor.black.setStroke()
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

	public func setColors(){
		strokeColor.setStroke()
		fillColor.setFill()
	}

	open func reshape(position pos: CNPosition, nextPoint point: CGPoint){
		NSLog("Must be override: \(#function)")
	}

	open func contains(point pt: CGPoint) -> Bool {
		NSLog("Must be override: \(#function)")
		return false
	}

	open func move(_ dx: CGFloat, _ dy: CGFloat) {
		NSLog("Must be override: \(#function)")
	}

	open func resize(ratio r: CGFloat) {
		NSLog("Must be override: \(#function)")
	}

	public func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"lineWidth"   : floatToValue(value: self.lineWidth),
			"doFill"      : boolToValue(value: self.doFill),
			"fillColor"   : .dictionaryValue(fillColor.toValue()),
			"strokeColor" : .dictionaryValue(strokeColor.toValue())
		]
		return result
	}

	public static func decode(value val: Dictionary<String, CNValue>) -> (CGFloat, Bool, CNColor, CNColor)? {
		guard let lwidth = floatInDictionary(dictionary: val, forKey: "lineWidth") else {
			CNLog(logLevel: .error, message: "The \"lineWidth\" property is not found")
			return nil
		}
		guard let dofill = boolInDictionary(dictionary:  val, forKey: "doFill") else {
			CNLog(logLevel: .error, message: "The \"doFill\" property is not found")
			return nil
		}
		guard let fcolor = objectInDictionary(dictionary: val, forKey: "fillColor") as? CNColor else {
			CNLog(logLevel: .error, message: "The \"fillColor\" property is not found")
			return nil
		}
		guard let scolor = objectInDictionary(dictionary: val, forKey: "strokeColor") as? CNColor else {
			CNLog(logLevel: .error, message: "The \"strokeColor\" property is not found")
			return nil
		}
		return (lwidth, dofill, fcolor, scolor)
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

	public override func contains(point pt: CGPoint) -> Bool {
		if let path = mBezierPath {
			return path.contains(pt)
		} else {
			return false
		}
	}
}

public class CNVectorPath: CNPathObject
{
	public static let ClassName = "vectorPath"

	private var mPoints:	Array<CGPoint>

	public override init(lineWidth width: CGFloat, doFill fill: Bool, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		mPoints		= []
		super.init(lineWidth: width, doFill: fill, strokeColor: scolor, fillColor: fcolor)
	}

	public static func fromValue(value val: CNValue) -> CNVectorPath? {
		if let dict = val.toDictionary() {
			return fromValue(value: dict)
		} else {
			return nil
		}
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNVectorPath? {
		if let (lwidth, dofill, fcolor, scolor) = CNVectorObject.decode(value: val) {
			if let pointsval = val["points"] {
				if let points = CNVectorPath.loadPoints(value: pointsval) {
					let path = CNVectorPath(lineWidth: lwidth, doFill: dofill, strokeColor: scolor, fillColor: fcolor)
					path.mPoints = points
					return path
				}
			}
		}
		return nil
	}

	private static func loadPoints(value val: CNValue) -> Array<CGPoint>? {
		if let elms = val.toArray() {
			var result: Array<CGPoint> = []
			for elm in elms {
				switch elm {
				case .interfaceValue(let ifval):
					if let pt = CGPoint.fromValue(value: ifval) {
						result.append(pt)
					} else {
						CNLog(logLevel: .error, message: "Failed to load point", atFunction: #function, inFile: #file)
					}
				default:
					CNLog(logLevel: .error, message: "Dictionary expected", atFunction: #function, inFile: #file)
				}
			}
			return result
		}
		return nil
	}

	public var points: Array<CGPoint> {
		get { return mPoints }
	}

	public func add(point pt: CGPoint){
		mPoints.append(pt)
	}

	open override func reshape(position pos: CNPosition, nextPoint point: CGPoint){
		self.add(point: point)
	}

	open override func move(_ dx: CGFloat, _ dy: CGFloat) {
		var newpoints: Array<CGPoint> = []
		for orgpt in mPoints {
			let newpt = CGPoint(x: orgpt.x + dx, y: orgpt.y + dy)
			newpoints.append(newpt)
		}
		mPoints = newpoints
	}

	open override func resize(ratio r: CGFloat) {
		var newpoints:Array<CGPoint> = []
		for curpt in mPoints {
			let newpt = CGPoint(x: curpt.x * r, y: curpt.y * r)
			newpoints.append(newpt)
		}
		mPoints = newpoints
	}

	public override func toValue() -> Dictionary<String, CNValue> {
		var result = super.toValue()
		var points: Array<CNValue> = []
		for pt in mPoints {
			points.append(.interfaceValue(pt.toValue()))
		}
		result["class" ] = .stringValue(CNVectorPath.ClassName)
		result["points"] = .arrayValue(points)
		return result
	}
}

public class CNVectorRect: CNPathObject
{
	public static let ClassName = "vectorRect"

	public var originPoint:		CGPoint
	public var endPoint:		CGPoint
	public var isRounded:		Bool

	public init(lineWidth width: CGFloat, doFill fill: Bool, isRounded isrnd: Bool, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		originPoint	= CGPoint.zero
		endPoint	= CGPoint.zero
		isRounded	= isrnd
		super.init(lineWidth: width, doFill: fill, strokeColor: scolor, fillColor: fcolor)
	}

	public static func fromValue(value val: CNValue) -> CNVectorRect? {
		if let dict = val.toDictionary() {
			return fromValue(value: dict)
		} else {
			return nil
		}
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNVectorRect? {
		if let (lwidth, dofill, fcolor, scolor) = CNVectorObject.decode(value: val) {
			if let origin = pointInDictionary(dictionary: val, forKey: "origin"),
			   let size   = sizeInDictionary(dictionary:  val, forKey: "size"),
			   let rnd    = boolInDictionary(dictionary: val, forKey: "isRounded"),
			   let rx     = floatInDictionary(dictionary: val, forKey: "rx") {
				let rect = CNVectorRect(lineWidth: lwidth, doFill: dofill, isRounded: rx > 0.0, strokeColor: scolor, fillColor: fcolor)
				rect.originPoint = CGPoint(x: origin.x, y: origin.y)
				rect.endPoint    = CGPoint(x: origin.x + size.width, y: origin.y + size.height)
				rect.isRounded   = rnd
				return rect
			}
		}
		return nil
	}

	public override func toValue() -> Dictionary<String, CNValue> {
		let rect = self.toRect()
		var result = super.toValue()
		result["class"    ] = .stringValue(CNVectorRect.ClassName)
		result["origin"   ] = .interfaceValue(rect.origin.toValue())
		result["size"     ] = .interfaceValue(rect.size.toValue())
		result["isRounded"] = .boolValue(self.isRounded)
		result["rx"       ] = floatToValue(value: self.roundValue)
		result["ry"       ] = floatToValue(value: self.roundValue)
		return result
	}

	public var roundValue: CGFloat {
		get { return 10.0}
	}

	open override func reshape(position pos: CNPosition, nextPoint point: CGPoint){
		let orgrect = CGRect.pointsToRect(fromPoint: originPoint, toPoint: endPoint)
		let orgul   = orgrect.upperLeftPoint
		let orgur   = orgrect.upperRightPoint
		let orgll   = orgrect.lowerLeftPoint
		let orglr   = orgrect.lowerRightPoint

		let neworg, newend: CGPoint
		switch pos.horizontal {
		case .left:
			switch pos.vertical {
			case .top:
				neworg = orglr
				newend = point
			case .middle:
				neworg = orgur
				newend = CGPoint(x: point.x, y: orgll.y)
			case .bottom:
				neworg = orgur
				newend = point
			}
		case .center:
			switch pos.vertical {
			case .top:
				neworg = orgll
				newend = CGPoint(x: orgur.x, y: point.y)
			case .middle:
				neworg = orgll
				newend = orgur
			case .bottom:
				neworg = orgul
				newend = CGPoint(x: orglr.x, y: point.y)
			}
		case .right:
			switch pos.vertical {
			case .top:
				neworg = orgll
				newend = point
			case .middle:
				neworg = orgul
				newend = CGPoint(x: point.x, y: orglr.y)
			case .bottom:
				neworg = orgul
				newend = point
			}
		}
		originPoint	= neworg
		endPoint	= newend
	}

	public func toRect() -> CGRect {
		let x      = min(originPoint.x, endPoint.x)
		let y      = min(originPoint.y, endPoint.y)
		let width  = abs(originPoint.x - endPoint.x)
		let height = abs(originPoint.y - endPoint.y)
		return CGRect(x: x, y: y, width: width, height: height)
	}

	open override func move(_ dx: CGFloat, _ dy: CGFloat) {
		let neworign = CGPoint(x: originPoint.x + dx, y: originPoint.y + dy)
		let newend   = CGPoint(x: endPoint.x + dx, y: endPoint.y + dy)
		originPoint  = neworign
		endPoint     = newend
	}

	open override func resize(ratio r: CGFloat) {
		originPoint = CGPoint(x: originPoint.x * r, y: originPoint.y * r)
		endPoint    = CGPoint(x: endPoint.x * r, y: endPoint.y * r)
	}

}

public class CNVectorOval: CNPathObject
{
	public static let ClassName = "vectorOval"

	public var centerPoint:		CGPoint
	public var endPoint:		CGPoint

	public override init(lineWidth width: CGFloat, doFill fill: Bool, strokeColor scolor: CNColor, fillColor fcolor: CNColor){
		centerPoint	= CGPoint.zero
		endPoint	= CGPoint.zero
		super.init(lineWidth: width, doFill: fill, strokeColor: scolor, fillColor: fcolor)
	}

	public static func fromValue(value val: CNValue) -> CNVectorOval? {
		if let dict = val.toDictionary() {
			return fromValue(value: dict)
		} else {
			return nil
		}
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNVectorOval? {
		if let (lwidth, dofill, fcolor, scolor) = CNVectorObject.decode(value: val) {
			if let center = pointInDictionary(dictionary: val, forKey: "center"),
			   let radius = floatInDictionary(dictionary: val, forKey: "radius") {
				let oval = CNVectorOval(lineWidth: lwidth, doFill: dofill, strokeColor: scolor, fillColor: fcolor)
				oval.centerPoint = center
				oval.endPoint    = CGPoint(x: center.x + radius, y: center.y)
				return oval
			}
		}
		return nil
	}

	public override func toValue() -> Dictionary<String, CNValue> {
		var result = super.toValue()
		let rnum   = NSNumber(floatLiteral: Double(self.radius))
		let local: Dictionary<String, CNValue> = [
			"class"	      : .stringValue(CNVectorOval.ClassName),
			"center"      : .interfaceValue(centerPoint.toValue()),
			"radius"      : .numberValue(rnum)
		]
		for (key, val) in local {
			result[key] = val
		}
		return result
	}

	public var radius: CGFloat { get {
		let dx: CGFloat = abs(endPoint.x - centerPoint.x)
		let dy: CGFloat = abs(endPoint.y - centerPoint.y)
		return sqrt(dx*dx + dy*dy)
	}}

	open override func reshape(position pos: CNPosition, nextPoint point: CGPoint){
		endPoint = point
	}

	public func toOval() -> (CGPoint, CGFloat) { // (center, radius)
		let diffx  = centerPoint.x - endPoint.x
		let diffy  = centerPoint.y - endPoint.y
		let radius = sqrt(diffx * diffx + diffy * diffy)
		return (centerPoint, radius)
	}

	open override func move(_ dx: CGFloat, _ dy: CGFloat) {
		let newcenter = CGPoint(x: centerPoint.x + dx, y: centerPoint.y + dy)
		let newend    = CGPoint(x: endPoint.x + dx, y: endPoint.y + dy)
		centerPoint   = newcenter
		endPoint      = newend
	}

	open override func resize(ratio r: CGFloat) {
		centerPoint = CGPoint(x: centerPoint.x * r, y: centerPoint.y * r)
		endPoint    = CGPoint(x: endPoint.x * r, y: endPoint.y * r)
	}
}

public class CNVectorString: CNVectorObject
{
	public static let ClassName = "vectorString"

	public var originPoint:		CGPoint
	public var string:		String
	public var font:		CNFont

	private var mAttributedString:	NSAttributedString?

	public init(font fnt: CNFont, color col: CNColor) {
		originPoint 		= CGPoint.zero
		string 	   		= ""
		font	    		= fnt
		mAttributedString	= nil
		super.init(lineWidth: 1.0, doFill: false, strokeColor: col, fillColor: CNColor.clear)
	}

	public static func fromValue(value val: CNValue) -> CNVectorString? {
		if let dict = val.toDictionary() {
			return fromValue(value: dict)
		} else {
			return nil
		}
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNVectorString? {
		if let orgval = val["origin"], let txtval = val["text"], let fontval = val["font"], let colval = val["color"] {
			if let orgif    = orgval.toInterface(interfaceName: CGPoint.InterfaceName),
			   let txtstr   = txtval.toString(),
			   let fontdict = fontval.toDictionary(), let coldict = colval.toDictionary() {
				if let orgpt = CGPoint.fromValue(value: orgif),
				   let font  = CNFont.fromValue(value: fontdict),
				   let color = CNColor.fromValue(value: coldict) {
					let vstr = CNVectorString(font: font, color: color)
					vstr.originPoint = orgpt
					vstr.string      = txtstr
					return vstr
				}
			}
		}
		return nil
	}

	public override func toValue() -> Dictionary<String, CNValue> {
		let orgpt = self.originPoint.toValue()
		let text  = CNValue.stringValue(string)
		let fnt   = font.toValue()
		let color = self.strokeColor.toValue()
		let result: Dictionary<String, CNValue> = [
			"class":	.stringValue(CNVectorString.ClassName),
			"origin":	.interfaceValue(orgpt),
			"text":		text,
			"font":		.dictionaryValue(fnt),
			"color":	.dictionaryValue(color)
		]
		return result
	}

	public var isEmpty: Bool {
		get { return self.string.isEmpty }
	}

	open override func reshape(position pos: CNPosition, nextPoint point: CGPoint){
		NSLog("Must be override: \(#function)")
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

	public override func contains(point pt: CGPoint) -> Bool {
		if let astr = mAttributedString {
			let strrect = CGRect(origin: originPoint, size: astr.size())
			return strrect.contains(pt)
		} else {
			return false
		}
	}

	open override func move(_ dx: CGFloat, _ dy: CGFloat) {
		let neworigin = CGPoint(x: originPoint.x + dx, y: originPoint.y + dy)
		originPoint   = neworigin
	}

	open override func resize(ratio r: CGFloat) {
		originPoint = CGPoint(x: originPoint.x * r, y: originPoint.y * r)
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


