/**
 * @file	CNLogManager.swift
 * @brief	Extend CNLogManager class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNLogBuffer
{
	public static let shared: CNLogBuffer = CNLogBuffer()

	private var mOutputConsole:	CNConsole?
	private var mLines:		Array<String>
	private var mLock:		NSLock

	private init() {
		mOutputConsole	= nil
		mLines		= []
		mLock		= NSLock()
	}

	public func setOutput(console cons: CNConsole) {
		mLock.lock()
			mOutputConsole = cons
		mLock.unlock()
	}

	public func resetOutput(){
		mLock.lock()
			mOutputConsole = nil
		mLock.unlock()
	}

	public func log(logLevel level: CNConfig.LogLevel, message msg: String){
		let curlvl = CNPreference.shared.systemPreference.logLevel
		if level.isIncluded(in: curlvl) {
			mLock.lock()
			mLines.append(msg)
			if let cons = mOutputConsole {
				for line in mLines {
					cons.print(string: line + "\n")
				}
				mLines = []
			}
			mLock.unlock()
		}
	}

	public func log(logLevel level: CNConfig.LogLevel, messages msgs: Array<String>){
		let curlvl = CNPreference.shared.systemPreference.logLevel
		if level.isIncluded(in: curlvl) {
			mLock.lock()
			mLines.append(contentsOf: msgs)
			if let cons = mOutputConsole {
				for line in mLines {
					cons.print(string: line + "\n")
				}
				mLines = []
			}
			mLock.unlock()
		}
	}
}


public func CNLog(logLevel level: CNConfig.LogLevel, message msg: String)
{
	CNLogBuffer.shared.log(logLevel: level, message: msg)
}

public func CNLog(logLevel level: CNConfig.LogLevel, messages msgs: Array<String>)
{
	CNLogBuffer.shared.log(logLevel: level, messages: msgs)
}


