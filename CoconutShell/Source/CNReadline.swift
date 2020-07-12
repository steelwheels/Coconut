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
	private var mEnvironment:	CNEnvironment
	private var mCommandLines:	CNCommandLines
	private var mComplementor:	CNComplementor
	private var mCurrentBuffer:	CNQueue<CNEscapeCode>

	public init(complementor compl: CNComplementor, environment env: CNEnvironment){
		mEnvironment	= env
		mCommandLines	= CNCommandLines()
		mComplementor	= compl
		mCurrentBuffer	= CNQueue<CNEscapeCode>()
	}

	public enum Result {
		case	none 					// No action needed
		case	commandLine(CNCommandLine, Bool)	// (commandline, determined)
		case	escapeCode(CNEscapeCode)
	}

	open func readLine(console cons: CNConsole, terminalInfo terminfo: CNTerminalInfo) -> Result {
		/* Check command queue */
		if let code = mCurrentBuffer.pop() {
			return decode(escapeCode: code, console: cons, terminalInfo: terminfo)
		}
		/* Scan input */
		if let str = self.scan(console: cons) {
			/* Finish complement */
			mComplementor.endComplement(console: cons)

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
		return .none
	}

	public func replaceReplayCommand(source src: String) -> String {
		return mCommandLines.replaceReplayCommand(source: src)
	}

	public func addCommand(command cmd: String) {
		mCommandLines.addCommand(command: cmd)
	}

	private func decode(escapeCode code: CNEscapeCode, console cons: CNConsole, terminalInfo terminfo: CNTerminalInfo) -> Result {
		let cmdline = mCommandLines.currentCommand
		let result: Result
		switch code {
		case .string(let str):
			cmdline.insert(string: str)
			result = .commandLine(cmdline, false)
		case .eot:
			result = .escapeCode(code)
		case .newline:
			result = .commandLine(cmdline, true)
		case .tab:
			switch mComplementor.beginComplement(commandString: cmdline.string, console: cons, environment: mEnvironment, terminalInfo: terminfo) {
			case .none:
				break
			case .matched(let newstr):
				let orgstr = cmdline.string
				let delta  = newstr.dropFirst(orgstr.count)
				mCurrentBuffer.push(.string(String(delta)))
			case .popup(_):
				break
			}
			result = .none
		case .backspace:
			cmdline.moveCursor(delta: -1)
			result = .commandLine(cmdline, false)
		case .delete:
			cmdline.erace(command: .eraceCursorLeft)
			result = .commandLine(cmdline, false)
		case .cursorUp(let n), .cursorPreviousLine(let n):
			if let newcmd = mCommandLines.upCommand(count: n) {
				result = .commandLine(newcmd, false)
			} else {
				result = .commandLine(cmdline, false)
			}
		case .cursorDown(let n), .cursorNextLine(let n):
			if let newcmd = mCommandLines.downCommand(count: n) {
				result = .commandLine(newcmd, false)
			} else {
				result = .commandLine(cmdline, false)
			}
		case .cursorForward(let n):
			cmdline.moveCursor(delta: n)
			result = .commandLine(cmdline, false)
		case .cursorBackward(let n):
			cmdline.moveCursor(delta: -n)
			result = .commandLine(cmdline, false)
		case .cursorHolizontalAbsolute(_):
			result = .none
		case .saveCursorPosition:
			result = .escapeCode(code)
		case .restoreCursorPosition:
			result = .escapeCode(code)
		case .cursorPosition(_, _):
			result = .none
		case .eraceFromCursorToEnd:
			result = .escapeCode(code)
		case .eraceFromCursorToBegin:
			result = .escapeCode(code)
		case .eraceEntireBuffer:
			result = .escapeCode(code)
		case .eraceFromCursorToLeft:
			cmdline.erace(command: .eraceFromCursorToBegin)
			result = .commandLine(cmdline, false)
		case .eraceFromCursorToRight:
			cmdline.erace(command: .eraceFromCursorToEnd)
			result = .commandLine(cmdline, false)
		case .eraceEntireLine:
			cmdline.erace(command: .eraceEntireBuffer)
			result = .commandLine(cmdline, false)
		case .scrollUp, .scrollDown:
			result = .escapeCode(code)
		case .resetAll:
			cmdline.erace(command: .eraceEntireBuffer)
			result = .escapeCode(code)
		case .resetCharacterAttribute,
		     .foregroundColor(_), .defaultForegroundColor,
		     .backgroundColor(_), .defaultBackgroundColor:
			result = .escapeCode(code)
		case .boldCharacter(_),
		     .blinkCharacter(_),
		     .underlineCharacter(_),
		     .reverseCharacter(_):
			result = .escapeCode(code)
		case .requestScreenSize:
			result = .escapeCode(code)
		case .screenSize(_, _):
			result = .escapeCode(code)
		case .selectAltScreen(_):
			result = .escapeCode(code)
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

