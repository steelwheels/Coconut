/**
 * @file	CNShell.swift
 * @brief	Define CNShell class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public struct CNShellInterface {
	public var 	input:		Pipe				// Terminal -> Shell
	public var 	output:		Pipe				// Shell -> Terminal
	public var	error:		Pipe				// Shell -> Terminal

	public init(input inp: Pipe, output outp: Pipe, error errp: Pipe){
		input		= inp
		output		= outp
		error		= errp
	}

	public init(){
		self.init(input: Pipe(), output: Pipe(), error: Pipe())
	}
}

open class CNShell: Thread
{
	private var mInterface:		CNShellInterface
	private var mConsole:		CNConsole
	private var mConfig:		CNConfig
	private var mInputs:		Array<String>
	private var mExitCode:		Int?
	private var mEnvironment:	CNShellEnvironment
	private var mInLock:		NSLock

	public init(interface intf: CNShellInterface, environment env: CNShellEnvironment, console cons: CNConsole, config conf: CNConfig) {
		mInterface	= intf
		mConsole	= cons
		mConfig		= conf
		mInputs		= []
		mExitCode	= nil
		mEnvironment	= env
		mInLock		= NSLock()
		super.init()

		mInterface.input.setReader(handler: {
			[weak self] (_ str: String) -> Void in
			if let myself = self {
				myself.pushInput(string: str)
			}
		})
	}

	public var console: CNConsole 			{ get { return mConsole }}
	public var config:  CNConfig  			{ get { return mConfig  }}
	public var environment:	CNShellEnvironment	{ get { return mEnvironment }}

	public var exitCode: Int? {
		return mExitCode
	}

	open func promptString() -> String {
		return "$ "
	}

	open override func main() {
		var doprompt = true
		while !isCancelled && mExitCode == nil {
			if doprompt {
				output(string: promptString())
				doprompt = false
			}
			if let input = popInput() {
				parse(string: input)
				doprompt = true
			}
		}
	}

	private func pushInput(string str: String) {
		mInLock.lock()
			mInputs.append(str)
		mInLock.unlock()
	}

	private func popInput() -> String? {
		var result: String?
		mInLock.lock()
			if mInputs.count > 0 {
				result = mInputs.removeFirst()
			} else {
				result = nil
			}
		mInLock.unlock()
		return result
	}

	public func output(string str: String){
		mInterface.output.write(string: str)
	}

	public func error(string str: String){
		mInterface.error.write(string: str)
	}

	public func exit(code ecode: Int) {
		mExitCode = ecode
	}

	private func parse(string str: String){
		let lines = str.components(separatedBy: ";")
		for line in lines {
			parse(line: line)
		}
	}

	private func parse(line str: String){
	}

	open func execute(string str: String){
		NSLog("execute(\(str))")
	}
}
