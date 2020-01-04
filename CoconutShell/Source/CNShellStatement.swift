/**
 * @file	CNShellStatement.swift
 * @brief	Define CNShellStatement class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

private let	NoProcessId: Int	= 0

public protocol CNShellStatementProtocol
{
	var	processId:	Int	 { get 	   }
	var	inputName:	String?	 { get set }
	var	outputName:	String?  { get set }
	var	errorName:	String?  { get set }
}

public extension CNShellStatementProtocol
{
	var inputNameString: String {
		if let str = self.inputName {
			return str
		} else {
			return "stdin"
		}
	}
	var outputNameString: String {
		if let str = self.outputName {
			return str
		} else {
			return "stdout"
		}
	}
	var errorNameString: String {
		if let str = self.errorName {
			return str
		} else {
			return "stderr"
		}
	}
}

public class CNShellCommandStatement: CNShellStatementProtocol
{
	private var	mProcessId:	Int

	public var	inputName:	String?
	public var	outputName:	String?
	public var	errorName:	String?

	public var processId: Int { get { return mProcessId }}

	public init() {
		mProcessId	= NoProcessId
		inputName	= nil
		outputName	= nil
		errorName	= nil
	}

	public func updateProcessId(startId pid: Int) -> Int {
		mProcessId = pid
		return pid + 1
	}
}


public class CNSystemShellCommandStatement: CNShellCommandStatement
{
	private var mShellCommand:	String

	public var shellCommand: String { get { return mShellCommand }}

	public init(shellCommand cmd: String){
		mShellCommand	= cmd
		super.init()
	}
}

public class CNRunShellCommandStatement: CNShellCommandStatement
{
	private var mScriptPath:	String?

	public var scriptPath: String {
		get {
			let path: String
			if let p = mScriptPath {
				path = "\"\(p)\""
			} else {
				path = "null"
			}
			return path
		}
	}

	public init(scriptPath path: String?) {
		mScriptPath = path
		super.init()
	}
}

public class CNBuiltinShellCommandStatement: CNShellCommandStatement
{
	private var mScriptURL:	URL

	public var scriptURL: URL { get { return mScriptURL }}

	public init(scriptURL url: URL) {
		mScriptURL = url
		super.init()
	}
}

public class CNProcessShellStatement: CNShellStatementProtocol
{
	private var mCommandSequence:	Array<CNShellCommandStatement>

	public var processId: Int {
		get {
			/* Get last process id */
			let count = mCommandSequence.count
			if count > 0 {
				return mCommandSequence[count - 1].processId
			} else {
				NSLog("No process id")
				return 0
			}
		}
	}

	public var commandSequence: Array<CNShellCommandStatement> { get { return mCommandSequence }}

	public init(){
		mCommandSequence = []
	}

	public var inputName: String? {
		get {
			if mCommandSequence.count > 0 {
				return mCommandSequence[0].inputName
			} else {
				return nil
			}
		}
		set(newname){
			for cmd in mCommandSequence {
				cmd.inputName = newname
			}
		}
	}

	public var outputName: String? {
		get {
			if mCommandSequence.count > 0 {
				return mCommandSequence[0].outputName
			} else {
				return nil
			}
		}
		set(newname){
			for cmd in mCommandSequence {
				cmd.outputName = newname
			}
		}
	}

	public var errorName: String? {
		get {
			if mCommandSequence.count > 0 {
				return mCommandSequence[0].errorName
			} else {
				return nil
			}
		}
		set(newname){
			for cmd in mCommandSequence {
				cmd.errorName = newname
			}
		}
	}

	public func add(command cmd: CNShellCommandStatement){
		mCommandSequence.append(cmd)
	}

	public func updateProcessId(startId pid: Int) -> Int {
		var newpid = pid
		for cmd in mCommandSequence {
			newpid = cmd.updateProcessId(startId: newpid)
		}
		return newpid
	}
}

public class CNPipelineShellStatement: CNShellStatementProtocol
{
	private var  	mProcessId:	Int

	public var	inputName: 	String?
	public var	outputName:	String?
	public var	errorName:	String?
	public var	exitName:	String?

	private var 	mCommandProcesses:	Array<CNProcessShellStatement>

	public var processId: Int { get { return mProcessId }}
	public var commandProcesses: Array<CNProcessShellStatement> { get { return mCommandProcesses }}

	public init(){
		mProcessId		= NoProcessId
		inputName		= nil
		outputName		= nil
		errorName		= nil
		mCommandProcesses	= []
	}

	public func add(process proc: CNProcessShellStatement){
		mCommandProcesses.append(proc)
		let _ = updateProcessId(startId: 0)
	}

	public func updateProcessId(startId pid: Int) -> Int {
		var newpid = pid
		for proc in mCommandProcesses {
			newpid = proc.updateProcessId(startId: newpid)
		}
		mProcessId = newpid
		return newpid + 1
	}
}
