/**
 * @file	CNShellThread.swift
 * @brief	Define CNShellThread class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

open class CNShellThread: CNThread
{
	private var mEnvironment:	CNShellEnvironment
	private var mConfig:		CNConfig
	private var mInputedString: 	String

	public init(input inhdl: FileHandle, output outhdl: FileHandle, error errhdl: FileHandle,  environment env: CNShellEnvironment, config conf: CNConfig, terminationHander termhdlr: TerminationHandler?){
		mEnvironment	= env
		mConfig		= conf
		mInputedString	= ""
		super.init(input: inhdl, output: outhdl, error: errhdl, terminationHander: termhdlr)
	}

	public var environment: CNShellEnvironment	{ get { return mEnvironment	}}
	public var config: CNConfig			{ get { return mConfig		}}

	open func promptString() -> String {
		return "$ "
	}

	open override func start() {
		super.start()
	}

	open override func mainOperation() -> Int32 {
		var doprompt = true
		while !isCancelled {
			if doprompt {
				if let data = promptString().data(using: .utf8) {
					self.outputFileHandle.write(data)
				}
				doprompt = false
			}
			/* Read input */
			let data = self.inputFileHandle.availableData
			if let str = String(data: data, encoding: .utf8) {
				if addString(string: str) {
					doprompt = true
				}
			}
		}
		return 0
	}

	private func addString(string str: String) -> Bool {
		var newstr = mInputedString + str
		while newstr.lengthOfBytes(using: .utf8) > 0 {
			if let nlidx = newstr.firstIndex(of: "\n") {
				/* put string before newline */
				let line = newstr[..<nlidx]
				self.inputLine(line: String(line))
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

	open func inputLine(line str: String) {
		NSLog("Override this method")
	}
}
