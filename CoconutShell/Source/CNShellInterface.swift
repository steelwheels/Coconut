/**
 * @file	CNShellInterface.swift
 * @brief	Define CNShellInterface class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

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

	public func connectWithStandardInput() {
		self.input.setWriter(handler: {
			() -> String? in
			let data = FileHandle.standardInput.availableData
			let str  = String(data: data, encoding: .utf8)
			return str
		})
	}

	public func connectWithStandardOutput() {
		self.output.setReader(handler: {
			(_ str: String) -> Void in
			if let data = str.data(using: .utf8) {
				FileHandle.standardOutput.write(data)
			} else {
				NSLog("Failed to geneeate output")
			}
		})
	}

	public func connectWithStandardError() {
		self.error.setReader(handler: {
			(_ str: String) -> Void in
			if let data = str.data(using: .utf8) {
				FileHandle.standardError.write(data)
			} else {
				NSLog("Failed to geneeate output")
			}
		})
	}
}

