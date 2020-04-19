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

open class CNThread: CNProcessProtocol
{
	private var mQueue:			DispatchQueue
	private var mSemaphore:			DispatchSemaphore
	private var mInputStream:		CNFileStream
	private var mOutputStream:		CNFileStream
	private var mErrorStream:		CNFileStream
	private var mEnvironment:		CNEnvironment
	private var mConsole:			CNFileConsole
	private var mArguments:			Array<CNNativeValue>
	private var mIsRunning:			Bool
	private var mIsCancelled:		Bool
	private var mTerminationStatus:		Int32

	public var queue:		DispatchQueue	{ get { return mQueue		}}
	public var inputStream:  	CNFileStream	{ get { return mInputStream	}}
	public var outputStream: 	CNFileStream 	{ get { return mOutputStream	}}
	public var errorStream:  	CNFileStream	{ get { return mErrorStream 	}}
	public var environment:		CNEnvironment	{ get { return mEnvironment	}}
	public var console:      	CNFileConsole	{ get { return mConsole 	}}
	public var isRunning:	 	Bool		{ get { return mIsRunning	}}
	public var isCancelled:		Bool 		{ get { return mIsCancelled	}}

	public init(queue disque: DispatchQueue, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNEnvironment) {
		mQueue			= disque
		mSemaphore		= DispatchSemaphore(value: 0)
		mInputStream		= instrm
		mOutputStream		= outstrm
		mErrorStream		= errstrm
		mEnvironment		= env
		mArguments		= []
		mIsRunning		= false
		mIsCancelled		= false
		mTerminationStatus	= -1

		mConsole = CNFileConsole(input:  CNFileStream.streamToFileHandle(stream: instrm,  forInside: true, isInput: true),
					 output: CNFileStream.streamToFileHandle(stream: outstrm, forInside: true, isInput: false),
					 error:  CNFileStream.streamToFileHandle(stream: errstrm, forInside: true, isInput: false))

		/* Set raw mode */
		let _ = self.inputStream.setRawMode(enable: true)
	}

	deinit {
		/* Release raw mode */
		let _ = self.inputStream.setRawMode(enable: false)
	}

	public func start(arguments args: Array<CNNativeValue>){
		mArguments	= args
		mIsRunning	= true
		mIsCancelled 	= false
		mQueue.async {
			/* Enable secure access */
			let homeurl  = CNPreference.shared.userPreference.homeDirectory
			let issecure = homeurl.startAccessingSecurityScopedResource()

			/* Execute main */
			self.mTerminationStatus = self.main(arguments: self.mArguments)

			/* Finalize */
			self.mIsRunning = false
			self.closeStreams()
			self.mSemaphore.signal()

			/* Disable secure access */
			if issecure {
				homeurl.stopAccessingSecurityScopedResource()
			}
		}
	}

	open func main(arguments args: Array<CNNativeValue>) -> Int32 {
		mConsole.error(string: "\(#file): Override this method\n")
		return -1
	}

	public func waitUntilExit() -> Int32 {
		mSemaphore.wait()
		return mTerminationStatus
	}

	public func terminate() {
		if mIsRunning {
			mIsCancelled = true
		}
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

