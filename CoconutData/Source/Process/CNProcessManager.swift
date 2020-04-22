/**
 * @file	CNProcess.swift
 * @brief	Define CNProcess class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public class CNProcessManager
{
	private var 	mNextProcessId:		Int
	private var	mProcesses:		Dictionary<Int, CNProcessProtocol>
	private var 	mChildProcessManager:	Array<CNProcessManager>

	public var childProcessManagers: Array<CNProcessManager> { get { return mChildProcessManager }}

	public init() {
		mNextProcessId		= 0
		mProcesses		= [:]
		mChildProcessManager	= []
	}

	public func addProcess(process proc: CNProcessProtocol) -> Int {
		let pid = mNextProcessId
		mProcesses[pid] = proc
		mNextProcessId  += 1
		return pid
	}

	public func removeProcess(process proc: CNProcessProtocol) {
		if let pid = proc.processId {
			mProcesses.removeValue(forKey: pid)
		} else {
			NSLog("CNProcessManager: Process with no pid")
		}
	}

	public func addChildManager(childManager mgr: CNProcessManager){
		mChildProcessManager.append(mgr)
	}

	public func terminate() {
		/* Terminate children first */
		for child in mChildProcessManager {
			//NSLog("\(#file): Terminate child processes")
			child.terminate()
		}
		/* Terminate all processes */
		for process in mProcesses.values {
			//NSLog("\(#file): Terminate the processe")
			process.terminate()
		}
	}
}
