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
	private var mInterface:		CNShellInterface
	private var mEnvironment:	CNShellEnvironment
	private var mConsole:		CNConsole
	private var mConfig:		CNConfig
	private var mExitCode:		Int?

	public var environment:	CNShellEnvironment	{ get { return mEnvironment	}}
	public var console: CNConsole 			{ get { return mConsole 	}}
	public var config:  CNConfig  			{ get { return mConfig  	}}
	public var exitCode: Int? 			{ get { return mExitCode	}}

	public init(interface intf: CNShellInterface, environment env: CNShellEnvironment, console cons: CNConsole, config conf: CNConfig) {
		mInterface	= intf
		mEnvironment	= env
		mConsole	= cons
		mConfig		= conf
		mExitCode	= nil
		super.init()

		intf.input.setReader(handler: {
			[weak self] (_ str: String) -> Void in
			if let myself = self {
				myself.pushInput(string: str)
			}
		})
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

