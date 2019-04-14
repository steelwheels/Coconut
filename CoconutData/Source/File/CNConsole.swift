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

public class CNDefaultConsole: CNConsole
{
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

public class CNLogConsole
{
	public enum MessageType: Int {
		case Flow	= 0
		case Warning	= 1
		case Error	= 2

		public func description() -> String {
			let desc: String
			switch self {
			case .Flow:	desc = "Flow   "
			case .Warning:	desc = "Warning"
			case .Error:	desc = "Error  "
			}
			return desc
		}
	}

	private var mDebugLevel:	MessageType
	private var mConsole:		CNConsole

	public init(debugLevel level: MessageType, toConsole cons: CNConsole){
		mDebugLevel = level
		mConsole    = cons
	}

	public var connectedConsole: CNConsole {
		get { return mConsole }
	}

	public func print(type logtype: MessageType, string str: String, file fname: String, line ln: Int, function fnc: String) {
		if logtype.rawValue >= mDebugLevel.rawValue {
			let desc    = logtype.description()
			let place   = "\(fname)/\(ln)/\(fnc)"
			let message = "[\(desc)] \(str) at \(place)\n"
			switch logtype {
			case .Flow:
				mConsole.print(string: message)
			case .Warning, .Error:
				mConsole.error(string: message)
			}
		}
	}
}

public protocol CNLogging
{
	var console: CNLogConsole?	{ get set }
	func log(type logtype: CNLogConsole.MessageType, string str: String, file filestr: String, line linestr: Int, function funcstr: String)
	func log(type logtype: CNLogConsole.MessageType, text   txt: CNText, file filestr: String, line linestr: Int, function funcstr: String)

}

extension CNLogging
{
	public func log(type logtype: CNLogConsole.MessageType, string str: String, file filestr: String, line linestr: Int, function funcstr: String) {
		if let cons = console {
			cons.print(type: logtype, string: str, file: filestr, line: linestr, function: funcstr)
		} else {
			let desc    = logtype.description()
			let message = "[\(desc)] \(str) at \(filestr)/\(linestr)/\(funcstr)"
			NSLog(message)
		}
	}

	public func log(type logtype: CNLogConsole.MessageType, text   txt: CNText, file filestr: String, line linestr: Int, function funcstr: String) {
		let cons: CNConsole
		if let logcons = console {
			cons = logcons.connectedConsole
		} else {
			cons = CNDefaultConsole()
		}

		let desc    = logtype.description()
		let message = "[\(desc)] at \(filestr)/\(linestr)/\(funcstr)\n"
		cons.print(string: message)
		txt.print(console: cons)
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
		set(console){
			if let cons = console {
				flushOutput(console: cons)
				flushError(console: cons)
			}
			mOutputConsole = console
		}
	}

	public func print(string str: String){
		if let console = mOutputConsole {
			flushOutput(console: console)
			console.print(string: str)
		} else {
			mOutputBuffer.append(str)
		}
	}

	public func error(string str: String){
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

	public func scan() -> String? {
		if let console = mOutputConsole {
			return console.scan()
		} else {
			return nil
		}
	}
}

