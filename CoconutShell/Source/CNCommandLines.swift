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

	public var commandCount: Int { get { return mCommandLines.count }}

	public func command(at index: Int) -> CNCommandLine? {
		if 0<=index && index<mCommandLines.count {
			return mCommandLines[index]
		}
		return nil
	}

	public func replaceReplayCommand(source src: String) -> String {
		var result: String = ""
		let stream = CNStringStream(string: src)
		while true {
			if let c = stream.getc() {
				if c == "!" {
					if let idx = stream.geti() {
						if 1<=idx && idx<=mCommandLines.count {
							let cmd = mCommandLines[idx-1]
							result.append(cmd.string)
						} else {
							result.append("!\(idx)")
						}
						continue
					}
				}
				result.append(c)
			} else {
				break
			}
		}
		return result
	}

	public func addCommand(command cmdstr: String) {
		/* Allocate command */
		let newcmd = CNCommandLine(command: cmdstr)

		#if false
		/* If there is same command, remove it */
		var dupidx: Int? = nil
		for i in 0..<mCommandLines.count {
			if mCommandLines[i] == newcmd {
				dupidx = i
				break
			}
		}
		if let i = dupidx {
			mCommandLines.remove(at: i)
		}
		#endif

		/* Add command to history */
		mCurrentCommand.resetDetermined()
		mCommandLines.append(newcmd)

		#if false
		/* If the count is over the limit, remove it */
		if mCommandLines.count > mMaxCount {
			mCommandLines.removeFirst()
		}
		#endif

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

	public func history() -> Array<String> {
		var result: Array<String> = []
		for cmdline in mCommandLines {
			result.append(cmdline.string)
		}
		return result
	}
}

