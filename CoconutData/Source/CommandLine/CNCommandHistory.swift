/**
 * @file	CNCommandHistory.swift
 * @brief	Define CNCommandHistory class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNCommandHistory
{
	private var	mLatestCommand:		String?
	private var	mHistoryIndex:		Int
	private var	mCommandHistory:	Array<String>

	public init(){
		mLatestCommand	= nil
		mHistoryIndex	= 0
		mCommandHistory = []
	}

	public var currentIndex: Int {
		get { return mHistoryIndex }
	}

	public func moveIndex(delta del: Int) -> Int? {
		let cmdcnt = mCommandHistory.count
		if  cmdcnt > 0 {
			let nxtidx0 = mHistoryIndex + del
			let nxtidx1 = max(0, nxtidx0)
			let nxtidx2 = min(nxtidx1, cmdcnt - 1)
			if mHistoryIndex != nxtidx2 {
				mHistoryIndex = nxtidx2
				return nxtidx2
			}
		}
		return nil
	}

	public var commandHistory: Array<String> {
		get { return mCommandHistory }
	}

	public func command(at idx: Int) -> String? {
		if 0<=idx && idx<mCommandHistory.count {
			return mCommandHistory[idx]
		} else {
			return nil
		}
	}

	public func append(command cmd: String){
		mCommandHistory.append(cmd)
		mHistoryIndex = mCommandHistory.count - 1
	}

	public func reset() {
		mLatestCommand = nil
	}

	public func selectPrevious(latest cmd: String) -> String? {
		if mLatestCommand == nil {
			mLatestCommand = cmd
		}
		if mHistoryIndex > 0 {
			mHistoryIndex -= 1
			return mCommandHistory[mHistoryIndex]
		} else {
			return nil
		}
	}

	public func selectNext(latest cmd: String) -> String? {
		if mLatestCommand == nil {
			mLatestCommand = cmd
		}
		if mHistoryIndex >= mCommandHistory.count {
			return mLatestCommand
		} else {
			let curidx = mHistoryIndex
			mHistoryIndex += 1
			return mCommandHistory[curidx]
		}
	}
}


