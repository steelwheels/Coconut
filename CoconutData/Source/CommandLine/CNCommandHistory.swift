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

	public var commandHistory: Array<String> {
		get { return mCommandHistory }
	}

	public func append(command cmd: String){
		mCommandHistory.append(cmd)
		mHistoryIndex  = mCommandHistory.count
		mLatestCommand = nil
	}

	public func select(delta val: Int, latest cmd: String) -> String? {
		if mLatestCommand == nil {
			mLatestCommand = cmd
		}
		if let nxtidx = moveIndex(delta: val) {
			return command(at: nxtidx)
		} else {
			return nil
		}
	}

	private func moveIndex(delta del: Int) -> Int? {
		let cmdcnt = mCommandHistory.count
		if  cmdcnt > 0 {
			let nxtidx0 = mHistoryIndex + del
			let nxtidx1 = max(0, nxtidx0)
			let nxtidx2 = min(nxtidx1, cmdcnt)
			if mHistoryIndex != nxtidx2 {
				mHistoryIndex = nxtidx2
				return nxtidx2
			}
		}
		return nil
	}

	public func command(at idx: Int) -> String? {
		if 0<=idx && idx<mCommandHistory.count {
			return mCommandHistory[idx]
		} else if idx == mCommandHistory.count {
			return mLatestCommand
		} else {
			return nil
		}
	}
}


