/**
 * @file	CNProcess.swift
 * @brief	Define CNProcess class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public enum CNProcessStatus {
	case Idle
	case Running
	case Finished
	case Canceled

	public var isRunning: Bool {
		let result: Bool
		switch self {
		case .Idle:	result = false
		case .Running:	result = true
		case .Finished:	result = false
		case .Canceled:	result = false
		}
		return result
	}

	public var isStopped: Bool {
		let result: Bool
		switch self {
		case .Idle:	result = false
		case .Running:	result = false
		case .Finished:	result = true
		case .Canceled:	result = true
		}
		return result
	}
}

public protocol CNProcessProtocol
{
	var 	processManager:	CNProcessManager? { get }
	var 	processId:	Int? { get set }

	var	inputStream: 		CNFileStream { get }
	var	outputStream:		CNFileStream { get }
	var	errorStream:		CNFileStream { get }

	var 	status:			CNProcessStatus { get }
	var	terminationStatus:	Int32 { get }

	func terminate()
}

public extension CNProcessProtocol
{
	var inputFileHandle: FileHandle {
		get { CNFileStream.streamToFileHandle(stream: inputStream, forInside: false, isInput: true) }
	}
	var outputFileHandle: FileHandle {
		get { CNFileStream.streamToFileHandle(stream: outputStream, forInside: false, isInput: false) }
	}
	var errorFileHandle: FileHandle {
		get { CNFileStream.streamToFileHandle(stream: errorStream, forInside: false, isInput: false) }
	}
}

#if os(OSX)

open class CNProcess: CNProcessProtocol
{
	public typealias TerminationHandler	= (_ proc: Process) -> Void

	private weak var mProcessManager:	CNProcessManager?
	private var mProcessId:			Int?
	private var mStatus:			CNProcessStatus
	private var mProcess:			Process
	private var mInputStream:		CNFileStream
	private var mOutputStream:		CNFileStream
	private var mErrorStream:		CNFileStream
	private var mConsole:			CNConsole
	private var mTerminationHandler:	TerminationHandler?

	public var status: 		CNProcessStatus { get { return mStatus 				}}
	public var terminationStatus:	Int32		{ get { return mProcess.terminationStatus	}}

	public var processId: Int? {
		get { return mProcessId }
		set(pid) { mProcessId = pid}
	}

	public var processManager:	CNProcessManager?	{ get { return mProcessManager	}}
	public var inputStream: 	CNFileStream		{ get { return mInputStream	}}
	public var outputStream: 	CNFileStream		{ get { return mOutputStream	}}
	public var errorStream: 	CNFileStream		{ get { return mErrorStream	}}

	public init(processManager mgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNEnvironment, terminationHander termhdlr: TerminationHandler?)
	{
		mProcessManager		= mgr
		mProcessId		= nil
		mStatus			= .Idle
		mProcess		= Process()
		mTerminationHandler	= termhdlr

		mInputStream	= instrm
		mOutputStream	= outstrm
		mErrorStream	= errstrm
		mConsole	= CNFileConsole(input:  CNFileStream.streamToFileHandle(stream: instrm,  forInside: true, isInput: true),
						output: CNFileStream.streamToFileHandle(stream: outstrm, forInside: true, isInput: false),
						error:  CNFileStream.streamToFileHandle(stream: errstrm, forInside: true, isInput: false))

		/* Connect interface with process */
		mProcess.standardInput		= CNFileStream.streamToAny(stream: instrm)
		mProcess.standardOutput		= CNFileStream.streamToAny(stream: outstrm)
		mProcess.standardError		= CNFileStream.streamToAny(stream: errstrm)
		mProcess.environment		= env.stringVariables
		mProcess.currentDirectoryURL	= env.currentDirectory
		mProcess.terminationHandler = {
			[weak self] (process: Process) -> Void in
			if let myself = self {
				/* Update status */
				myself.mStatus = .Finished
				/* Call handler */
				if let handler = myself.mTerminationHandler {
					handler(myself.mProcess)
				}
			}
		}
	}

	deinit {
		/* Remove from parent */
		if let procmgr = mProcessManager {
			procmgr.removeProcess(process: self)
		}
	}

	public func execute(command cmd: String) {
		/* Add to process table */
		if let procmgr = mProcessManager {
			self.processId = procmgr.addProcess(process: self)
		}

		/* Enable secure access */
		let homeurl  = CNPreference.shared.userPreference.homeDirectory
		let issecure = homeurl.startAccessingSecurityScopedResource()

		mStatus			= .Running
		mProcess.launchPath	= "/bin/sh"
		mProcess.arguments	= ["-c", cmd]
		mProcess.launch()

		/* Disable secure access */
		if issecure {
			homeurl.stopAccessingSecurityScopedResource()
		}
	}

	open func terminate() {
		if mProcess.isRunning {
			mProcess.terminate()
		}
	}

	private func closeStreams() {
		if let outpipe = mProcess.standardOutput as? Pipe {
			outpipe.fileHandleForWriting.closeFile()
		}
		if let errpipe = mProcess.standardError as? Pipe {
			errpipe.fileHandleForWriting.closeFile()
		}
	}
}

#endif

