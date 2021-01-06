/*
 * @file	CNGraphicsType.swift
 * @brief	Define data type for graphics
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNAxis: Int32
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


public enum CNAlignment: Int32 {
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

/* OSX: NSStackView.Distribution */
public enum CNDistribution: Int32 {
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

