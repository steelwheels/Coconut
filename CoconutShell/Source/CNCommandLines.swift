/*
 * @file	CNCommandHistory.swift
 * @brief	Define CNCommandHistory class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNCommandLines
{
	private var mCommandLines:	Array<CNCommandLine>
	private var mMaxCount:		Int
	private var mCurrentIndex:	Int
	private var mCurrentCommand:	CNCommandLine

	public init() {
		mCommandLines	= []
		mMaxCount	= 32
		mCurrentIndex	= 0
		mCurrentCommand	= CNCommandLine()
	}

	public var currentCommand: CNCommandLine {
		if 0<=mCurrentIndex && mCurrentIndex < mCommandLines.count {
			return mCommandLines[mCurrentIndex]
		} else {
			return mCurrentCommand
		}
	}

	public func saveCurrentCommand() {
		/* If there is same command, remove it */
		var dupidx: Int? = nil
		for i in 0..<mCommandLines.count {
			if mCommandLines[i] == mCurrentCommand {
				dupidx = i
				break
			}
		}
		if let i = dupidx {
			mCommandLines.remove(at: i)
		}

		/* Add command to history */
		mCurrentCommand.resetDetermined()
		mCommandLines.append(mCurrentCommand)

		/* If the count is over the limit, remove it */
		if mCommandLines.count > mMaxCount {
			mCommandLines.removeFirst()
		}

		/* Reflesh the current command */
		mCurrentCommand = CNCommandLine()

		/* Update index to point current command */
		mCurrentIndex = mCommandLines.count
	}

	public func upCommand(count cnt: Int) -> CNCommandLine? {
		let previdx = mCurrentIndex - cnt
		//NSLog("upCommand: count=\(mCommandLines.count) mCurrentIndex=\(mCurrentIndex) previdx=\(previdx), cnt=\(cnt)")
		if 0<=previdx && previdx < mCommandLines.count {
			mCurrentIndex = previdx
			//NSLog("upCommand: result=\(mCommandLines[previdx].string)")
			return mCommandLines[previdx]
		}
		//NSLog("upCommand: result=nil")
		return nil
	}

	public func downCommand(count cnt: Int) -> CNCommandLine? {
		let nextidx = mCurrentIndex + cnt
		//NSLog("downCommand: count=\(mCommandLines.count) mCurrentIndex=\(mCurrentIndex) nextidx=\(nextidx), cnt=\(cnt)")
		if nextidx < mCommandLines.count {
			let result: CNCommandLine
			if nextidx < mCommandLines.count {
				result = mCommandLines[nextidx]
			} else {
				result = mCurrentCommand
			}
			mCurrentIndex = nextidx
			//NSLog("downCommand: result=\(result.string)")
			return result
		}
		//NSLog("downCommand: result=nil")
		return nil
	}
}

