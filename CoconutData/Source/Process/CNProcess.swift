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

	private var mIsStarted:			Bool
	private var mProcess:			Process
	private var mConsole:			CNConsole
	private var mTerminationHandler:	TerminationHandler?

	public var status: Status { get {
		if !mIsStarted {
			return .Idle
		} else if mProcess.isRunning {
			return .Running
		} else {
			return .Finished
		}
	}}

	public var inputFileHandle: 	FileHandle  { get { return force(fileHandle: mProcess.standardInput) 	}}
	public var outputFileHandle:	FileHandle  { get { return force(fileHandle: mProcess.standardOutput)	}}
	public var errorFileHandle:	FileHandle  { get { return force(fileHandle: mProcess.standardError) 	}}
	open   var terminationStatus:	Int32	    { get { return mProcess.terminationStatus			}}

	public var core:		Process     { get { return mProcess					}}

	public init(input inhdl: FileHandle, output outhdl: FileHandle, error errhdl: FileHandle, terminationHander termhdlr: TerminationHandler?) {
		mIsStarted		= false
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
				/* Call handler */
				if let handler = myself.mTerminationHandler {
					handler(myself.mProcess)
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
		mIsStarted		= true
		mProcess.launchPath	= "/bin/sh"
		mProcess.arguments	= ["-c", cmd]
		mProcess.launch()
	}

	public func waitUntilExit() {
		mProcess.waitUntilExit()
	}
}

#endif

