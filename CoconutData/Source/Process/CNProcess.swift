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
	var	console: 	CNFileConsole { get }

	var 	status:			CNProcessStatus { get }
	var	terminationStatus:	Int32 { get }

	func terminate()
}

#if os(OSX)

open class CNProcess: CNProcessProtocol
{
	public typealias TerminationHandler	= (_ proc: Process) -> Void

	private weak var mProcessManager:	CNProcessManager?
	private var mProcessId:			Int?
	private var mStatus:			CNProcessStatus
	private var mProcess:			Process
	private var mConsole:			CNFileConsole
	private var mTerminationHandler:	TerminationHandler?

	public var console:		CNFileConsole	{ get { return mConsole 			}}
	public var status: 		CNProcessStatus { get { return mStatus 				}}
	public var terminationStatus:	Int32		{ get { return mProcess.terminationStatus	}}

	public var processId: Int? {
		get { return mProcessId }
		set(pid) { mProcessId = pid}
	}

	public var processManager:	CNProcessManager?	{ get { return mProcessManager	}}

	public init(processManager mgr: CNProcessManager, input ifile: CNFile, output ofile: CNFile, error efile: CNFile, environment env: CNEnvironment, terminationHander termhdlr: TerminationHandler?)
	{
		mProcessManager		= mgr
		mProcessId		= nil
		mStatus			= .Idle
		mProcess		= Process()
		mTerminationHandler	= termhdlr
		mConsole		= CNFileConsole(input: ifile, output: ofile, error: efile)

		ifile.activateReaderHandler(enable: false)

		mProcess.standardInput		= ifile.fileHandle
		mProcess.standardOutput		= ofile.fileHandle
		mProcess.standardError		= efile.fileHandle
		mProcess.environment		= env.stringVariables
		mProcess.currentDirectoryURL	= env.currentDirectory
		mProcess.terminationHandler = {
			[weak self] (process: Process) -> Void in
			if let myself = self {
				/* Update status */
				myself.mStatus = .Finished
				/* Restore reader handler */
				myself.closeStreams()
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
		mConsole.inputFile.activateReaderHandler(enable: true)
		mConsole.outputFile.closeWritePipe()
		mConsole.errorFile.closeWritePipe()
	}
}

#endif

