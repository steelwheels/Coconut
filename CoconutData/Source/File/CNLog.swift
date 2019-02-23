/**
 * @file	CNLog.swift
 * @brief	Define CNLog function
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public enum CNLogType: Int, Comparable {
	case Debug	= 0
	case Flow	= 1
	case Warning	= 2
	case Error	= 3

	public static func < (lhs: CNLogType, rhs: CNLogType) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}

	public var description: String {
		let result: String
		switch self {
		case .Debug:	result = "Debug  " // keep same string length
		case .Flow:	result = "Flow   "
		case .Warning:	result = "Warning"
		case .Error:	result = "Error  "
		}
		return result
	}
}

private var mLogConsole:	CNConsole?	= nil
private var mLogLevel:		CNLogType	= .Warning

public func CNLogSetup(console cons: CNConsole?, logLevel level: CNLogType)
{
	mLogConsole	= cons
	mLogLevel	= level
}

public func CNLog(type typ: CNLogType, message msg: String, file fname: String, line ln: Int, function fnc: String)
{
	if typ.rawValue >= mLogLevel.rawValue {
		let place   = "\(fname)/\(ln)/\(fnc)"
		let message = "[\(typ.description)] \(msg) at \(place)\n"
		CNPrintString(string: message)
	}
}

public func CNLog(type typ: CNLogType, text txt: CNText, file fname: String, line ln: Int, function fnc: String)
{
	if typ.rawValue >= mLogLevel.rawValue {
		let place   = "\(fname)/\(ln)/\(fnc)"
		let header  = "[\(typ.description)] at \(place)\n"
		CNPrintString(string: header)
		CNPrintText(text: txt)
	}
}

public func CNDoPrintLog(logLevel level: CNLogType) -> Bool {
	return level >= mLogLevel
}

private func CNPrintString(string str: String)
{
	if let cons = mLogConsole {
		cons.print(string: str)
	} else {
		#if os(OSX)
		let fcons = CNFileConsole()
		fcons.print(string: str)
		#else
		NSLog(str)
		#endif
	}
}

private func CNPrintText(text txt: CNText)
{
	if let cons = mLogConsole {
		txt.print(console: cons)
	} else {
		#if os(OSX)
		let fcons = CNFileConsole()
		txt.print(console: fcons)
		#else
		NSLog("Failed to dump text at \(#file):\(#line):\(#function)")
		#endif
	}
}

