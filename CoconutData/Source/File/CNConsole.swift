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
	public var inputHandle:		FileHandle
	public var outputHandle:	FileHandle
	public var errorHandle:		FileHandle

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

public class CNPipeConsole
{
	public typealias InputHandler	= () -> String?
	public typealias OutputHandler	= (_ str: String) -> Void

	private var mInputPipe:		Pipe
	private var mOutputPipe:	Pipe
	private var mErrorPipe:		Pipe

	private var mInputHandler:	InputHandler?
	private var mOutputHandler:	OutputHandler?
	private var mErrorHandler:	OutputHandler?

	private var mInterfaceConsole: CNFileConsole

	public var interfaceConsole: CNFileConsole { get { return mInterfaceConsole }}

	public var inputHandler: InputHandler? {
		get { return mInputHandler }
		set(hdl){ mInputHandler = hdl }
	}

	public var outputHandler: OutputHandler? {
		get { return mOutputHandler }
		set(hdl){ mOutputHandler = hdl }
	}

	public var errorHandler: OutputHandler? {
		get { return mErrorHandler }
		set(hdl){ mErrorHandler = hdl }
	}

	public init() {
		mInputHandler	= nil
		mOutputHandler	= nil
		mErrorHandler	= nil

		mInputPipe  	= Pipe()
		mOutputPipe 	= Pipe()
		mErrorPipe  	= Pipe()
		mInterfaceConsole = CNFileConsole(input:  mInputPipe.fileHandleForReading,
						  output: mOutputPipe.fileHandleForWriting,
						  error:  mErrorPipe.fileHandleForWriting)

		/* Close input */
		mInputPipe.fileHandleForWriting.writeabilityHandler = {
			[weak self] (_ handle: FileHandle) -> Void in
			if let myself = self {
				if let str = myself.input() {
					if let data = str.data(using: .utf8) {
						myself.mInputPipe.fileHandleForWriting.write(data)
					} else {
						NSLog("Failed to read data")
					}
				} else {
					myself.mInputPipe.fileHandleForWriting.closeFile()
				}
			}
		}

		/* Connect output */
		mOutputPipe.fileHandleForReading.readabilityHandler = {
			[weak self] (_ handle: FileHandle) -> Void in
			if let myself = self {
				if let str = String(data: handle.availableData, encoding: .utf8) {
					myself.output(string: str)
				} else {
					NSLog("Non string data")
				}
			}
		}
		/* Connect error */
		mErrorPipe.fileHandleForReading.readabilityHandler = {
			[weak self] (_ handle: FileHandle) -> Void in
			if let myself = self {
				if let str = String(data: handle.availableData, encoding: .utf8) {
					myself.error(string: str)
				} else {
					NSLog("Non string data")
				}
			}
		}
	}


	private func input() -> String? {
		if let hdl = mInputHandler {
			return hdl()
		} else {
			return nil
		}
	}

	private func output(string str: String) {
		if let hdl = mOutputHandler {
			hdl(str)
		}
	}

	private func error(string str: String) {
		if let hdl = mErrorHandler {
			hdl(str)
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

