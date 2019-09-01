/**
 * @file	CNPipdThread.swift
 * @brief	Define CNPipeThread class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

open class CNPipeThread: Thread
{
	private var mInterface:			CNShellInterface
	private var mEnvironment:		CNShellEnvironment
	private var mConsole:			CNConsole
	private var mConfig:			CNConfig

	public var interface:   CNShellInterface	{ get { return mInterface	}}
	public var environment:	CNShellEnvironment	{ get { return mEnvironment	}}
	public var console: CNConsole 			{ get { return mConsole 	}}
	public var config:  CNConfig  			{ get { return mConfig  	}}

	public init(interface parent: CNShellInterface, environment env: CNShellEnvironment, console cons: CNConsole, config conf: CNConfig) {
		mInterface		= CNShellInterface()
		mEnvironment		= env
		mConsole		= cons
		mConfig			= conf
		super.init()

		mInterface.connectInput(from: parent.input)
		mInterface.connectOutput(to: parent.output)
		mInterface.connectError(to: parent.error)
	}

	open var terminationStatus: Int32 {
		get { return 1 }		// must be override
	}

	open func pushInput(string str: String) {
	}

	public func output(string str: String){
		mInterface.output.write(string: str)
	}

	public func error(string str: String){
		mInterface.error.write(string: str)
	}
}

