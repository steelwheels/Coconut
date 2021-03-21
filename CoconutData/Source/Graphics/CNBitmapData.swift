/*
 * @file	CNBitmapData.swift
 * @brief	Define CNBitmapData class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNBitmapData
{
	private var mWidth: 		Int
	private var mHeight:		Int
	private var mData:		Array<Array<CNColor>>

	public var width:		Int			{ get { return mWidth  }}
	public var height:		Int			{ get { return mHeight }}

	public init(width w: Int, height h: Int) {
		mWidth			= w
		mHeight			= h
		mData   		= []
		for _ in 0..<h {
			let row = Array(repeating: CNColor.clear, count: w)
			mData.append(row)
		}
	}

	public init(colorData cdata: Array<Array<CNColor>>) {
		mHeight		= cdata.count
		mWidth		= cdata[0].count
		mData		= cdata
	}

	public func resize(width wid: Int, height hgt: Int) {
		/* If the size is not changed, do nothing */
		if mWidth == wid && mHeight == hgt {
			return
		}
		/* Allocate new empty data */
		var newdata: Array<Array<CNColor>> = []
		for _ in 0..<wid {
			let row = Array(repeating: CNColor.clear, count: hgt)
			newdata.append(row)
		}
		/* copy contents */
		let mwid = min(wid, mWidth)
		let mhgt = min(hgt, mHeight)
		for y in 0..<mhgt {
			for x in 0..<mwid {
				newdata[y][x] = mData[y][x]
			}
		}
		/* Replace */
		mWidth	= wid
		mHeight	= hgt
		mData	= newdata
	}

	public func set(x posx: Int, y posy: Int, color col: CNColor) {
		if 0<=posx && posx<mWidth {
			if 0<=posy && posy<mHeight {
				mData[posy][posx] = col
			}
		}
	}

	public func set(x posx: Int, y posy: Int, bitmap bm: CNBitmapData){
		let height = bm.mData.count
		for y in 0..<height {
			let line  = bm.mData[y]
			let width = line.count
			for x in 0..<width {
				set(x: posx + x, y: posy + y, color: line[x])
			}
		}
	}

	public func clean() {
		for y in 0..<mHeight {
			for x in 0..<mWidth {
				mData[y][x] = CNColor.clear
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

	public func toText() -> CNText {
		let result = CNTextSection()
		result.header = "BitmapContents: {" ; result.footer = "}"
		result.add(text: CNTextLine(string: "width:  \(width)"))
		result.add(text: CNTextLine(string: "height: \(height)"))

		let data = CNTextSection()
		data.header = "data: {" ; data.footer = "}"
		for line in mData {
			data.append(text: lineToText(line: line))
		}
		result.add(text: data)

		return result
	}

	private func lineToText(line ln: Array<CNColor>) -> CNTextLine {
		var result = ""
		for col in ln {
			if col.alphaComponent == 0.0 {
				result += "-"
			} else {
				switch col.escapeCode() {
				case 0:		result += "k"
				case 1:		result += "r"
				case 2:		result += "g"
				case 3:		result += "y"
				case 4:		result += "b"
				case 5:		result += "m"
				case 6:		result += "c"
				case 7:		result += "w"
				default:	result += "?"
				}
			}
		}
		return CNTextLine(string: result + "\n")
	}
}

