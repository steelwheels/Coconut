/**
 * @file	CNLogBuffer.swift
 * @brief	Define CNLogBuffer class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNLogManager
{
	public static var shared	= CNLogManager()

	private var mConsole:		CNConsole
	private var mConsoleStack:	CNStack<CNConsole>

	private init(){
		mConsole 	= CNDefaultConsole()
		mConsoleStack	= CNStack()
	}

	public var console: CNConsole {
		get {
			if let cons = mConsoleStack.peek() {
				return cons
			} else {
				return mConsole
			}
		}
	}

	public func pushConsone(console cons: CNConsole){
		mConsoleStack.push(cons)
	}

	public func popConsole(){
		let _ = mConsoleStack.pop()
	}

	public func log(logLevel level: CNConfig.LogLevel, message msg: String){
		let curlvl = CNPreference.shared.systemPreference.logLevel
		let cons   = self.console
		if curlvl.isIncluded(in: level) {
			switch level {
			case .nolog:
				break
			case .user:
				cons.print(string: msg + "\n")
			case .error:
				cons.error(string: "[Error  ] " + msg + "\n")
			case .warning:
				cons.error(string: "[Warning] " + msg + "\n")
			case .debug:
				cons.print(string: "[Debug  ] " + msg + "\n")
			case .detail:
				cons.print(string: "[Message] " + msg + "\n")
			}
		}
	}
}

public func CNLog(logLevel level: CNConfig.LogLevel, message msg: String)
{
	CNLogManager.shared.log(logLevel: level, message: msg)
}

public func CNLog(logLevel level: CNConfig.LogLevel, message msg: String, atFunction afunc: String, inFile ifile: String)
{
	let newmsg = msg + " at " + afunc + " in " + ifile
	CNLog(logLevel: level, message: newmsg)
}

public func CNLog(logLevel level: CNConfig.LogLevel, messages msgs: Array<String>)
{
	let msg = msgs.joined(separator: "\n")
	CNLog(logLevel: level, message: msg)
}

public func CNLog(logLevel level: CNConfig.LogLevel, text txt: CNText)
{
	let lines = txt.toStrings()
	CNLog(logLevel: level, messages: lines)
}
