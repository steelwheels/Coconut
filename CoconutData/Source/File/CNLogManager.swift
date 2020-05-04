/**
 * @file	CNLogManager.swift
 * @brief	Extend CNLogManager class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

open class CNLogManager
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

	public init() {
		mInputPipe	= Pipe()
		mOutputPipe	= Pipe()
		mErrorPipe	= Pipe()
		mConsole	= CNFileConsole(input:  mInputPipe.fileHandleForReading,
						output: mOutputPipe.fileHandleForWriting,
						error:  mErrorPipe.fileHandleForWriting)
		mOutputConsole	= nil
		mLock		= NSLock()
		mText		= []

		mOutputPipe.fileHandleForReading.readabilityHandler = {
			(_ hdl: FileHandle) -> Void in
			if let str = String(data: hdl.availableData, encoding: .utf8) {
				self.mLock.lock()
					self.mText.append(.normal(str))
					self.flush()
				self.mLock.unlock()
			}
		}
		mErrorPipe.fileHandleForReading.readabilityHandler = {
			(_ hdl: FileHandle) -> Void in
			if let str = String(data: hdl.availableData, encoding: .utf8) {
				self.mLock.lock()
					self.mText.append(.error(str))
					self.flush()
				self.mLock.unlock()
			}
		}
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
}
