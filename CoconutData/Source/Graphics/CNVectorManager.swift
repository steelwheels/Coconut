/*
 * @file	CNVectorManager.swift
 * @brief	Define CNVectorManager class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoreGraphics
import Foundation

private func className(value val: Dictionary<String, CNValue>) -> String? {
	if let nameval = val["class"] {
		if let namestr = nameval.toString() {
			return namestr
		}
	}
	return nil
}

public class CNVectorManager
{
	private var mGraphics:		Array<CNVectorGraphics>
	private var mCurrentIndex:	Int?
	private var mLineWidth:		CGFloat
	private var mStrokeColor:	CNColor
	private var mFillColor:		CNColor
	private var mFont:		CNFont

	public enum SelectedGraphics {
		case none
		case selectCurrentGrip(CNGripPoint, CNVectorGraphics)
		case selectCurrentObject(CNVectorGraphics)
		case selectOtherObject(Int)			// next target index
	}

	public init(){
		mGraphics	= []
		mCurrentIndex	= nil
		mLineWidth	= 1.0
		mStrokeColor	= CNColor.black
		mFillColor	= CNColor.black
		mFont		= CNFont.systemFont(ofSize: CNFont.systemFontSize)
	}

	public convenience init?(objects objs: Array<CNValue>) {
		self.init()
		if self.load(objects: objs) {
			return	// load done
		} else {
			CNLog(logLevel: .error, message: "Failed to load objects", atFunction: #function, inFile: #file)
			return nil
		}
	}

	public var count: Int {
		get { return mGraphics.count }
	}

	public var objects: Array<CNVectorGraphics> {
		get { return mGraphics }
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

	public var font: CNFont {
		get 	    { return mFont }
		set(newval) { mFont = newval }
	}

	public func currentObject() -> CNVectorGraphics? {
		if let idx = mCurrentIndex {
			return mGraphics[idx]
		} else {
			return nil
		}
	}

	public func selectObject(index idx: Int) {
		if 0<=idx && idx < mGraphics.count {
			mCurrentIndex = idx
		}
	}

	public func addObject(location loc: CGPoint, type gtype: CNVectorGraphicsType) -> CNVectorGraphics {
		let newobj: CNVectorGraphics
		let DefaultSize: CGFloat = 50.0
		switch gtype {
		case .path(let dofill):
			let newpath = CNVectorPath(lineWidth: mLineWidth, doFill: dofill, strokeColor: mStrokeColor, fillColor: mFillColor)
			newpath.add(point: loc)
			mGraphics.append(.path(newpath))
			newobj = .path(newpath)
		case .rect(let dofill, let isround):
			let newrect = CNVectorRect(lineWidth: mLineWidth, doFill: dofill, isRounded: isround, strokeColor: mStrokeColor, fillColor: mFillColor)
			newrect.originPoint = loc
			newrect.endPoint    = CGPoint(x: loc.x + DefaultSize, y: loc.y + DefaultSize)
			mGraphics.append(.rect(newrect))
			newobj = .rect(newrect)
		case .oval(let dofill):
			let newoval = CNVectorOval(lineWidth: mLineWidth, doFill: dofill, strokeColor: mStrokeColor, fillColor: mFillColor)
			newoval.centerPoint = loc
			newoval.endPoint    = CGPoint(x: loc.x + DefaultSize, y: loc.y + DefaultSize)
			mGraphics.append(.oval(newoval))
			newobj = .oval(newoval)
		case .string:
			let newstr = CNVectorString(font: mFont, color: mStrokeColor)
			newstr.originPoint = loc
			mGraphics.append(.string(newstr))
			newobj = .string(newstr)
		}
		mCurrentIndex = mGraphics.count - 1
		return newobj
	}

	public func moveObject(diffPoint dpoint: CGPoint, object gobj: CNVectorGraphics) {
		let dx = dpoint.x
		let dy = dpoint.y
		switch gobj {
		case .path(let path):
			path.move(dx, dy)
		case .rect(let rect):
			rect.move(dx, dy)
		case .oval(let oval):
			oval.move(dx, dy)
		case .string(let vstr):
			vstr.move(dx, dy)
		}
	}

	public func resize(from fsize: CGSize, to tsize: CGSize) {
		guard fsize.width > 0.0 && fsize.height > 0.0 && tsize.width > 0.0 && fsize.height > 0.0 else {
			return
		}
		let ratio = min(tsize.width / fsize.width, tsize.height / fsize.height)
		for obj in mGraphics {
			switch obj {
			case .rect(let rect):
				rect.resize(ratio: ratio)
			case .path(let path):
				path.resize(ratio: ratio)
			case .oval(let oval):
				oval.resize(ratio: ratio)
			case .string(let vstr):
				vstr.resize(ratio: ratio)
			}
		}
	}

	public func addPointToObject(nextPoint npoint: CGPoint, object gobj: CNVectorGraphics) {
		let nx = npoint.x
		let ny = npoint.y
		switch gobj {
		case .path(let path):
			path.add(point: CGPoint(x: nx, y: ny))
		case .rect(_), .oval(_), .string(_):
			CNLog(logLevel: .error, message: "Not supported", atFunction: #function, inFile: #file)
		}
	}

	public func reshapeObject(nextPoint nextpt: CGPoint, grip gpoint: CNGripPoint, object gobj: CNVectorGraphics) {
		switch gobj {
		case .path(let path):
			path.reshape(position: gpoint.position, nextPoint: nextpt)
		case .rect(let rect):
			rect.reshape(position: gpoint.position, nextPoint: nextpt)
		case .oval(let oval):
			oval.reshape(position: gpoint.position, nextPoint: nextpt)
		case .string(let vstr):
			vstr.reshape(position: gpoint.position, nextPoint: nextpt)
		}
	}

	public func contains(point pt: CGPoint) -> SelectedGraphics {
		if let obj = currentObject() {
			/* Search the grip point */
			let base = baseObject(in: obj)
			for grip in base.gripPoints {
				if grip.contains(point: pt) {
					return .selectCurrentGrip(grip, obj)
				}
			}
			/* Select current object */
			if base.contains(point: pt){
				return .selectCurrentObject(obj)
			}
		}
		/* Search graphics */
		let count = mGraphics.count
		for i in (0..<count).reversed() {
			if let curidx = mCurrentIndex {
				if curidx == i {
					continue
				}
			}
			let base = baseObject(in: mGraphics[i])
			if base.contains(point: pt) {
				return .selectOtherObject(i)
			}
		}
		return .none
	}

	public func loadString() -> String? {
		var result: String? = nil
		if let obj = currentObject() {
			switch obj {
			case .path(_), .rect(_), .oval(_):
				result = nil
			case .string(let vstr):
				result = vstr.string
			}
		}
		return result
	}

	public func storeString(string str: String) {
		if let obj = currentObject() {
			switch obj {
			case .path(_), .rect(_), .oval(_):
				break
			case .string(let vstr):
				vstr.string = str
			}
		}
	}

	public func toValue() -> Array<CNValue> {
		var objects: Array<CNValue> = []
		for obj in mGraphics {
			switch obj {
			case .path(let path):
				objects.append(.dictionaryValue(path.toValue()))
			case .rect(let rect):
				objects.append(.dictionaryValue(rect.toValue()))
			case .oval(let oval):
				objects.append(.dictionaryValue(oval.toValue()))
			case .string(let vstr):
				objects.append(.dictionaryValue(vstr.toValue()))
			}
		}
		return objects
	}

	public func load(objects objs: Array<CNValue>) -> Bool {
		var result = true
		mGraphics  = []
		for obj in objs {
			if let dict = obj.toDictionary() {
				if let clsname = className(value: dict) {
					switch clsname {
					case CNVectorPath.ClassName:
						if let obj = CNVectorPath(value: dict) {
							mGraphics.append(.path(obj))
						} else {
							CNLog(logLevel: .error, message: "Failed to decode vector path", atFunction: #function, inFile: #file)
							result = false
						}
					case CNVectorRect.ClassName:
						if let obj = CNVectorRect(value: dict) {
							mGraphics.append(.rect(obj))
						} else {
							CNLog(logLevel: .error, message: "Failed to decode vector rect", atFunction: #function, inFile: #file)
							result = false
						}
					case CNVectorOval.ClassName:
						if let obj = CNVectorOval(value: dict) {
							mGraphics.append(.oval(obj))
						} else {
							CNLog(logLevel: .error, message: "Failed to decode vector oval", atFunction: #function, inFile: #file)
							result = false
						}
					case CNVectorString.ClassName:
						if let obj = CNVectorString(value: dict) {
							mGraphics.append(.string(obj))
						} else {
							CNLog(logLevel: .error, message: "Failed to decode vector string", atFunction: #function, inFile: #file)
							result = false
						}
					default:
						CNLog(logLevel: .error, message: "Unknown object name: \(clsname)", atFunction: #function, inFile: #file)
						result = false
					}
				} else {
					CNLog(logLevel: .error, message: "No class name", atFunction: #function, inFile: #file)
					result = false
				}
			} else {
				CNLog(logLevel: .error, message: "Object is required", atFunction: #function, inFile: #file)
				result = false
			}
		}
		return result
	}

	private func baseObject(in obj: CNVectorGraphics) -> CNVectorObject {
		let result: CNVectorObject
		switch obj {
		case .path(let path):	result = path
		case .rect(let rect):	result = rect
		case .oval(let oval):	result = oval
		case .string(let vstr):	result = vstr
		}
		return result
	}
}

