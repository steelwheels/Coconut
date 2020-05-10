/*
 * @file	CNReadline.swift
 * @brief	Define CNReadline class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation
import Darwin

open class CNReadline
{
	private var mCommandLines:	CNCommandLines
	private var mCurrentBuffer:	CNQueue<CNEscapeCode>

	public init(){
		mCommandLines	= CNCommandLines()
		mCurrentBuffer	= CNQueue<CNEscapeCode>()
	}

	public enum Result {
		case	commandLine(CNCommandLine)
		case	escapeCode(CNEscapeCode)
		case	empty
	}

	open func readLine(console cons: CNConsole) -> Result {
		/* Scan input */
		var result: Result = .empty
		if let str = self.scan(console: cons) {
			/* Push command into buffer */
			switch CNEscapeCode.decode(string: str) {
			case .ok(let codes):
				for code in codes {
					mCurrentBuffer.push(code)
				}
			case .error(let err):
				let msg = "[Error] " + err.description()
				cons.error(string: msg)
			}
		}
		/* Get latest command */
		if let code = mCurrentBuffer.pop() {
			if decode(escapeCode: code) {
				result = .commandLine(mCommandLines.currentCommand)
			} else {
				result = .escapeCode(code)
			}
		}
		return result
	}

	public func replaceReplayCommand(source src: String) -> String {
		return mCommandLines.replaceReplayCommand(source: src)
	}

	public func addCommand(command cmd: String) {
		mCommandLines.addCommand(command: cmd)
	}

	private func decode(escapeCode code: CNEscapeCode) -> Bool {
		let cmdline = mCommandLines.currentCommand
		let result: Bool
		switch code {
		case .string(let str):
			cmdline.insert(string: str)
			result = true
		case .eot:
			result = false			/* Skipped	*/
		case .newline:
			cmdline.determine()
			result = true
		case .tab:
			cmdline.insert(string: "\t")
			result = true
		case .backspace:
			cmdline.moveCursor(delta: -1)
			result = true
		case .delete:
			cmdline.erace(command: .eraceCursorLeft)
			result = true
		case .cursorUp(let n), .cursorPreviousLine(let n):
			let _ = mCommandLines.upCommand(count: n)
			result = true
		case .cursorDown(let n), .cursorNextLine(let n):
			let _ = mCommandLines.downCommand(count: n)
			result = true
		case .cursorForward(let n):
			cmdline.moveCursor(delta: n)
			result = true
		case .cursorBackward(let n):
			cmdline.moveCursor(delta: -n)
			result = true
		case .cursorHolizontalAbsolute(_):
			result = true			/* ignored */
		case .cursorPoisition(_, _):
			result = true			/* ignored */
		case .eraceFromCursorToEnd:
			result = false			/* skipped */
		case .eraceFromCursorToBegin:
			result = false			/* skipped */
		case .eraceEntireBuffer:
			result = false			/* skipped */
		case .eraceFromCursorToLeft:
			cmdline.erace(command: .eraceFromCursorToBegin)
			result = true
		case .eraceFromCursorToRight:
			cmdline.erace(command: .eraceFromCursorToEnd)
			result = true
		case .eraceEntireLine:
			cmdline.erace(command: .eraceEntireBuffer)
			result = true
		case .scrollUp, .scrollDown:
			result = false			/* skipped */
		case .resetCharacterAttribute,
		     .foregroundColor(_), .defaultForegroundColor,
		     .backgroundColor(_), .defaultBackgroundColor:
			result = true			/* ignored */
		case .boldCharacter(_),
		     .blinkCharacter(_),
		     .underlineCharacter(_),
		     .reverseCharacter(_):
			result = true			/* ignored */
		case .requestScreenSize:
			result = true			/* ignored */
		case .screenSize(_, _):
			result = false			/* Skipped */
		case .selectAltScreen(_):
			result = false			/* Skipped */
		}
		return result
	}

	open func scan(console cons: CNConsole) -> String? {
		return cons.scan()
	}

	public func history() -> Array<String> {
		return mCommandLines.history()
	}

	public func search(byIndex idx: Int) -> String? {
		let elmidx = mCommandLines.commandCount - idx
		if 0 <= elmidx && elmidx < mCommandLines.commandCount {
			if let cmdline = mCommandLines.command(at: elmidx) {
				return cmdline.string
			}
		}
		return nil
	}
}

