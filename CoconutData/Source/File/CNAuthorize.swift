/**
 * @file	CNAuthorize.swift
 * @brief	Define CNAuthorize class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNAuthorizeState: Int
{
	case Undetermined	= 0
	case Examinating	= 1
	case Denied		= 2
	case Authorized		= 3

	public var description: String {
		var result: String
		switch self {
		case .Undetermined:	result = "undetermined"
		case .Examinating:	result = "examinating"
		case .Denied:		result = "denied"
		case .Authorized:	result = "authorized"
		}
		return result
	}
}

