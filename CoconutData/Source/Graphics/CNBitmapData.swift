/*
 * @file	CNBitmapData.swift
 * @brief	Define CNBitmapDAta class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNBitmapData
{
	private var mWidth: 		Int
	private var mHeight:		Int
	private var mData:		Array<Array<CNColor>>
	private var mBackgroundColor:	CNColor

	public var width:		Int			{ get { return mWidth  }}
	public var height:		Int			{ get { return mHeight }}
	public var data:   		Array<Array<CNColor>>	{ get { return mData }}
	public var backgroundColor:	CNColor 		{ get { return mBackgroundColor }}

	public init(width w: Int, height h: Int, backgroundColor bcol: CNColor) {
		mWidth			= w
		mHeight			= h
		mData   		= []
		mBackgroundColor	= bcol
		for _ in 0..<h {
			let row = Array(repeating: bcol, count: w)
			mData.append(row)
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

