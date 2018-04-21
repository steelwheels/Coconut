/**
 * @file	CNParser.swift
 * @brief	Define CNParser class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public enum CNParseError: Error
{
	case NoError
	case TokenizeError(Int, String)
	case ParseError(Int, String)

	public func description() -> String {
		let result: String
		switch self {
		case .NoError:
			result = "No error"
		case .TokenizeError(let lineno, let message):
			result = "Error: \(message) at line \(lineno)"
		case .ParseError(let lineno, let message):
			var linedesc: String
			if lineno > 0 {
				linedesc = " at line \(lineno)"
			} else {
				linedesc = ""
			}
			result = "Error: \(message)" + linedesc
		}
		return result
	}
}
