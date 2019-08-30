/*
 * @file	CNShellCommand.swift
 * @brief	Define KLShell class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

#if os(OSX)

import CoconutData
import Foundation

public class CNPipeProcess
{
	public typealias FileAccessHandler	= (_ hdl:  FileHandle) -> Void
	public typealias TerminationHandler	= (_ proc: Process) -> Void

	private var mProcess:			Process
	private var mEnvironment:		CNShellEnvironment
	private var mConsole:			CNConsole
	private var mConfig:			CNConfig
	private var mIsExecuting:		Bool
	private var mIsFinished:		Bool
	private var mInterface:			CNShellInterface
	private var mPrevInputWriter:		FileAccessHandler?
	private var mTerminationHandler:	TerminationHandler?

	public var isExecuting: Bool	{ get { return mIsExecuting	}}
	public var isFinished:  Bool	{ get { return mIsFinished	}}

	public var core: Process { get { return mProcess }}

	public init(interface intf: CNShellInterface, environment env: CNShellEnvironment, console cons: CNConsole, config conf: CNConfig, terminationHander termhdlr: TerminationHandler?) {
		mProcess		= Process()
		mInterface		= intf
		mEnvironment		= env
		mConsole		= cons
		mConfig			= conf
		mIsExecuting		= false
		mIsFinished		= false
		mTerminationHandler	= termhdlr

		/* Keep original handler */
		mPrevInputWriter = intf.input.fileHandleForWriting.writeabilityHandler

		/* Connect input */
		let inpipe		= Pipe()
		intf.input.fileHandleForWriting.writeabilityHandler = {
			[weak self]  (_ hdl: FileHandle) -> Void in
			if let myself = self {
				let data = hdl.availableData
				myself.mInterface.output.write(data: data)
			}
		}
		/* Connect output */
		let outpipe		= Pipe()
		outpipe.fileHandleForReading.readabilityHandler = {
			[weak self] (_ hdl: FileHandle) -> Void in
			if let myself = self {
				let data = hdl.availableData
				myself.mInterface.output.write(data: data)
			}
		}
		/* Connect error */
		let errpipe		= Pipe()
		errpipe.fileHandleForReading.readabilityHandler = {
			[weak self] (_ hdl: FileHandle) -> Void in
			if let myself = self {
				let data = hdl.availableData
				myself.mInterface.error.write(data: data)
			}
		}

		/* Connect interface with process */
		mProcess.standardInput	= inpipe
		mProcess.standardOutput	= outpipe
		mProcess.standardError	= errpipe
		mProcess.terminationHandler = {
			[weak self] (process: Process) -> Void in
			if let myself = self {
				/* Reset connection */
				myself.mInterface.input.fileHandleForWriting.writeabilityHandler = myself.mPrevInputWriter
				/* Detach pipes */
				if let inpipe  = process.standardInput as? Pipe {
					inpipe.fileHandleForWriting.writeabilityHandler = nil
				}
				if let outpipe = process.standardOutput as? Pipe {
					outpipe.fileHandleForReading.readabilityHandler = nil
				}
				if let errpipe = process.standardError as? Pipe {
					errpipe.fileHandleForReading.readabilityHandler = nil
				}
				/* Update status */
				myself.mIsExecuting	= false
				myself.mIsFinished	= true
				/* Call handler */
				if let handler = myself.mTerminationHandler {
					handler(myself.mProcess)
				}
			}
		}
	}

	public func execute(command cmd: String) {
		mIsExecuting		= true
		mIsFinished		= false
		mProcess.launchPath	= "/bin/sh"
		mProcess.arguments	= ["-c", cmd]
		mProcess.launch()
	}

	public func waitUntilExit() {
		if mIsExecuting {
			mProcess.waitUntilExit()
		}
	}
}

#endif // os(OSX)

