/**
 * @file	CNProcess.swift
 * @brief	Define CNProcess class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

#if os(OSX)

open class CNProcess
{
	public typealias TerminationHandler	= (_ proc: Process) -> Void

	public enum Status {
		case Idle
		case Running
		case Finished
	}

	private var mStatus:			Status
	private var mProcess:			Process
	private var mConsole:			CNConsole
	private var mTerminationHandler:	TerminationHandler?

	public var status: Status { get { return mStatus }}

	public var inputFileHandle: 	FileHandle  { get { return force(fileHandle: mProcess.standardInput) 	}}
	public var outputFileHandle:	FileHandle  { get { return force(fileHandle: mProcess.standardOutput)	}}
	public var errorFileHandle:	FileHandle  { get { return force(fileHandle: mProcess.standardError) 	}}
	open   var terminationStatus:	Int32	    { get { return mProcess.terminationStatus			}}

	public init(input inhdl: FileHandle, output outhdl: FileHandle, error errhdl: FileHandle, terminationHander termhdlr: TerminationHandler?) {
		mStatus			= .Idle
		mProcess		= Process()
		mConsole		= CNFileConsole(input: inhdl, output: outhdl, error: errhdl)
		mTerminationHandler	= termhdlr

		/* Connect interface with process */
		mProcess.standardInput	= inhdl
		mProcess.standardOutput	= outhdl
		mProcess.standardError	= errhdl
		mProcess.terminationHandler = {
			[weak self] (process: Process) -> Void in
			if let myself = self {
				/* Update status */
				myself.mStatus = .Finished
				/* Call handler */
				if let handler = myself.mTerminationHandler {
					handler(myself.mProcess)
				}
				/* Close outputs */
				if let file = myself.mProcess.standardOutput as? FileHandle {
					if file != FileHandle.standardOutput {
						file.closeFile()
					}
				}
				if let file = myself.mProcess.standardError as? FileHandle {
					if file != FileHandle.standardError {
						file.closeFile()
					}
				}
			}
		}
	}

	private func force(fileHandle hdl: Any?) -> FileHandle {
		if let hdl = hdl as? FileHandle {
			return hdl
		} else {
			fatalError("can not happen")
		}
	}

	public func execute(command cmd: String) {
		mStatus			= .Running
		mProcess.launchPath	= "/bin/sh"
		mProcess.arguments	= ["-c", cmd]
		mProcess.launch()
	}

	public func waitUntilExit() {
		switch mStatus {
		case .Idle, .Finished:
			break
		case .Running:
			mProcess.waitUntilExit()
		}
	}
}

#endif

