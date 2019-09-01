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
	private var mInputedString: String

	public override init(interface intf: CNShellInterface, environment env: CNShellEnvironment, console cons: CNConsole, config conf: CNConfig){
		mInputedString = ""
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
			/* Read input */
			let data = self.interface.input.fileHandleForReading.availableData
			if let str = String(data: data, encoding: .utf8) {
				if addString(string: str) {
					doprompt = true
				}
			}
		}
	}

	private func addString(string str: String) -> Bool {
		var newstr = mInputedString + str
		while newstr.lengthOfBytes(using: .utf8) > 0 {
			if let nlidx = newstr.firstIndex(of: "\n") {
				/* put string before newline */
				let line = newstr[..<nlidx]
				input(string: String(line))
				/* Keep string after newline */
				let nxtidx = newstr.index(after: nlidx)
				if nxtidx < newstr.endIndex {
					newstr = String(newstr[nxtidx..<newstr.endIndex])
				} else {
					newstr = ""
				}
			} else {
				break
			}
		}
		mInputedString = newstr
		return true
	}

	open override func input(string str: String){
		NSLog("input(\(str))")
	}

	open func execute(string str: String){
		NSLog("execute(\(str))")
	}
}
