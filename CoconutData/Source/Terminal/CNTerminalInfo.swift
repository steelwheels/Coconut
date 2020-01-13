/**
 * @file	CNTerminalInfo.swift
 * @brief	Define CNTerminalInfo class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public class CNTerminalInfo {
	public var	width:			Int
	public var	height:			Int
	public var	foregroundColor:	CNColor
	public var	backgroundColor:	CNColor

	public init(){
		width		= 0
		height		= 0
		foregroundColor	= CNColor.Green
		backgroundColor	= CNColor.Black
	}
}
