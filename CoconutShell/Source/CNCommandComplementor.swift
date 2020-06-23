/*
 * @file	CNCommandComplementer.swift
 * @brief	Define CNCommandComplementer class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNCommandComplementor
{
	public enum ComplementState {
	case none
	case popup(Int)		// Number of pop upped line num
	}

	private var	mComplementState:	ComplementState
	private var 	mCommandNames:		Array<String>
	private var	mCommandTable:		Dictionary<String, String>

	public var isComplementing: Bool { get {
		let result: Bool
		switch mComplementState {
		case .popup(_):		result = true
		default:		result = false
		}
		return result
	}}

	public init() {
		mComplementState	= .none
		mCommandTable		= [:]
		mCommandNames		= []
	}

	public func beginComplement(commandString cmdstr: String, console cons: CNConsole, environment env: CNEnvironment, terminalInfo terminfo: CNTerminalInfo) {
		if mCommandNames.count == 0 {
			updateCommandNameList(environment: env)
		}
		guard let matched = matchedItems(commandString: cmdstr) else {
			mComplementState = .none
			return
		}
		guard matched.count > 0 else {
			mComplementState = .none
			return
		}

		/* Make multi column list */
		let items   = foldItems(items: matched, terminalInfo: terminfo)

		/* Keep current cursor position */
		cons.print(string: CNEscapeCode.saveCursorPosition.encode())
		/* Scrollup n lines */
		for item in items {
			cons.print(string: CNEscapeCode.scrollUp(1).encode())
			cons.print(string: CNEscapeCode.cursorNextLine(1).encode())
			cons.print(string: item)
		}
		/* Update state*/
		mComplementState = .popup(items.count)
	}

	private func matchedItems(commandString cmdstr: String) -> Array<String>? {
		if cmdstr.count > 0 {
			/* Split to words */
			var words: Array<String> = []
			for substr in cmdstr.components(separatedBy: .whitespaces) {
				if substr.count > 0 {
					words.append(substr)
				}
			}
			/* Match by command, option and parameters */
			if words.count == 1 {
				/* Select command */
				return matchByCommand(commandString: words[0])
			}
		}
		return nil
	}

	private func matchByCommand(commandString cmdstr: String) -> Array<String>? {
		let cmdlen = cmdstr.lengthOfBytes(using: .utf8)
		var result: Array<String> = []
		for name in mCommandNames {
			if name.lengthOfBytes(using: .utf8) >= cmdlen {
				if name.prefix(cmdlen) == cmdstr {
					result.append(name)
				}
			}
		}
		return result.count > 0 ? result : nil
	}

	private func foldItems(items itms: Array<String>, terminalInfo terminfo: CNTerminalInfo) -> Array<String> {
		/* Get max width */
		var maxwidth = 0
		for item in itms {
			maxwidth = max(maxwidth, item.lengthOfBytes(using: .utf8))
		}
		/* Get width */
		let colnum = Int(ceil(Double(terminfo.width) / Double(maxwidth + 1))) // +1 for space
		let width  = terminfo.width / colnum
		var result: Array<String> = []
		for i in stride(from: 0, to: itms.count, by: colnum) {
			var line: String = ""
			for j in 0..<colnum {
				let idx = i + j
				if idx < itms.count {
					let item = itms[idx]
					line += item
					let len  = item.lengthOfBytes(using: .utf8)
					let diff = width - len
					if diff > 0 {
						line += String(repeating: " ", count: diff)
					}
				}
			}
			result.append(line)
		}
		return result
	}

	public func endComplement(console cons: CNConsole) {
		switch mComplementState {
		case .none:
			break	// do nothing
		case .popup(let lines):
			/* Scroll down */
			cons.print(string: CNEscapeCode.scrollDown(lines).encode())
			/* Restore current cursor position */
			cons.print(string: CNEscapeCode.restoreCursorPosition.encode())
			/* Reset */
			mComplementState = .none
		}
	}

	private func updateCommandNameList(environment env: CNEnvironment) {
		let fmanager = FileManager.default
		mCommandNames = []
		for path in env.paths {
			switch fmanager.checkFileType(pathString: path) {
			case .Directory:
				do {
					let fnames = try fmanager.contentsOfDirectory(atPath: path)
					for fname in fnames {
						let fullname = path + "/" + fname
						if fmanager.isExecutableFile(atPath: fullname) {
							mCommandNames.append(fname)
						}
					}
				} catch let err {
					let errobj = err as NSError
					NSLog("updateCommandNameList: \(errobj.toString())")
				}
			case .File, .NotExist:
				break
			}
		}
	}

	private func searchCommand(commandName name: String, environment env: CNEnvironment) -> String? {
		if let cmdpath = mCommandTable[name] {
			return cmdpath
		} else {
			let fmanager = FileManager.default
			let paths    = env.paths
			for path in paths {
				let cmdpath = path + "/" + name
				if fmanager.fileExists(atPath: cmdpath) {
					if fmanager.isExecutableFile(atPath: cmdpath) {
						mCommandTable[name] = cmdpath
						return cmdpath
					}
				}
			}
			return nil
		}
	}
}

