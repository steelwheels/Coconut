/*
 * @file	CNGraphicsMapper.swift
 * @brief	Define CNGraphicsMapper class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public class CNGraphicsMapper
{
	private var 	mLogicalSize:		CGSize
	private var	mPhysicalSize:		CGSize
	private var	l2pRatio:		CGSize
	private var	p2lRatio:		CGSize

	public init(physicalSize psize: CGSize) {
		mPhysicalSize		= psize
		mLogicalSize		= psize
		(l2pRatio, p2lRatio)	= CNGraphicsMapper.updateRatio(logicalSize: mLogicalSize, physicalSize: mPhysicalSize)
	}

	public var logicalSize: CGSize {
		get { return mLogicalSize }
		set(newsize) {
			mLogicalSize	     = newsize
			(l2pRatio, p2lRatio) = CNGraphicsMapper.updateRatio(logicalSize: mLogicalSize, physicalSize: mPhysicalSize)
		}
	}

	public var physicalSize: CGSize {
		get { return mPhysicalSize }
		set(newsize) {
			mPhysicalSize	     = newsize
			(l2pRatio, p2lRatio) = CNGraphicsMapper.updateRatio(logicalSize: mLogicalSize, physicalSize: mPhysicalSize)
		}
	}

	private class func updateRatio(logicalSize lsize: CGSize, physicalSize psize: CGSize) -> (CGSize, CGSize) {
		if lsize.width > 0.0 && lsize.height > 0.0 && psize.width > 0.0 && psize.height > 0.0 {
			let l2pratio = CGSize(width: psize.width/lsize.width, height: psize.height/lsize.height)
			let p2lratio = CGSize(width: lsize.width/psize.width, height: lsize.height/psize.height)
			return (l2pratio, p2lratio)
		} else {
			NSLog("Invalid logical or physical size")
			return (CGSize.zero, CGSize.zero)
		}
	}

	public func logicalToPhysical(point pt: CGPoint) -> CGPoint {
		let x = pt.x * l2pRatio.width
		let y = pt.y * l2pRatio.height
		return CGPoint(x: x, y: y)
	}

	public func physicalToLogical(point pt: CGPoint) -> CGPoint {
		let x = pt.x * p2lRatio.width
		let y = pt.y * p2lRatio.height
		return CGPoint(x: x, y: y)
	}

	public func logicalToPhysical(size sz: CGSize) -> CGSize {
		let width  = sz.width  * l2pRatio.width
		let height = sz.height * l2pRatio.height
		return CGSize(width: width, height: height)
	}

	public func physicalToLogical(size sz: CGSize) -> CGSize {
		let width  = sz.width  * p2lRatio.width
		let height = sz.height * p2lRatio.height
		return CGSize(width: width, height: height)
	}
}

