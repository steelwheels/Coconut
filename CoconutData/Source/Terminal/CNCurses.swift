/**
 * @file	CNCurses.swift
 * @brief	Define CNCurses class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public class CNCurses {
	public struct Size {
		public var 	width: 		Int
		public var	height:		Int
		public init(width w: Int, height h: Int){
			width  = w
			height = h
		}
	}

	private var	mTerminalInfo:	CNTerminalInfo

	public init(terminalInfo tinfo: CNTerminalInfo) {
		mTerminalInfo = tinfo
	}

	public var size: Size {
		return Size(width: mTerminalInfo.width, height: mTerminalInfo.height)
	}
}

