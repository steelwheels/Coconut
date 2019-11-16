/*
 * @file	CNReadline.swift
 * @brief	Define CNReadline class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation
import Darwin

public class CNCommandLine
{
	public enum EraceCommand {
		case eraceCursorLeft
		case eraceFromCursorToEnd
		case eraceFromCursorToBegin
		case eraceFromBeginToEnd
	}

	private var	mCommandLine:		String
	private var	mCurrentIndex:		String.Index
	private var 	mCurrentPosition:	Int
	private var	mDidDetermined:		Bool

	public var didDetermined: Bool { get { return mDidDetermined }}

	public init(){
		mCommandLine	 = ""
		mCurrentIndex	 = mCommandLine.endIndex
		mCurrentPosition = 0
		mDidDetermined   = false
	}

	public func determine() {
		mDidDetermined = true
	}

	public func get() -> (String, Int) {
		if mDidDetermined {
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
		mDidDetermined   = false
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

		case .eraceFromBeginToEnd:
			if mCommandLine.count > 0 {
				mCommandLine	 = ""
				mCurrentIndex	 = mCommandLine.startIndex
				mCurrentPosition = 0
			}
		}
	}
}

private class CNCommandHistory
{
	public init() {
	}

	public func traceHistory(delta deltaval: Int) -> String? {
		return nil
	}
}

open class CNReadline
{
	private var mConsole:		CNFileConsole
	private var mCommandLine:	CNCommandLine
	private var mCommandHistory:	CNCommandHistory
	private var mCurrentBuffer:	CNQueue<CNEscapeCode>
	private var mPreviousTerm:	termios

	public var console: CNFileConsole { get { return mConsole } set(cons){ set(console: cons) }}

	public init(){
		mConsole	= CNFileConsole()
		mCommandLine	= CNCommandLine()
		mCommandHistory	= CNCommandHistory()
		mCurrentBuffer	= CNQueue<CNEscapeCode>()
		mPreviousTerm	= CNReadline.enableRawMode(fileHandle: mConsole.inputHandle)
	}

	deinit {
		CNReadline.restoreRawMode(fileHandle: mConsole.inputHandle, originalTerm: mPreviousTerm)
	}

	public enum Result {
		case	none
		case	commandLine(CNCommandLine)
		case	escapeCode(CNEscapeCode)
	}

	open func readLine() -> Result {
		/* Scan input */
		if let str = self.scan() {
			switch CNEscapeCode.decode(string: str) {
			case .ok(let codes):
				for code in codes {
					mCurrentBuffer.push(code)
				}
			case .error(let err):
				let msg = "[Error] " + err.description()
				mConsole.error(string: msg)
			}
		}
		/* Return result */
		if let code = mCurrentBuffer.pop() {
			if decodeForCommandLine(escapeCode: code) {
				return .commandLine(mCommandLine)
			} else {
				return .escapeCode(code)
			}
		} else {
			return .none
		}
	}

	open func scan() -> String? {
		return mConsole.scan()
	}

	private func decodeForCommandLine(escapeCode code: CNEscapeCode) -> Bool {
		let result: Bool
		switch code {
		case .string(let str):
			mCommandLine.insert(string: str)
			result = true
		case .newline:
			mCommandLine.determine()
			result = true
		case .tab:
			mCommandLine.insert(string: "\t")
			result = true
		case .backspace:
			mCommandLine.moveCursor(delta: -1)
			result = true
		case .delete:
			mCommandLine.erace(command: .eraceCursorLeft)
			result = true
		case .cursorUp(let n), .cursorPreviousLine(let n):
			if let newstr = mCommandHistory.traceHistory(delta: -n) {
				mCommandLine.replace(string: newstr)
			}
			result = true
		case .cursorDown(let n), .cursorNextLine(let n):
			if let newstr = mCommandHistory.traceHistory(delta: n) {
				mCommandLine.replace(string: newstr)
			}
			result = true
		case .cursorForward(let n):
			mCommandLine.moveCursor(delta: n)
			result = true
		case .cursorBack(let n):
			mCommandLine.moveCursor(delta: -n)
			result = true
		case .cursorHolizontalAbsolute(_):
			result = true			/* ignored */
		case .cursorPoisition(_, _):
			result = true			/* ignored */
		case .eraceFromCursorToEnd:
			mCommandLine.erace(command: .eraceFromCursorToEnd)
			result = true
		case .eraceFromCursorToBegin:
			mCommandLine.erace(command: .eraceFromCursorToBegin)
			result = true
		case .eraceFromBeginToEnd:
			mCommandLine.erace(command: .eraceFromBeginToEnd)
			result = true
		case .eraceEntireBuffer:
			mCommandLine.erace(command: .eraceFromBeginToEnd)
			result = true
		case .scrollUp, .scrollDown:
			result = false
		case .foregroundColor(_), .backgroundColor(_), .setNormalAttributes:
			result = true			/* ignored */
		}
		return result
	}

	private func set(console cons: CNFileConsole) {
		/* Restore current handler */
		CNReadline.restoreRawMode(fileHandle: mConsole.inputHandle, originalTerm: mPreviousTerm)
		/* Update for new one */
		mPreviousTerm = CNReadline.enableRawMode(fileHandle: cons.inputHandle)
		mConsole = cons
	}

	/*
	 * Following code is copied from StackOverflow.
	 * See https://stackoverflow.com/questions/49748507/listening-to-stdin-in-swift
	 */
	private static func initStruct<S>() -> S {
	    let struct_pointer = UnsafeMutablePointer<S>.allocate(capacity: 1)
	    let struct_memory = struct_pointer.pointee
	    struct_pointer.deallocate()
	    return struct_memory
	}

	private static func enableRawMode(fileHandle: FileHandle) -> termios {
	    var raw: termios = initStruct()
	    tcgetattr(fileHandle.fileDescriptor, &raw)

	    let original = raw

	    raw.c_lflag &= ~(UInt(ECHO | ICANON))
	    tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &raw);

	    return original
	}

	private static func restoreRawMode(fileHandle: FileHandle, originalTerm: termios) {
	    var term = originalTerm
	    tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &term);
	}
}

