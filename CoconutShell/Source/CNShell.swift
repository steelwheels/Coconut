/**
 * @file	CNShell.swift
 * @brief	Define CNShell class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public enum CNShellCommand {
	case selectPreviousHistory
	case selectNextHistory
}

public struct CNShellInterface {
	public var	commands:	CNMutexStack<CNShellCommand>	// Terminal -> Shell
	public var 	input:		Pipe				// Terminal -> Shell
	public var 	output:		Pipe				// Shell -> Terminal
	public var	error:		Pipe				// Shell -> Terminal

	public init(input inp: Pipe, output outp: Pipe, error errp: Pipe){
		commands	= CNMutexStack()
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
	private var mInputs:		Array<String>
	private var mInLock:		NSLock

	public init(interface intf: CNShellInterface, console cons: CNConsole) {
		mInterface	= intf
		mConsole	= cons
		mInputs		= []
		mInLock		= NSLock()
		super.init()

		mInterface.input.setReader(handler: {
			[weak self] (_ str: String) -> Void in
			if let myself = self {
				myself.pushInput(string: str)
			}
		})
	}

	open func promptString() -> String {
		return "$ "
	}

	public var console: CNConsole { get { return  mConsole }}

	open override func main() {
		var doprompt = true
		while !isCancelled {
			if doprompt {
				output(string: promptString())
				doprompt = false
			}
			if let input = popInput() {
				execute(string: input)
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

	open func execute(string str: String){
		NSLog("execute(\(str))")
	}
}
