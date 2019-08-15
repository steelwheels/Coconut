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
	public var	commands:	CNMutexStack<CNShellCommand>		// Terminal -> Shell
	public var 	stdin:		CNConnection				// Terminal -> Shell
	public var 	stdout:		CNConnection				// Shell -> Terminal
	public var	stderr:		CNConnection				// Shell -> Terminal

	public init(){
		commands	= CNMutexStack()
		stdin		= CNConnection()
		stdout		= CNConnection()
		stderr		= CNConnection()
	}
}

open class CNShell: Thread
{
	private var mPrompt:		String
	private var mInterface:		CNShellInterface
	private var mInputs:		Array<String>
	private var mInLock:		NSLock

	public init(interface intf: CNShellInterface) {
		mPrompt 	= "$ "
		mInterface	= intf
		mInputs		= []
		mInLock		= NSLock()
		super.init()

		mInterface.stdin.receiverFunction = {
			[weak self] (_ str: String) -> Void in
			if let myself = self {
				myself.pushInput(string: str)
			}
		}
	}

	public var prompt: String {
		get		{ return mPrompt }
		set(newstr)	{ mPrompt = newstr }
	}

	open override func main() {
		var doprompt = true
		while !isCancelled {
			if doprompt {
				output(string: mPrompt)
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
		mInterface.stdout.send(string: str)
	}

	public func error(string str: String){
		mInterface.stderr.send(string: str)
	}

	open func execute(string str: String){
		NSLog("execute(\(str))")
	}
}
