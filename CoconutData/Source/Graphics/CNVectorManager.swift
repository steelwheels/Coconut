/*
 * @file	CNVectorManager.swift
 * @brief	Define CNVectorManager class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoreGraphics
import Foundation

public class CNVecroManager
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

	public var count: Int {
		get { return mGraphics.count }
	}

	public var contents: Array<CNVectorGraphics> {
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

	public func addObject(location gloc: CGPoint, in area: CGSize, type gtype: CNVectorGraphicsType) -> CNVectorGraphics {
		let newobj: CNVectorGraphics
		let DefaultSize: CGFloat = 0.1
		let loc = convert(point: gloc, in: area)
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
			let newstr = CNVectorString(lineWidth: mLineWidth, font: mFont, color: mStrokeColor)
			newstr.originPoint = loc
			mGraphics.append(.string(newstr))
			newobj = .string(newstr)
		}
		mCurrentIndex = mGraphics.count - 1
		return newobj
	}

	public func moveObject(diffPoint dpoint: CGPoint, in area: CGSize, object gobj: CNVectorGraphics) {
		let dx = dpoint.x / area.width
		let dy = dpoint.y / area.height
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

	public func addPointToObject(nextPoint npoint: CGPoint, in area: CGSize, object gobj: CNVectorGraphics) {
		let nx = npoint.x / area.width
		let ny = npoint.y / area.height
		switch gobj {
		case .path(let path):
			path.add(point: CGPoint(x: nx, y: ny))
		case .rect(_), .oval(_), .string(_):
			CNLog(logLevel: .error, message: "Not supported", atFunction: #function, inFile: #file)
		}
	}

	public func reshapeObject(nextPoint nextpt: CGPoint, in area: CGSize, grip gpoint: CNGripPoint, object gobj: CNVectorGraphics) {
		let nextloc = convert(point: nextpt, in: area)
		switch gobj {
		case .path(let path):
			path.reshape(position: gpoint.position, nextPoint: nextloc)
		case .rect(let rect):
			rect.reshape(position: gpoint.position, nextPoint: nextloc)
		case .oval(let oval):
			oval.reshape(position: gpoint.position, nextPoint: nextloc)
		case .string(let vstr):
			vstr.reshape(position: gpoint.position, nextPoint: nextloc)
		}
	}

	public func contains(point pt: CGPoint, in area: CGSize) -> SelectedGraphics {
		if let obj = currentObject() {
			/* Search the grip point */
			let base = baseObject(in: obj)
			for grip in base.gripPoints {
				if grip.contains(point: pt) {
					return .selectCurrentGrip(grip, obj)
				}
			}
			/* Select current object */
			if base.contains(point: pt, in: area){
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
			if base.contains(point: pt, in: area) {
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

	private func convert(point pt: CGPoint, in area: CGSize) -> CGPoint {
		guard area.width > 0.0 && area.height > 0.0 else {
			CNLog(logLevel: .error, message: "Can not accept empty frame", atFunction: #function, inFile: #file)
			return CGPoint.zero
		}
		let x = pt.x / area.width
		let y = pt.y / area.height
		return CGPoint(x: x, y: y)
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

