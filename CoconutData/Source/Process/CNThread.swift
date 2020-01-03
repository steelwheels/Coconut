/**
 * @file	CNThread.swift
 * @brief	Define functions to operate threads
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public func CNExecuteInMainThread(doSync sync: Bool, execute exec: @escaping () -> Void){
	if Thread.isMainThread {
		exec()
	} else {
		if sync {
			DispatchQueue.main.sync(execute: exec)
		} else {
			DispatchQueue.main.async(execute: exec)
		}
	}
}

open class CNThread: CNProcessStream
{
	private var mQueue:			DispatchQueue
	private var mSemaphore:			DispatchSemaphore
	private var mInputStream:		CNFileStream
	private var mOutputStream:		CNFileStream
	private var mErrorStream:		CNFileStream
	private var mConsole:			CNFileConsole
	private var mConfig:			CNConfig
	private var mArguments:			Array<CNNativeValue>
	private var mIsRunning:			Bool
	private var mTerminationStatus:		Int32

	public var queue:		DispatchQueue	{ get { return mQueue		}}
	public var inputStream:  	CNFileStream	{ get { return mInputStream	}}
	public var outputStream: 	CNFileStream 	{ get { return mOutputStream	}}
	public var errorStream:  	CNFileStream	{ get { return mErrorStream 	}}
	public var console:      	CNFileConsole	{ get { return mConsole 	}}
	public var config:		CNConfig 	{ get { return mConfig 		}}
	public var isRunning:	 	Bool		{ get { return mIsRunning	}}

	public init(queue disque: DispatchQueue, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, config conf: CNConfig) {
		mQueue			= disque
		mSemaphore		= DispatchSemaphore(value: 0)
		mInputStream		= instrm
		mOutputStream		= outstrm
		mErrorStream		= errstrm
		mConfig			= conf
		mArguments		= []
		mIsRunning		= false
		mTerminationStatus	= -1

		mConsole = CNFileConsole(input:  CNFileStream.streamToFileHandle(stream: instrm,  forInside: true, isInput: true),
					 output: CNFileStream.streamToFileHandle(stream: outstrm, forInside: true, isInput: false),
					 error:  CNFileStream.streamToFileHandle(stream: errstrm, forInside: true, isInput: false))

	}

	public func start(arguments args: Array<CNNativeValue>){
		log(string: "start/start")
		mArguments = args
		mIsRunning = true
		mQueue.async {
			self.log(string: "start/async/start")
			self.mTerminationStatus = self.main(arguments: self.mArguments)
			self.closeStreams()
			self.mSemaphore.signal()
			self.mIsRunning = false
			self.log(string: "main/async/end")
		}
		log(string: "start/done")
	}

	open func main(arguments args: Array<CNNativeValue>) -> Int32 {
		mConsole.error(string: "Override this method\n")
		return -1
	}

	public func waitUntilExit() -> Int32 {
		log(string: "waitUntilExit/start")
		mSemaphore.wait()
		log(string: "waitUntilExit/done")
		return mTerminationStatus
	}

	private func closeStreams() {
		switch mOutputStream {
		case .pipe(let pipe):
			pipe.fileHandleForWriting.closeFile()
		case .fileHandle(_), .null:
			break	// Do nothing
		}
		switch mErrorStream {
		case .pipe(let pipe):
			pipe.fileHandleForWriting.closeFile()
		case .fileHandle(_), .null:
			break	// Do nothing
		}
	}

	public func log(string str: String) {
		switch mConfig.logLevel {
		case .detail:
			let name = String(describing: type(of: self))
			mConsole.print(string: "[\(name)] \(str)\n")
		case .flow, .error, .warning:
			break
		}
	}
}

