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

open class CNThread: Thread, CNProcessStream
{
	public typealias TerminationHandler	= (_ thread: Thread) -> Int32

	public enum Status {
		case Idle
		case Running
		case Finished
	}

	private var mStatus:			Status
	private var mInputStream:		CNFileStream
	private var mOutputStream:		CNFileStream
	private var mErrorStream:		CNFileStream
	private var mConsole:			CNFileConsole
	private var mTerminationStatus:		Int32
	private var mTerminationHandler:	TerminationHandler?

	public var status: Status 			{ get { return mStatus			}}
	open   var terminationStatus:	Int32	    	{ get { return mTerminationStatus	}}
	public var console:    CNFileConsole		{ get { return mConsole 		}}

	public var inputStream:  CNFileStream { get { return mInputStream	}}
	public var outputStream: CNFileStream { get { return mOutputStream	}}
	public var errorStream:  CNFileStream { get { return mErrorStream 	}}

	public init(input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, terminationHander termhdlr: TerminationHandler?) {
		mStatus			= .Idle
		mInputStream		= instrm
		mOutputStream		= outstrm
		mErrorStream		= errstrm
		mTerminationStatus	= -1
		mTerminationHandler	= termhdlr

		mConsole = CNFileConsole(input:  CNFileStream.streamToFileHandle(stream: instrm,  forInside: true, isInput: true),
					 output: CNFileStream.streamToFileHandle(stream: outstrm, forInside: true, isInput: false),
					 error:  CNFileStream.streamToFileHandle(stream: errstrm, forInside: true, isInput: false))

		super.init()
	}

	open override func start() {
		/* Update status */
		mStatus = .Running
		/* Start process */
		super.start()
	}

	open override func main(){
		/* Execute main operation */
		self.mTerminationStatus = mainOperation()
		/* Execution finished */
		if let hdlr = mTerminationHandler {
			self.mTerminationStatus = hdlr(self)
		}
		/* Update status */
		mStatus = .Finished
	}

	open func mainOperation() -> Int32 {
		NSLog("Override this method")
		return 1
	}

	public func waitUntilExit() -> Int32 {
		while self.status == .Running {
			usleep(100)	// 100us = 0.1ms
		}
		closeStreams()
		return mTerminationStatus
	}

	private func closeStreams() {
		switch mOutputStream {
		case .null:		break
		case .fileHandle(_):	break
		case .pipe(let pipe):	pipe.fileHandleForWriting.closeFile()
		}
		switch mErrorStream {
		case .null:		break
		case .fileHandle(_):	break
		case .pipe(let pipe):	pipe.fileHandleForWriting.closeFile()
		}
	}

	/*
	public func set(console cons: CNFileConsole) {
		mInputHandle	= cons.inputHandle
		mOutputHandle	= cons.outputHandle
		mErrorHandle	= cons.errorHandle
		mConsole	= CNFileConsole(input: mInputHandle, output: mOutputHandle, error: mErrorHandle)
	}*/
}

