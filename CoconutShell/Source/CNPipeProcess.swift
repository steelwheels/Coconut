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
	private var mProcess:		Process
	private var mInterface:		CNShellInterface
	private var mEnvironment:	CNShellEnvironment
	private var mConsole:		CNConsole
	private var mConfig:		CNConfig
	private var mIsExecuting:	Bool
	private var mIsFinished:		Bool

	public var isExecuting: Bool	{ get { return mIsExecuting	}}
	public var isFinished:  Bool	{ get { return mIsFinished	}}

	public init(interface intf: CNShellInterface, environment env: CNShellEnvironment, console cons: CNConsole, config conf: CNConfig) {
		mProcess	= Process()
		mInterface	= intf
		mEnvironment	= env
		mConsole	= cons
		mConfig		= conf
		mIsExecuting	= false
		mIsFinished	= false

		/* Connect interface */
		mProcess.standardInput	= intf.input
		mProcess.standardOutput	= intf.output
		mProcess.standardError	= intf.error
		mProcess.terminationHandler = {
			[weak self] (process: Process) -> Void in
			if let myself = self {
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

