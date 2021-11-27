/**
 * @file	CNOval.swift
 * @brief	Define CNOval class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoreGraphics
import Foundation

public class CNOval
{
	private var mCenter:	CGPoint
	private var mRadius:	CGFloat

	public init(center ctr: CGPoint, radius rad: CGFloat){
		mCenter		= ctr
		mRadius		= rad
	}

	public var center: CGPoint { get { return mCenter }}

	public var upperCenter: CGPoint { get {
		let result: CGPoint
		#if os(OSX)
			result = CGPoint(x: mCenter.x, y: mCenter.y + mRadius)
		#else
			result = CGPoint(x: mCenter.x, y: mCenter.y - mRadius)
		#endif
		return result
	}}

	public var lowerCenter: CGPoint { get {
		let result: CGPoint
		#if os(OSX)
			result = CGPoint(x: mCenter.x, y: mCenter.y - mRadius)
		#else
			result = CGPoint(x: mCenter.x, y: mCenter.y + mRadius)
		#endif
		return result
	}}

	public var middleLeft: CGPoint { get {
		return CGPoint(x: mCenter.x - mRadius, y: mCenter.y)
	}}

	public var middleRight: CGPoint { get {
		return CGPoint(x: mCenter.x + mRadius, y: mCenter.y)
	}}
}


