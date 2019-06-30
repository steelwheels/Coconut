/**
 * @file	CNConsole.h
 * @brief	Define CNConsole class
 * @par Copyright
 *   Copyright (C) 2015-2016 Steel Wheels Project
 */

import Foundation

public protocol CNConsole {
	func print(string str: String)
	func error(string str: String)
	func scan() -> String?
}

public enum CNLogType {
	case Flow
	case Warning
	case Error

	public var description: String {
		get {
			let result: String
			switch self {
			case .Flow:	result = "Flow"
			case .Warning:	result = "Debug"
			case .Error:	result = "Error"
			}
			return result
		}
	}
}

public protocol CNLogging
{
	var console: CNConsole?	{ get }

	func log(type logtype: CNLogType, string str: String, file filestr: String, line linestr: Int, function funcstr: String)
	func log(type logtype: CNLogType, text   txt: CNText, file filestr: String, line linestr: Int, function funcstr: String)
}

extension CNLogging
{
	public func log(type logtype: CNLogType, string str: String, file filestr: String, line lineval: Int, function funcstr: String){
		let desc  = "[\(logtype.description)] "
		let place = placeString(file: filestr, line: lineval, function: funcstr)
		log(type: logtype, entireString: desc + str + " at " + place + "\n")
	}

	public func log(type logtype: CNLogType, text   txt: CNText, file filestr: String, line lineval: Int, function funcstr: String){
		let desc  = "[\(logtype.description)] "
		let place = placeString(file: filestr, line: lineval, function: funcstr)
		log(type: logtype, entireString: desc + " at " + place + "\n")
		if let cons = console {
			txt.print(console: cons)
		}
	}

	private func log(type logtype: CNLogType, entireString str: String) {
		let doverbose = CNPreference.shared.systemPreference.doVerbose
		switch logtype {
		case .Flow:
			if doverbose {
				console?.print(string: str)
			}
		case .Warning, .Error:
			console?.error(string: str)
		}
	}

	private func placeString(file filestr: String, line linestr: Int, function funcstr: String) -> String {
		return "\(filestr)/\(linestr)/\(funcstr)\n"
	}
}

public class CNDefaultConsole: CNConsole
{
	public init(){
	}

	public func print(string str: String){
		NSLog(str)
	}

	public func error(string str: String){
		NSLog(str)
	}

	public func scan() -> String? {
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

	public init() {
		inputHandle	= FileHandle.standardInput
		outputHandle	= FileHandle.standardOutput
		errorHandle	= FileHandle.standardError
	}

	public func print(string str: String){
		if let data = str.data(using: .utf8) {
			outputHandle.write(data)
		}
	}

	public func error(string str: String){
		if let data = str.data(using: .utf8) {
			errorHandle.write(data)
		} else {
			print(string: str)
		}
	}

	public func scan() -> String? {
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

	public func print(string str: String){
		mConsole.print(string: mIndentString + str)
	}

	public func error(string str: String){
		mConsole.error(string: mIndentString + str)
	}

	public func scan() -> String? {
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

	public init(){
		toConsole	= nil
		inputPipe	= Pipe()
		errorPipe	= Pipe()
		outputPipe	= Pipe()

		inputPipe.fileHandleForReading.readabilityHandler = {
			[weak self] (_ handle: FileHandle) -> Void in
			if let str = String(data: handle.availableData, encoding: String.Encoding.utf8) {
				if let myself = self {
					myself.print(string: str)
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

	open func print(string str: String){
		if let cons = toConsole {
			cons.print(string: str)
		}
	}

	open func error(string str: String){
		if let cons = toConsole {
			cons.error(string: str)
		}
	}

	open func scan() -> String? {
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

	public init(){
		mOutputBuffer	= []
		mErrorBuffer	= []
		mOutputConsole	= nil
	}

	public var outputConsole: CNConsole? {
		get { return mOutputConsole }
		set(newcons){
			if let cons = newcons {
				flushOutput(console: cons)
				flushError(console: cons)
			}
			mOutputConsole = newcons
		}
	}

	public func print(string str: String){
		if let cons = mOutputConsole {
			flushOutput(console: cons)
			cons.print(string: str)
		} else {
			mOutputBuffer.append(str)
		}
	}

	public func error(string str: String){
		if let cons = mOutputConsole {
			flushError(console: cons)
			cons.error(string: str)
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

	public func scan() -> String? {
		if let cons = mOutputConsole {
			return cons.scan()
		} else {
			return nil
		}
	}
}

