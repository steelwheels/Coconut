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

/*


@objc open class CNLogManager: NSObject
{
	public typealias LogLevel = CNConfig.LogLevel

	private enum Message {
		case normal(String)
		case error(String)
	}

	private var mInputPipe:		Pipe
	private var mOutputPipe:	Pipe
	private var mErrorPipe:		Pipe
	private var mConsole:		CNFileConsole
	private var mOutputConsole:	CNConsole?
	private var mLock:		NSLock
	private var mText:		Array<Message>

	public var console: CNFileConsole { get { return mConsole }}

	public override init() {
		mInputPipe	= Pipe()
		mOutputPipe	= Pipe()
		mErrorPipe	= Pipe()
		mConsole	= CNFileConsole(input:  mInputPipe.fileHandleForReading,
						output: mOutputPipe.fileHandleForWriting,
						error:  mErrorPipe.fileHandleForWriting)
		mOutputConsole	= nil
		mLock		= NSLock()
		mText		= []
		super.init()

		mOutputPipe.fileHandleForReading.readabilityHandler = {
			(_ hdl: FileHandle) -> Void in
			if let str = String.stringFromData(data: hdl.availableData) {
				self.mLock.lock()
					self.mText.append(.normal(str))
					self.flush()
				self.mLock.unlock()
			}
		}
		mErrorPipe.fileHandleForReading.readabilityHandler = {
			(_ hdl: FileHandle) -> Void in
			if let str = String.stringFromData(data: hdl.availableData) {
				self.mLock.lock()
					self.mText.append(.error(str))
					self.flush()
				self.mLock.unlock()
			}
		}

		/* Observe LogLevel item */
		let syspref = CNPreference.shared.systemPreference
		syspref.addObserver(observer: self, forKey: CNSystemPreference.LogLevelItem)
	}

	public func setOutput(console cons: CNConsole?) {
		self.mLock.lock()
			mOutputConsole = cons
		self.mLock.unlock()
	}

	private func flush() {
		if let out = mOutputConsole {
			for message in mText {
				switch message {
				case .normal(let str):
					out.print(string: str)
				case .error(let str):
					out.error(string: str)
				}
			}
			mText = []
		}
	}

	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		switch keyPath {
		case CNSystemPreference.LogLevelItem:
			if let vals = change {
				if let newval = vals[.newKey] as? Int {
					if let newlevel = CNSystemPreference.LogLevel(rawValue: newval) {
						updateLogLevel(logLevel: newlevel)
					}
				}
			}
		default:
			NSLog("oV: \(String(describing: keyPath))")
		}
	}

	/* Override this method */
	open func updateLogLevel(logLevel lvl: LogLevel) {
		console.print(string: "\(#file) Update log level: \(lvl.description)\n")
	}
}

*/

