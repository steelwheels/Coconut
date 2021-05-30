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

	private var mConsole:	CNConsole
	private var mLevel:	CNConfig.LogLevel

	private init(){
		mConsole = CNDefaultConsole()
		mLevel	 = .warning
	}

	public func log(logLevel level: CNConfig.LogLevel, message msg: String){
		let curlvl = CNPreference.shared.systemPreference.logLevel
		if curlvl.isIncluded(in: level) {
			switch level {
			case .nolog:
				break
			case .error:
				mConsole.error(string: "[Error  ] " + msg)
			case .warning:
				mConsole.error(string: "[Warning] " + msg)
			case .debug:
				mConsole.print(string: "[Debug  ] " + msg)
			case .detail:
				mConsole.print(string: "[Message] " + msg)
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
	var lines: String = ""
	for msg in msgs {
		lines += msg + "\n"
	}
	CNLogManager.shared.log(logLevel: level, message: lines)
}

public func CNLog(logLevel level: CNConfig.LogLevel, text txt: CNText)
{
	let lines = txt.toStrings(terminal: "")
	CNLog(logLevel: level, messages: lines)
}
