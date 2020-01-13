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
	private var mArguments:			Array<CNNativeValue>
	private var mIsRunning:			Bool
	private var mTerminationStatus:		Int32

	public var queue:		DispatchQueue	{ get { return mQueue		}}
	public var inputStream:  	CNFileStream	{ get { return mInputStream	}}
	public var outputStream: 	CNFileStream 	{ get { return mOutputStream	}}
	public var errorStream:  	CNFileStream	{ get { return mErrorStream 	}}
	public var console:      	CNFileConsole	{ get { return mConsole 	}}
	public var isRunning:	 	Bool		{ get { return mIsRunning	}}

	public init(queue disque: DispatchQueue, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream) {
		mQueue			= disque
		mSemaphore		= DispatchSemaphore(value: 0)
		mInputStream		= instrm
		mOutputStream		= outstrm
		mErrorStream		= errstrm
		mArguments		= []
		mIsRunning		= false
		mTerminationStatus	= -1

		mConsole = CNFileConsole(input:  CNFileStream.streamToFileHandle(stream: instrm,  forInside: true, isInput: true),
					 output: CNFileStream.streamToFileHandle(stream: outstrm, forInside: true, isInput: false),
					 error:  CNFileStream.streamToFileHandle(stream: errstrm, forInside: true, isInput: false))

	}

	public func start(arguments args: Array<CNNativeValue>){
		mArguments = args
		mIsRunning = true
		mQueue.async {
			self.mTerminationStatus = self.main(arguments: self.mArguments)
			self.closeStreams()
			self.mSemaphore.signal()
			self.mIsRunning = false
		}
	}

	open func main(arguments args: Array<CNNativeValue>) -> Int32 {
		mConsole.error(string: "Override this method\n")
		return -1
	}

	public func waitUntilExit() -> Int32 {
		mSemaphore.wait()
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
}

