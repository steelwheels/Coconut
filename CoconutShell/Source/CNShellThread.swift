/**
 * @file	CNShellThread.swift
 * @brief	Define CNShellThread class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation


open class CNShellThread: CNThread
{
	public enum ShellMode {
		case readline
		case curses
	}

	private struct ReadlineStatus {
		var	doPrompt	: Bool
		var	editingLine	: String
		var 	editingPosition	: Int

		public init(doPrompt prompt: Bool){
			doPrompt	= prompt
			editingLine	= ""
			editingPosition	= 0
		}
	}

	private struct CursesStatus {
		var	cursorVisible:	Bool

		public init(cursorVisible vis: Bool){
			cursorVisible = vis
		}
	}

	private var mMode:		ShellMode
	private var mReadline:		CNReadline
	private var mReadlineStatus:	ReadlineStatus
	private var mCurses:		CNCurses
	private var mCursesStatus:	CursesStatus
	private var mConfig:		CNConfig
	private var mPreviousTerm:	termios

	public var config: CNConfig { get { return mConfig }}
	public var mode: ShellMode {
		get { return mMode }
		set(newmode) {
			mMode 		= newmode
			switch newmode {
			case .readline:		mReadlineStatus = ReadlineStatus(doPrompt: true)
			case .curses:		break
			}
		}
	}

	public init(input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, config conf: CNConfig, terminationHander termhdlr: TerminationHandler?){
		mMode		= .readline
		mReadline 	= CNReadline()
		mReadlineStatus	= ReadlineStatus(doPrompt: true)
		mCurses		= CNCurses()
		mCursesStatus	= CursesStatus(cursorVisible: true)
		mConfig		= conf
		mPreviousTerm	= CNShellThread.enableRawMode(fileStream: instrm)
		super.init(input: instrm, output: outstrm, error: errstrm, terminationHander: termhdlr)
	}

	deinit {
		CNShellThread.restoreRawMode(fileHandle: super.console.inputHandle, originalTerm: mPreviousTerm)
	}

	open override func start() {
		super.start()
	}

	open override func mainOperation() -> Int32 {
		while !isCancelled {
			switch mMode {
			case .readline:
				shellOperation()
			case .curses:
				break
			}
		}
		return 0
	}

	open func promptString() -> String {
		return "$ "
	}

	private func shellOperation() {
		let BS  = CNEscapeCode.backspace.encode()
		let DEL = BS + " " + BS

		if mReadlineStatus.doPrompt {
			self.console.print(string: promptString() + mReadlineStatus.editingLine)
			mReadlineStatus.doPrompt = false
		}
		/* Read command line */
		switch mReadline.readLine(console: self.console) {
		case .commandLine(let cmdline):
			let determined        = cmdline.didDetermined
			let (newline, newpos) = cmdline.get()
			if determined {
				/* Execute command */
				console.print(string: "\n") // Execute at new line
				execute(command: newline)
				/* Reset terminal */
				let resetstr = CNEscapeCode.setNormalAttributes.encode()
				console.print(string: resetstr)
				/* Print prompt again */
				mReadlineStatus.doPrompt	= true
				mReadlineStatus.editingLine     = ""
				mReadlineStatus.editingPosition	= 0
			} else {
				/* Move cursor to end of line */
				let forward = mReadlineStatus.editingLine.count - mReadlineStatus.editingPosition
				let fwdstr  = CNEscapeCode.cursorForward(forward).encode()
				if forward > 0 {
					console.print(string: fwdstr)
				}
				/* Erace current command line */
				let curlen  = mReadlineStatus.editingLine.count
				for _ in 0..<curlen {
					console.print(string: DEL)
				}
				/* Print new command line */
				console.print(string: newline)
				/* Adjust cursor */
				let newlen = newline.count
				let back   = newlen - newpos
				let bakstr = CNEscapeCode.cursorBack(back).encode()
				if back > 0 {
					console.print(string: bakstr)
				}
				/* Update current line*/
				mReadlineStatus.editingLine     = newline
				mReadlineStatus.editingPosition = newpos
			}
		case .escapeCode(let code):
			console.error(string: "ECODE: \(code.description())\n")
		case .none:
			break
		}
	}

	open func execute(command cmd: String) {
		console.error(string: "execute: \(cmd)\n")
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

	private static func enableRawMode(fileStream: CNFileStream) -> termios {
		switch fileStream {
		case .fileHandle(let handle):
			return enableRawMode(fileHandle: handle)
		case .pipe(let pipe):
			return enableRawMode(fileHandle: pipe.fileHandleForReading)
		case .null:
			fatalError()
		}
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
