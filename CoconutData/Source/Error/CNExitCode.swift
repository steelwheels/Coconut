/**
 * @file	CNExitCode.swift
 * @brief	Define exit code
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNExitCode: Int
{
	case NoError
	case InternalError
	case CommandLineError
	case SyntaxError
	case Exception

	public var code: Int32 {
		let result: Int32
		switch self {
		case .NoError:			result = 0
		case .InternalError:		result = 1
		case .CommandLineError:		result = 2
		case .SyntaxError:		result = 3
		case .Exception:		result = 4
		}
		return result
	}

	public var description: String {
		let result: String
		switch self {
		case .NoError:		result = "No error"
		case .InternalError:	result = "Internal error"
		case .CommandLineError:	result = "Commandline error"
		case .SyntaxError:	result = "Syntax error"
		case .Exception:	result = "Exception"
		}
		return result
	}
}

