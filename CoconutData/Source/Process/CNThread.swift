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

/* The instance of this class will be used as an object in JavaScript context.
 * So this class must inherit NSObject
 */
@objc open class CNThread: NSObject, CNProcessProtocol
{
	private weak var mProcessManager:	CNProcessManager?

	private var mProcessId:			Int?
	private var mSemaphore:			DispatchSemaphore
	private var mInputStream:		CNFileStream
	private var mOutputStream:		CNFileStream
	private var mErrorStream:		CNFileStream
	private var mEnvironment:		CNEnvironment
	private var mConsole:			CNFileConsole
	private var mArgument:			CNNativeValue
	private var mIsRawMode:			Bool?
	private var mIsRunning:			Bool
	private var mIsCancelled:		Bool
	private var mTerminationStatus:		Int32

	public var processId: Int? {
		get { return mProcessId }
		set(pid) { mProcessId = pid}
	}

	public var processManager:	CNProcessManager?	{ get { return mProcessManager	}}
	//public var queue:		DispatchQueue		{ get { return mQueue		}}
	public var inputStream:  	CNFileStream		{ get { return mInputStream	}}
	public var outputStream: 	CNFileStream 		{ get { return mOutputStream	}}
	public var errorStream:  	CNFileStream		{ get { return mErrorStream 	}}
	public var environment:		CNEnvironment		{ get { return mEnvironment	}}
	public var console:      	CNFileConsole		{ get { return mConsole 	}}
	public var isRunning:	 	Bool			{ get { return mIsRunning	}}
	public var isCancelled:		Bool 			{ get { return mIsCancelled	}}

	public init(processManager mgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNEnvironment) {
		mProcessManager		= mgr
		mSemaphore		= DispatchSemaphore(value: 0)
		mInputStream		= instrm
		mOutputStream		= outstrm
		mErrorStream		= errstrm
		mEnvironment		= env
		mArgument		= .nullValue
		mIsRawMode		= mInputStream.isRawMode()
		mIsRunning		= false
		mIsCancelled		= false
		mTerminationStatus	= -1

		mConsole = CNFileConsole(input:  CNFileStream.streamToFileHandle(stream: instrm,  forInside: true, isInput: true),
					 output: CNFileStream.streamToFileHandle(stream: outstrm, forInside: true, isInput: false),
					 error:  CNFileStream.streamToFileHandle(stream: errstrm, forInside: true, isInput: false))

		/* Set raw mode */
		if let israw = mIsRawMode {
			if !israw {
				let _ = mInputStream.setRawMode(enable: true)
			}
		}
	}

	deinit {
		/* Release raw mode */
		if let israw = mIsRawMode {
			if !israw {
				let _ = mInputStream.setRawMode(enable: false)
			}
		}
		/* Remove from parent */
		if let mgr = mProcessManager {
			mgr.removeProcess(process: self)
		}
	}

	public func start(argument arg: CNNativeValue){
		mArgument	= arg
		mIsRunning	= true
		mIsCancelled 	= false

		/* Add to process table */
		if let procmgr = mProcessManager {
			self.processId = procmgr.addProcess(process: self)
		}

		DispatchQueue.global(qos: .background).async {
			() -> Void in
			/* Enable secure access */
			let homeurl  = CNPreference.shared.userPreference.homeDirectory
			let issecure = homeurl.startAccessingSecurityScopedResource()

			/* Execute main */
			self.mTerminationStatus = self.main(argument: self.mArgument)

			/* Disable secure access */
			if issecure {
				homeurl.stopAccessingSecurityScopedResource()
			}

			/* Finalize */
			self.mIsRunning = false
			self.closeStreams()
			self.mSemaphore.signal()
		}
	}

	open func main(argument arg: CNNativeValue) -> Int32 {
		mConsole.error(string: "\(#file): Override this method\n")
		return -1
	}

	open func waitUntilExit() -> Int32 {
		mSemaphore.wait()
		return mTerminationStatus
	}

	open func terminate() {
		if mIsRunning {
			mIsCancelled = true
			mIsRunning   = false
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

