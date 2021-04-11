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

/*
public class CNCommandHistory
{
	public static var shared = CNCommandHistory()

	private var mHistory:	Array<String>

	public var history: Array<String> { get { return mHistory }}

	private init(){
		mHistory = []
	}

	public func set(history src: Array<String>){
		mHistory = src
	}
}
*/

