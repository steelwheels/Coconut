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

	public init() {
		mNextProcessId	= 0
		mProcesses	= [:]
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
}
