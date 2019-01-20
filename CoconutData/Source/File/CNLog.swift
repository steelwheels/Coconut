/**
 * @file	CNLog.swift
 * @brief	Define CNLog function
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public enum CNLogType: Int, Comparable {
	case Normal	= 0
	case Warning	= 1
	case Error	= 2

	public static func < (lhs: CNLogType, rhs: CNLogType) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}

	public var description: String {
		let result: String
		switch self {
		case .Normal:	result = "Normal"
		case .Warning:	result = "Warning"
		case .Error:	result = "Error"
		}
		return result
	}
}

private var mStaticConsole: CNConsole?	= nil
private var mDoVerbose: Bool		= false

public func CNLogSetup(console cons: CNConsole?, doVerbose verb: Bool)
{
	mStaticConsole	= cons
	mDoVerbose	= verb
}

public func CNLog(type typ: CNLogType, message msg: String, place plc: String)
{
	guard typ > .Normal || mDoVerbose else {
		return
	}
	let message = "[\(typ.description)] \(msg) at \(plc)\n"
	if let cons = mStaticConsole {
		cons.print(string: message)
	} else {
		#if os(OSX)
			let fcons = CNFileConsole()
			fcons.print(string: message)
		#else
			 NSLog(message)
		#endif
	}
}

