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

	public struct Context {
		public var	fixedCommands:	Array<String>
		public var 	commandLine:	String
		public var	position:	Int
		public init(fixedCommands fcmds: Array<String>, commandLine cmdline: String, position pos: Int) {
			fixedCommands	= fcmds
			commandLine	= cmdline
			position	= pos
		}
	}

	private var	mFixedCommands:		Array<String>
	private var	mCommandLine:		String
	private var	mCurrentIndex:		String.Index
	private var 	mCurrentPosition:	Int
	private var	mDidUpdated:		Bool

	public init(){
		mFixedCommands	 = []
		mCommandLine	 = ""
		mCurrentIndex	 = mCommandLine.endIndex
		mCurrentPosition = 0
		mDidUpdated	 = true
	}

	public var didUpdated: Bool { get { return mDidUpdated }}
	public var context: Context {
		get {
			let ctxt = Context(fixedCommands: mFixedCommands, commandLine: mCommandLine, position: mCurrentPosition)
			mFixedCommands	 = []
			//mCommandLine	 = ""
			//mCurrentIndex	 = mCommandLine.startIndex
			//mCurrentPosition = 0
			mDidUpdated      = false
			return ctxt
		}
	}

	public func replace(string str: String){
		mCommandLine	 = str
		mCurrentIndex	 = str.endIndex
		mCurrentPosition = str.count
		mDidUpdated 	 = true
	}

	public func enter() {
		mFixedCommands.append(mCommandLine)
		replace(string: "")
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
		mDidUpdated = true
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
		mDidUpdated = true
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
				mDidUpdated	 =  true
			}
		case .eraceFromCursorToEnd:
			if mCurrentIndex < mCommandLine.endIndex {
				let subrange = mCurrentIndex..<mCommandLine.endIndex
				mCommandLine.removeSubrange(subrange)
				/* Index is not changed */
				mDidUpdated      = true
			}
		case .eraceFromCursorToBegin:
			if mCommandLine.startIndex < mCurrentIndex {
				let subrange = mCommandLine.startIndex..<mCurrentIndex
				mCommandLine.removeSubrange(subrange)
				mCurrentIndex	 = mCommandLine.startIndex
				mCurrentPosition = 0
				mDidUpdated	 =  true
			}

		case .eraceFromBeginToEnd:
			if mCommandLine.count > 0 {
				mCommandLine	 = ""
				mCurrentIndex	 = mCommandLine.startIndex
				mCurrentPosition = 0
				mDidUpdated      = true
			}
		}
	}

	private func erace(subRange srange: Range<String.Index>) {
		mCommandLine.removeSubrange(srange)
		mCurrentIndex    = mCommandLine.startIndex
		mCurrentPosition = 0
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

	open func readLine() -> CNCommandLine {
		if let str = self.scan() {
			switch CNEscapeCode.decode(string: str) {
			case .ok(let codes):
				for code in codes {
					mCurrentBuffer.push(code)
				}
				flushBuffer()
			case .error(let err):
				let msg = "[Error] " + err.description()
				mConsole.error(string: msg)
			}
		}
		return mCommandLine
	}

	open func scan() -> String? {
		return mConsole.scan()
	}

	private func flushBuffer() {
		var docont: Bool = true
		while docont && mCurrentBuffer.count > 0 {
			if let ecode = mCurrentBuffer.pop() {
				switch flushCode(escapeCode: ecode) {
				case .doContinue:
					break
				case .doIgnore:
					break
				case .doFlush:
					docont = false
					break
				}
			} else {
				break
			}
		}
	}

	private enum FlushResult {
		case doIgnore
		case doContinue
		case doFlush
	}

	private func flushCode(escapeCode ecode: CNEscapeCode) -> FlushResult {
		var result: FlushResult = .doIgnore
		switch ecode {
		case .string(let str):
			mCommandLine.insert(string: str)
		case .newline:
			mCommandLine.enter()
		case .tab:
			mCommandLine.insert(string: "\t")
		case .backspace:
			mCommandLine.erace(command: .eraceCursorLeft)
		case .cursorUp(let n), .cursorPreviousLine(let n):
			if let newstr = mCommandHistory.traceHistory(delta: -n) {
				mCommandLine.replace(string: newstr)
			}
		case .cursorDown(let n), .cursorNextLine(let n):
			if let newstr = mCommandHistory.traceHistory(delta: n) {
				mCommandLine.replace(string: newstr)
			}
		case .cursorForward(let n):
			mCommandLine.moveCursor(delta: n)
		case .cursorBack(let n):
			mCommandLine.moveCursor(delta: -n)
		case .cursorHolizontalAbsolute(_):
			result = .doIgnore
		case .cursorPoisition(_, _):
			result = .doIgnore
		case .eraceFromCursorToEnd:
			mCommandLine.erace(command: .eraceFromCursorToEnd)
		case .eraceFromCursorToBegin:
			mCommandLine.erace(command: .eraceFromCursorToBegin)
		case .eraceFromBeginToEnd:
			mCommandLine.erace(command: .eraceFromBeginToEnd)
		case .eraceEntireBuffer:
			mCommandLine.erace(command: .eraceFromBeginToEnd)
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

