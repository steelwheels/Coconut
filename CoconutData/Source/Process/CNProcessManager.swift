/**
 * @file	CNProcessManager.swift
 * @brief	Define CNProcessManager class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

private class CNProcessGroup
{
	private var mGroupId:		UInt16
	private var mIndexId:		UInt16
	private var mProcesses:		Dictionary<UInt16, CNProcessProtocol>	// process-id, process

	public init(groupId gid: UInt16) {
		mGroupId	= gid
		mIndexId	= 0
		mProcesses	= [:]
	}

	public func add(process proc: CNProcessProtocol) -> UInt32 {
		let idx = mIndexId
		mProcesses[idx] = proc
		mIndexId += 1
		return CNProcessGroup.gidToPid(groupId: mGroupId, index: idx)
	}

	public func waitUntilExit() -> Int32 {
		var summary: Int32 = 0
		for proc in mProcesses.values {
			let res = proc.waitUntilExit()
			if summary == 0 && res != 0 {
				summary = res
			}
		}
		return summary
	}

	public func terminate() {
		for proc in mProcesses.values {
			proc.terminate()
		}
	}

	public static func gidToPid(groupId gid: UInt16, index idx: UInt16) -> UInt32 {
		return (UInt32(gid) << 16) | UInt32(idx)
	}
}

public class CNProcessManager
{
	private var mProcessGroups:	Dictionary<UInt16, CNProcessGroup>
	private var mNextGroupId:	UInt16
	private var mLock: 		NSLock

	public init() {
		mProcessGroups	= [:]
		mNextGroupId	= 0
		mLock		= NSLock()
	}

	public func newGroupId() -> UInt16 {
		let gid = mNextGroupId
		mNextGroupId += 1
		return gid
	}

	public func add(groupId gid: UInt16, process proc: CNProcessProtocol) -> UInt32 {
		let group: CNProcessGroup
		if let grp = mProcessGroups[gid] {
			group = grp
		} else {
			group = CNProcessGroup(groupId: gid)
			mProcessGroups[gid] = group
		}
		return group.add(process: proc)
	}

	public func waitUntilExit(groupId gid: UInt16) -> Int32 {
		if let grp = mProcessGroups[gid] {
			return grp.waitUntilExit()
		} else {
			return -1 // No such procss group
		}
	}

	public func terminate(groupId gid: UInt16) {
		if let grp = mProcessGroups[gid] {
			grp.terminate()
		}
	}
}
