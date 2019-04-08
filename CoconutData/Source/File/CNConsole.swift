/**
 * @file	CNConsole.h
 * @brief	Define CNConsole class
 * @par Copyright
 *   Copyright (C) 2015-2016 Steel Wheels Project
 */

import Foundation

open class CNConsole
{
	public init(){

	}

	open func print(string str: String){
		Swift.print(str, terminator: "")
	}

	open func error(string str: String){
		Swift.print(str, terminator: "")
	}

	open func scan() -> String? {
		return nil
	}
}

public class CNFileConsole : CNConsole
{
	var inputHandle:	FileHandle
	var outputHandle:	FileHandle
	var errorHandle:	FileHandle

	public init(input ihdl: FileHandle, output ohdl: FileHandle, error ehdl: FileHandle){
		inputHandle	= ihdl
		outputHandle	= ohdl
		errorHandle	= ehdl
	}

	public override init() {
		inputHandle	= FileHandle.standardInput
		outputHandle	= FileHandle.standardOutput
		errorHandle	= FileHandle.standardError
	}

	public override func print(string str: String){
		if let data = str.data(using: .utf8) {
			outputHandle.write(data)
		}
	}

	public override func error(string str: String){
		if let data = str.data(using: .utf8) {
			errorHandle.write(data)
		} else {
			print(string: str)
		}
	}

	public override func scan() -> String? {
		return String(data: inputHandle.availableData, encoding: .utf8)
	}
}

public class CNIndentedConsole: CNConsole
{
	private var mConsole:		CNConsole
	private var mIndentValue:	Int
	private var mIndentString:	String

	public required init(console cons: CNConsole){
		mConsole 	= cons
		mIndentValue	= 0
		mIndentString	= ""
	}

	public override func print(string str: String){
		mConsole.print(string: mIndentString + str)
	}

	public override func error(string str: String){
		mConsole.error(string: mIndentString + str)
	}

	public override func scan() -> String? {
		return mConsole.scan()
	}

	public func incrementIndent() {
		updateIndent(indent: mIndentValue + 1)
	}

	public func decrementIndent() {
		if mIndentValue > 0 {
			updateIndent(indent: mIndentValue - 1)
		}
	}

	public func updateIndent(indent idt: Int) {
		var result = ""
		for _ in 0..<idt {
			result = result + "  "
		}
		mIndentValue  = idt
		mIndentString = result
	}
}

public class CNPipeConsole: CNConsole
{
	public var toConsole: 		CNConsole?
	public var inputPipe:		Pipe
	public var errorPipe:		Pipe
	public var outputPipe:		Pipe

	public override init(){
		toConsole	= nil
		inputPipe	= Pipe()
		errorPipe	= Pipe()
		outputPipe	= Pipe()
		super.init()

		inputPipe.fileHandleForReading.readabilityHandler = {
			[weak self] (_ handle: FileHandle) -> Void in
			if let str = String(data: handle.availableData, encoding: String.Encoding.utf8) {
				if let myself = self {
					myself.print(string: str)
				} else {
					CNLog(type: .Flow, message: str, file: #file, line: #line, function: #function)
				}
			} else {
				NSLog("Error decoding data: \(handle.availableData)")
			}
		}
		errorPipe.fileHandleForReading.readabilityHandler = {
			[weak self] (_ handle: FileHandle) -> Void in
			if let str = String(data: handle.availableData, encoding: String.Encoding.utf8) {
				if let myself = self {
					myself.error(string: str)
				} else {
					CNLog(type: .Error, message: str, file: #file, line: #line, function: #function)
				}
			} else {
				NSLog("Error decoding data: \(handle.availableData)")
			}
		}
		outputPipe.fileHandleForWriting.writeabilityHandler = {
			[weak self] (filehandle: FileHandle) -> Void in
			if let myself = self {
				if let str = myself.scan() {
					if let data = str.data(using: .utf8) {
						filehandle.write(data)
					} else {
						NSLog("Error encoding data: \(str)")
					}
				}
			}
		}
	}

	open override func print(string str: String){
		if let cons = toConsole {
			cons.print(string: str)
		}
	}

	open override func error(string str: String){
		if let cons = toConsole {
			cons.error(string: str)
		}
	}

	open override func scan() -> String? {
		if let cons = toConsole {
			return cons.scan()
		} else {
			return nil
		}
	}
}

public class CNBufferedConsole: CNConsole
{
	private var mOutputBuffer:	Array<String>
	private var mErrorBuffer:	Array<String>

	private var mOutputConsole: CNConsole?

	public override init(){
		mOutputBuffer	= []
		mErrorBuffer	= []
		mOutputConsole	= nil
	}

	public var outputConsole: CNConsole? {
		get { return mOutputConsole }
		set(console){
			if let cons = console {
				flushOutput(console: cons)
				flushError(console: cons)
			}
			mOutputConsole = console
		}
	}

	public override func print(string str: String){
		if let console = mOutputConsole {
			flushOutput(console: console)
			console.print(string: str)
		} else {
			mOutputBuffer.append(str)
		}
	}

	public override func error(string str: String){
		if let console = mOutputConsole {
			flushError(console: console)
			console.error(string: str)
		} else {
			mErrorBuffer.append(str)
		}
	}

	private func flushOutput(console cons: CNConsole){
		for elm in mOutputBuffer {
			cons.print(string: elm)
		}
		mOutputBuffer = []
	}

	private func flushError(console cons: CNConsole){
		for elm in mErrorBuffer {
			cons.error(string: elm)
		}
		mErrorBuffer = []
	}

	public override func scan() -> String? {
		if let console = mOutputConsole {
			return console.scan()
		} else {
			return nil
		}
	}
}

