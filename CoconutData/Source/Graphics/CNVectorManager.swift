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
		case grip(CNGripPoint, CNVectorGraphics)
		case graphics(CNVectorGraphics)
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

	public func currentItem() -> CNVectorGraphics? {
		if let idx = mCurrentIndex {
			return mGraphics[idx]
		} else {
			return nil
		}
	}

	public func addItem(location gloc: CGPoint, in area: CGSize, graphicsType gtype: CNVectorGraphicsType){
		let DefaultSize: CGFloat = 0.1
		let loc = convert(point: gloc, in: area)
		switch gtype {
		case .path(let dofill):
			let newobj = CNVectorPath(lineWidth: mLineWidth, doFill: dofill, strokeColor: mStrokeColor, fillColor: mFillColor)
			newobj.add(point: loc)
			mGraphics.append(.path(newobj))
		case .rect(let dofill, let isround):
			let newobj = CNVectorRect(lineWidth: mLineWidth, doFill: dofill, isRounded: isround, strokeColor: mStrokeColor, fillColor: mFillColor)
			newobj.originPoint = loc
			newobj.endPoint    = CGPoint(x: loc.x + DefaultSize, y: loc.y + DefaultSize)
			mGraphics.append(.rect(newobj))
		case .oval(let dofill):
			let newobj = CNVectorOval(lineWidth: mLineWidth, doFill: dofill, strokeColor: mStrokeColor, fillColor: mFillColor)
			newobj.centerPoint = loc
			newobj.endPoint    = CGPoint(x: loc.x + DefaultSize, y: loc.y + DefaultSize)
			mGraphics.append(.oval(newobj))
		case .string:
			let newobj = CNVectorString(lineWidth: mLineWidth, font: mFont, color: mStrokeColor)
			newobj.originPoint = loc
			mGraphics.append(.string(newobj))
		}
		mCurrentIndex = mGraphics.count - 1
	}

	public func moveItem(diffPoint dpoint: CGPoint, in area: CGSize, graphics gobj: CNVectorGraphics) {
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

	public func contains(point pt: CGPoint, in area: CGSize) -> SelectedGraphics {
		/* Search the grip point */
		if let item = currentItem() {
			let grippoints: Array<CNGripPoint>
			switch item {
			case .path(let path):   grippoints = path.gripPoints
			case .rect(let rect):   grippoints = rect.gripPoints
			case .oval(let oval):   grippoints = oval.gripPoints
			case .string(let vstr): grippoints = vstr.gripPoints
			}
			for grip in grippoints {
				if grip.contains(point: pt) {
					return .grip(grip, item)
				}
			}
		}
		/* Search graphics */
		for item in mGraphics.reversed() {
			let gr: CNVectorObject
			switch item {
			case .path(let path):   gr = path
			case .rect(let rect):   gr = rect
			case .oval(let oval):   gr = oval
			case .string(let vstr): gr = vstr
			}
			if gr.contains(point: pt, in: area) {
				return .graphics(item)
			}
		}
		return .none
	}

	public func loadString() -> String? {
		var result: String? = nil
		if let item = currentItem() {
			switch item {
			case .path(_), .rect(_), .oval(_):
				result = nil
			case .string(let vstr):
				result = vstr.string
			}
		}
		return result
	}

	public func storeString(string str: String) {
		if let item = currentItem() {
			switch item {
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
}

