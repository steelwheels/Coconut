/*
 * @file	CNBitmapData.swift
 * @brief	Define CNBitmapDAta class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNBitmapData
{
	private var mPositionX:		Int
	private var mPositionY:		Int
	private var mWidth: 		Int
	private var mHeight:		Int
	private var mData:		Array<Array<CNColor>>

	public var positionX:		Int 			{ get { return mPositionX }}
	public var positionY:		Int			{ get { return mPositionY }}
	public var width:		Int			{ get { return mWidth  }}
	public var height:		Int			{ get { return mHeight }}
	public var data:   		Array<Array<CNColor>>	{ get { return mData }}

	public init(x xpos: Int, y ypos: Int, width w: Int, height h: Int) {
		mPositionX		= xpos
		mPositionY		= ypos
		mWidth			= w
		mHeight			= h
		mData   		= []
		for _ in 0..<h {
			let row = Array(repeating: CNColor.clear, count: w)
			mData.append(row)
		}
	}

	public init(monoData idata: Array<Array<Int>>) {
		mPositionX		= 0
		mPositionY		= 0
		mHeight			= idata.count
		var width: Int = 0
		for row in idata {
			width = max(width, row.count)
		}
		mWidth			= width
		/* Allocate destination array */
		mData = []
		for _ in 0..<mHeight {
			let row = Array(repeating: CNColor.clear, count: mWidth)
			mData.append(row)
		}
		/* get color */
		let fgcolor = CNPreference.shared.viewPreference.foregroundColor
		let bgcolor = CNPreference.shared.viewPreference.backgroundColor

		/* Copy array */
		for y in 0..<idata.count {
			let row = idata[y]
			for x in 0..<row.count {
				let ival = row[x]
				mData[y][x] = (ival != 0) ? fgcolor : bgcolor
			}
		}
	}

	public func set(x posx: Int, y posy: Int, color col: CNColor) {
		if 0<=posx && posx<mWidth {
			if 0<=posy && posy<mHeight {
				mData[posy][posx] = col
			}
		}
	}

	public func get(x posx: Int, y posy: Int) -> CNColor? {
		if 0<=posx && posx<mWidth {
			if 0<=posy && posy<mHeight {
				return mData[posy][posx]
			}
		}
		return nil
	}
}

