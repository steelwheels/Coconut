/*
 * @file	CNCommandLine.swift
 * @brief	Define CNCommandLine class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public class CNCommandLine: Equatable
{
	public enum EraceCommand {
		case eraceCursorLeft
		case eraceFromCursorToEnd
		case eraceFromCursorToBegin
		case eraceEntireBuffer
	}

	private var	mCommandLine:		String
	private var	mCurrentIndex:		String.Index
	private var 	mCurrentPosition:	Int

	public var string:   String { get { return mCommandLine  }}
	public var position: Int    { get { return mCurrentPosition }}

	public init(command cmd: String) {
		mCommandLine	 = cmd
		mCurrentIndex	 = mCommandLine.startIndex
		mCurrentPosition = 0
	}

	public func getAndClear(didDetermined det: Bool) -> (String, Int) {
		if det {
			let curcmd = mCommandLine
			let curpos = mCurrentPosition
			replace(string: "")
			return (curcmd, curpos)
		} else {
			return (mCommandLine, mCurrentPosition)
		}
	}

	public func replace(string str: String){
		mCommandLine	 = str
		mCurrentIndex	 = str.endIndex
		mCurrentPosition = str.count
	}

	public func insert(string str: String){
		let len = str.count
		mCommandLine.insert(contentsOf: str, at: mCurrentIndex)
		let endidx = mCommandLine.endIndex
		for _ in 0..<len {
			if mCurrentIndex < endidx {
				mCurrentIndex    =  mCommandLine.index(after: mCurrentIndex)
				mCurrentPosition += 1
			} else {
				break
			}
		}
	}

	public func moveCursor(delta dlt: Int) {
		if dlt >= 0 {
			/* move forward */
			let endidx   = mCommandLine.endIndex
			for _ in 0..<dlt {
				if mCurrentIndex < endidx {
					mCurrentIndex    =  mCommandLine.index(after: mCurrentIndex)
					mCurrentPosition += 1
				} else {
					break
				}
			}
		} else {
			/* move backward */
			let startidx = mCommandLine.startIndex
			let ndlt = -dlt
			for _ in 0..<ndlt {
				if startidx < mCurrentIndex {
					mCurrentIndex    =  mCommandLine.index(before: mCurrentIndex)
					mCurrentPosition -= 1
				} else {
					break
				}
			}
		}
	}

	public func erace(command cmd: EraceCommand) {
		let subrange: Range<String.Index>
		switch cmd {
		case .eraceCursorLeft:
			if mCommandLine.startIndex < mCurrentIndex {
				let previdx = mCommandLine.index(before: mCurrentIndex)
				subrange = previdx..<mCurrentIndex
				mCommandLine.removeSubrange(subrange)
				mCurrentIndex	 =  previdx
				mCurrentPosition -= 1
			}
		case .eraceFromCursorToEnd:
			if mCurrentIndex < mCommandLine.endIndex {
				let subrange = mCurrentIndex..<mCommandLine.endIndex
				mCommandLine.removeSubrange(subrange)
				/* Index is not changed */
			}
		case .eraceFromCursorToBegin:
			if mCommandLine.startIndex < mCurrentIndex {
				let subrange = mCommandLine.startIndex..<mCurrentIndex
				mCommandLine.removeSubrange(subrange)
				mCurrentIndex	 = mCommandLine.startIndex
				mCurrentPosition = 0
			}

		case .eraceEntireBuffer:
			if mCommandLine.count > 0 {
				mCommandLine	 = ""
				mCurrentIndex	 = mCommandLine.startIndex
				mCurrentPosition = 0
			}
		}
	}

	public static func == (cmd0: CNCommandLine, cmd1: CNCommandLine) -> Bool {
		return cmd0.string == cmd1.string
	}
}


