/**
 * @file	CNLogManager.swift
 * @brief	Extend CNLogManager class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

@objc open class CNLogManager: NSObject
{
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
						console.print(string: "\(#file) Update log level: \(newlevel.description)\n")
					}
				}
			}
		default:
			NSLog("oV: \(String(describing: keyPath))")
		}
	}
}
