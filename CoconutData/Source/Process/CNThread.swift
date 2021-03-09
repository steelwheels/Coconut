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

public enum CNUserThreadLevel {
	case	thread
	case	event
}

public func CNExecuteInUserThread(level lvl: CNUserThreadLevel, execute exec: @escaping () -> Void){
	let qos: DispatchQoS.QoSClass
	switch lvl {
	case .thread:	qos = .utility
	case .event:	qos = .userInitiated
	}
	DispatchQueue.global(qos: qos).async {
		exec()
	}
}

@objc open class CNThread: NSObject, CNProcessProtocol
{
	private weak var mProcessManager:	CNProcessManager?

	private var mProcessId:			Int?
	private var mInputStream:		CNFileStream
	private var mOutputStream:		CNFileStream
	private var mErrorStream:		CNFileStream
	private var mEnvironment:		CNEnvironment
	private var mConsole:			CNFileConsole
	private var mArgument:			CNNativeValue
	private var mStatus:			CNProcessStatus
	private var mTerminationStatus:		Int32

	public var processId: Int? {
		get { return mProcessId }
		set(pid) { mProcessId = pid}
	}

	public var processManager:	CNProcessManager?	{ get { return mProcessManager	}}
	public var inputStream:  	CNFileStream		{ get { return mInputStream	}}
	public var outputStream: 	CNFileStream 		{ get { return mOutputStream	}}
	public var errorStream:  	CNFileStream		{ get { return mErrorStream 	}}
	public var environment:		CNEnvironment		{ get { return mEnvironment	}}
	public var console:      	CNFileConsole		{ get { return mConsole 	}}
	public var status:		CNProcessStatus		{ get { return mStatus		}}

	public var terminationStatus:	Int32			{ get { return mTerminationStatus	}}

	public init(processManager mgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNEnvironment) {
		mProcessManager		= mgr
		mInputStream		= instrm
		mOutputStream		= outstrm
		mErrorStream		= errstrm
		mEnvironment		= env
		mArgument		= .nullValue
		mStatus			= .Idle
		mTerminationStatus	= -1

		mConsole = CNFileConsole(input:  CNFileStream.streamToFileHandle(stream: instrm,  forInside: true, isInput: true),
					 output: CNFileStream.streamToFileHandle(stream: outstrm, forInside: true, isInput: false),
					 error:  CNFileStream.streamToFileHandle(stream: errstrm, forInside: true, isInput: false))
	}

	deinit {
		/* Remove from parent */
		if let mgr = mProcessManager {
			mgr.removeProcess(process: self)
		}
	}

	public func start(argument arg: CNNativeValue){
		mArgument	= arg
		mStatus		= .Running

		/* Add to process table */
		if let procmgr = mProcessManager {
			self.processId = procmgr.addProcess(process: self)
		}

		CNExecuteInUserThread(level: .thread, execute: {
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
			self.closeStreams()
			switch self.mStatus {
			case .Running:
				self.mStatus = .Finished
			default:
				break
			}
		})
	}

	open func main(argument arg: CNNativeValue) -> Int32 {
		mConsole.error(string: "\(#file): Override this method\n")
		return -1
	}

	open func terminate() {
		switch mStatus {
		case .Running:
			mStatus = .Canceled
		default:
			break
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

