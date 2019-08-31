/**
 * @file	CNShellThread.swift
 * @brief	Define CNShellThread class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

open class CNShellThread: CNPipeThread
{
	private var mInLock:		NSLock
	private var mInputs:		Array<String>

	public override init(interface intf: CNShellInterface, environment env: CNShellEnvironment, console cons: CNConsole, config conf: CNConfig){
		mInLock		= NSLock()
		mInputs		= []
		super.init(interface: intf, environment: env, console: cons, config: conf)
	}

	open override var terminationStatus: Int32 {
		get { return 0 }
	}

	open func promptString() -> String {
		return "$ "
	}

	open override func main() {
		var doprompt = true
		while !isCancelled {
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

	open override func pushInput(string str: String) {
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
