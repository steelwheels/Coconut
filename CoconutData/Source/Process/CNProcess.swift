/**
 * @file	CNProcess.swift
 * @brief	Define CNProcess class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public protocol CNProcessProtocol
{
	var 	processManager:	CNProcessManager? { get }
	var 	processId:	Int? { get set }

	var	inputStream: 	CNFileStream { get }
	var	outputStream:	CNFileStream { get }
	var	errorStream:	CNFileStream { get }

	var 	isRunning:	Bool { get }

	func terminate()
	func waitUntilExit() -> Int32
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

	public enum Status {
		case Idle
		case Running
		case Finished
	}

	private weak var mProcessManager:	CNProcessManager?
	private var mProcessId:			Int?
	private var mStatus:			Status
	private var mProcess:			Process
	private var mInputStream:		CNFileStream
	private var mOutputStream:		CNFileStream
	private var mErrorStream:		CNFileStream
	private var mConsole:			CNConsole
	private var mTerminationHandler:	TerminationHandler?

	public var status: 		Status 		{ get { return mStatus 				}}
	open   var terminationStatus:	Int32		{ get { return mProcess.terminationStatus	}}

	public var processId: Int? {
		get { return mProcessId }
		set(pid) { mProcessId = pid}
	}

	public var processManager:	CNProcessManager?	{ get { return mProcessManager	}}
	public var inputStream: 	CNFileStream		{ get { return mInputStream	}}
	public var outputStream: 	CNFileStream		{ get { return mOutputStream	}}
	public var errorStream: 	CNFileStream		{ get { return mErrorStream	}}

	public var isRunning: Bool		{ get { return mStatus == .Running 	}}

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
		mProcess.environment		= env.variables
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

	public func waitUntilExit() -> Int32 {
		let result: Int32
		switch mStatus {
		case .Idle, .Finished:
			result = mProcess.terminationStatus
		case .Running:
			mProcess.waitUntilExit()
			closeStreams()
			result = mProcess.terminationStatus
		}
		return result
	}

	public func terminate() {
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

