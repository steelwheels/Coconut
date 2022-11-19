/*
 * @file	CNGraphicsType.swift
 * @brief	Define data type for graphics
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNAxis: Int
{
	case horizontal
	case vertical

	public static var typeName = "Axis"

	public var description: String {
		let result: String
		switch self {
		case .horizontal:	result = "horizontal"
		case .vertical:		result = "vertical"
		}
		return result
	}
}

public enum CNAlignment: Int {
	case leading
	case trailing
	case fill
	case center

	public static var typeName = "Alignment"

	public var description: String {
		let result: String
		switch self {
		case .leading:		result = "leading"
		case .trailing:		result = "trailing"
		case .fill:		result = "fill"
		case .center:		result = "center"
		}
		return result
	}
}

public enum CNVerticalPosition {
	case top
	case middle
	case bottom
}

public enum CNHorizontalPosition {
	case left
	case center
	case right
}

public enum CNIconSize: Int {
	case small
	case regular
	case large
}

public struct CNPosition {
	public var 	horizontal:	CNHorizontalPosition
	public var	vertical:	CNVerticalPosition

	public init(){
		vertical	= .middle
		horizontal	= .center
	}

	public init(horizontal hpos: CNHorizontalPosition, vertical vpos: CNVerticalPosition){
		vertical	= vpos
		horizontal	= hpos
	}
}

/* OSX: NSStackView.Distribution */
public enum CNDistribution: Int {
	case fill
	case fillProportinally
	case fillEqually
	case equalSpacing

	public static var typeName = "Distribution"

	public var description: String {
		let result: String
		switch self {
		case .fill:			result = "fill"
		case .fillProportinally:	result = "fillProportionally"
		case .fillEqually:		result = "fillEqually"
		case .equalSpacing:		result = "equalSpacing"
		}
		return result
	}
}

public enum CNAnimationState: Int {
	case	idle
	case	run
	case	pause

	public static var typeName = "AnimationState"

	public var description: String {
		get {
			let result: String
			switch self {
			case .idle:	result = "idle"
			case .run:	result = "run"
			case .pause:	result = "pause"
			}
			return result
		}
	}
}
