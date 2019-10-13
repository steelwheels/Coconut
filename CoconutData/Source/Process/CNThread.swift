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

open class CNThread: Thread
{
	public typealias TerminationHandler	= (_ thread: Thread) -> Int32

	public enum Status {
		case Idle
		case Running
		case Finished
	}

	private var mStatus:			Status
	private var mInputHandle:		FileHandle
	private var mOutputHandle:		FileHandle
	private var mErrorHandle:		FileHandle
	private var mConsole:			CNFileConsole
	private var mTerminationStatus:		Int32
	private var mTerminationHandler:	TerminationHandler?

	public var status: Status 			{ get { return mStatus			}}
	public var inputFileHandle:  FileHandle		{ get { return mInputHandle		}}
	public var outputFileHandle: FileHandle		{ get { return mOutputHandle		}}
	public var errorFileHandle:  FileHandle		{ get { return mErrorHandle		}}
	open   var terminationStatus:	Int32	    	{ get { return mTerminationStatus	}}
	public var console:    CNFileConsole		{ get { return mConsole 		}}

	public init(input inhdl: FileHandle, output outhdl: FileHandle, error errhdl: FileHandle, terminationHander termhdlr: TerminationHandler?) {
		mStatus			= .Idle
		mInputHandle		= inhdl
		mOutputHandle		= outhdl
		mErrorHandle		= errhdl
		mConsole		= CNFileConsole(input: inhdl, output: outhdl, error: errhdl)
		mTerminationStatus	= -1
		mTerminationHandler	= termhdlr
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
		/* Close files */
		if mOutputHandle != FileHandle.standardOutput {
			mOutputHandle.closeFile()
		}
		if mErrorHandle != FileHandle.standardError {
			mErrorHandle.closeFile()
		}
	}

	open func mainOperation() -> Int32 {
		NSLog("Override this method")
		return 1
	}

	public func waitUntilExit() {
		while self.status == .Running {
			usleep(100)	// 100us = 0.1ms
		}
	}

	public func set(console cons: CNFileConsole) {
		mInputHandle	= cons.inputHandle
		mOutputHandle	= cons.outputHandle
		mErrorHandle	= cons.errorHandle
		mConsole	= CNFileConsole(input: mInputHandle, output: mOutputHandle, error: mErrorHandle)
	}
}

