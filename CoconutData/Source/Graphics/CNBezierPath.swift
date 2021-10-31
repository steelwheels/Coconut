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

public class CNBezierPath
{
	public enum Path {
		case moveTo(CGPoint)
		case lineTo(CGPoint)
		case lineWidth(CGFloat)
	}

	private var mPaths:		Array<Path>
	private var mIs1stPoint:	Bool
	private var mLineWidth:		CGFloat

	public init(){
		mPaths		= []
		mIs1stPoint	= true
		mLineWidth	= 1.0
	}

	public func addUp(point pt: CGPoint, in area: CGSize){
		mPaths.append(.lineTo(convert(point: pt, in: area)))
		mIs1stPoint = true
	}

	public func addDown(point pt: CGPoint, in area: CGSize){
		if mIs1stPoint {
			mPaths.append(.moveTo(convert(point: pt, in: area)))
			mIs1stPoint = false
		} else {
			mPaths.append(.lineTo(convert(point: pt, in: area)))
		}
	}

	public func addDrag(point pt: CGPoint, in area: CGSize){
		mPaths.append(.lineTo(convert(point: pt, in: area)))
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

	public func forEach(_ cbfunc: (_ path: Path) -> Void){
		mPaths.forEach({
			(_ path: Path) -> Void in cbfunc(path)
		})
	}

	public var lineWidth: CGFloat {
		get {
			return mLineWidth
		}
		set(newval){
			if newval != mLineWidth {
				mPaths.append(.lineWidth(newval))
				mLineWidth = newval
			}
		}
	}
}

