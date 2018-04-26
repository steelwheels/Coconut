/**
 * @file	CNExitCode.swift
 * @brief	Define exit code
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNExitCode: Int32
{
	case NoError
	case InternalError
	case CommandLineError
	case SyntaxError
	case ExecError
	case Exception

	public var code: Int32 {
		let result: Int32
		switch self {
		case .NoError:		result = 0
		case .InternalError:	result = 1
		case .CommandLineError:	result = 2
		case .SyntaxError:	result = 3
		case .ExecError:	result = 4
		case .Exception:	result = 5
		}
		return result
	}
}

