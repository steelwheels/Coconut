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

	public init(console cons: CNConsole){
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
			(_ handle: FileHandle) -> Void in
			if let str = String(data: handle.availableData, encoding: String.Encoding.utf8) {
				self.print(string: str)
			} else {
				NSLog("Error decoding data: \(handle.availableData)")
			}
		}
		errorPipe.fileHandleForReading.readabilityHandler = {
			(_ handle: FileHandle) -> Void in
			if let str = String(data: handle.availableData, encoding: String.Encoding.utf8) {
				self.error(string: str)
			} else {
				NSLog("Error decoding data: \(handle.availableData)")
			}
		}
		outputPipe.fileHandleForWriting.writeabilityHandler = {
			(filehandle: FileHandle) -> Void in
			if let str = self.scan() {
				if let data = str.data(using: .utf8) {
					filehandle.write(data)
				} else {
					NSLog("Error encoding data: \(str)")
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

#if false
public class CNSenderConsole: CNConsole
{
	private var mConnection	: CNConnection?

	public override init(){
		mConnection = nil
	}

	public var connection: CNConnection? {
		get {
			return mConnection
		}
		set(newconn){
			if let conn = newconn {
				conn.sender = self
			}
			mConnection = newconn
		}
	}

	open override func print(string str: String){
		if let conn = mConnection {
			if let receiver = conn.receiver as? CNReceiverConsole {
				receiver.print(string: str)
			} else {
				NSLog("Invalid object")
			}
		}
	}

	open override func error(string str: String){
		if let conn = mConnection {
			if let receiver = conn.receiver as? CNReceiverConsole {
				receiver.error(string: str)
			} else {
				NSLog("Invalid object")
			}
		}
	}

	open override func scan() -> String? {
		if let conn = mConnection {
			if let receiver = conn.receiver as? CNReceiverConsole {
				return receiver.scan()
			} else {
				NSLog("Invalid object")
			}
		}
		return nil
	}
}

public class CNReceiverConsole: CNConsole
{
	private var mConnection	: CNConnection?

	public var printCallback	: ((_ str: String) -> Void)?
	public var errorCallback	: ((_ str: String) -> Void)?
	public var scanCallback		: (() -> String)?

	public override init(){
		mConnection	= nil
		printCallback	= nil
		errorCallback	= nil
		scanCallback	= nil
	}

	public var connection: CNConnection? {
		get {
			return mConnection
		}
		set(newconn){
			if let conn = newconn {
				conn.receiver = self
			}
			mConnection = newconn
		}
	}

	open override func print(string str: String){
		if let callback = printCallback {
			callback(str)
		}
	}

	open override func error(string str: String){
		if let callback = errorCallback {
			callback(str)
		}
	}

	open override func scan() -> String? {
		if let callback = scanCallback {
			return callback()
		} else {
			return nil
		}
	}
}
#endif


