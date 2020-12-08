/**
 * @file	CNLogBuffer.swift
 * @brief	Define CNLogBuffer class
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

	public func log(logLevel level: CNConfig.LogLevel, messages msgs: Array<String>){
		let curlvl = CNPreference.shared.systemPreference.logLevel
		if curlvl.isIncluded(in: level) {
			mLock.lock()
			if let cons = mOutputConsole {
				putLines(console: cons, lines: mLines)
				putLines(console: cons, lines: msgs)
				mLines = []
			} else {
				mLines.append(contentsOf: msgs)
			}
			mLock.unlock()
		}
	}

	public func flush() {
		mLock.lock()
		if let cons = mOutputConsole {
			if mLines.count > 0 {
				putLines(console: cons, lines: mLines)
				mLines = []
			}
		}
		mLock.unlock()
	}

	private func putLines(console cons: CNConsole, lines lns: Array<String>) {
		if lns.count > 0 {
			let str = lns.joined(separator: "\n") + "\n"
			cons.print(string: str)
		}
	}
}


public func CNLog(logLevel level: CNConfig.LogLevel, message msg: String)
{
	CNLogBuffer.shared.log(logLevel: level, messages: [msg])
}

public func CNLog(logLevel level: CNConfig.LogLevel, messages msgs: Array<String>)
{
	CNLogBuffer.shared.log(logLevel: level, messages: msgs)
}

public func CNLog(logLevel level: CNConfig.LogLevel, text txt: CNText)
{
	let lines = txt.toStrings(terminal: "")
	CNLogBuffer.shared.log(logLevel: level, messages: lines)
}

