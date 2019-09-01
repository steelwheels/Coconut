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
	private var mIsStarted:			Bool
	private var mIsFinished:		Bool
	private var mInterface:			CNShellInterface
	private var mTerminationHandler:	TerminationHandler?

	public var isFinished:  Bool	{ get { return mIsFinished	}}

	public var core: Process { get { return mProcess }}

	public init(interface parent: CNShellInterface, environment env: CNShellEnvironment, console cons: CNConsole, config conf: CNConfig, terminationHander termhdlr: TerminationHandler?) {
		mProcess		= Process()
		mInterface		= CNShellInterface()
		mEnvironment		= env
		mConsole		= cons
		mConfig			= conf
		mIsStarted		= false
		mIsFinished		= false
		mTerminationHandler	= termhdlr

		mInterface.connectInput(from: parent.input)
		mInterface.connectOutput(to: parent.output)
		mInterface.connectError(to: parent.error)

		/* Connect interface with process */
		mProcess.standardInput	= mInterface.input
		mProcess.standardOutput	= mInterface.output
		mProcess.standardError	= mInterface.error
		mProcess.terminationHandler = {
			[weak self] (process: Process) -> Void in
			if let myself = self {
				/* Reset connection */
				myself.mInterface.unconnectInput()
				myself.mInterface.unconnectOutput()
				myself.mInterface.unconnectError()
				/* Update status */
				myself.mIsStarted	= false
				myself.mIsFinished	= true
				/* Call handler */
				if let handler = myself.mTerminationHandler {
					handler(myself.mProcess)
				}
			}
		}
	}

	public func execute(command cmd: String) {
		mIsStarted		= true
		mIsFinished		= false
		mProcess.launchPath	= "/bin/sh"
		mProcess.arguments	= ["-c", cmd]
		mProcess.launch()
	}

	public func waitUntilExit() {
		if mIsStarted {
			mProcess.waitUntilExit()
		}
	}
}

#endif // os(OSX)

