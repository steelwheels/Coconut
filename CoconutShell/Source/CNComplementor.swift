/*
 * @file	CNComplementer.swift
 * @brief	Define CNComplementer class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

open class CNComplementor
{
	public enum ComplementState {
	case none
	case matched(String)	// Replace the matched one
	case popup(Int)		// Number of pop upped line num
	}

	public enum MatchResult {
	case none
	case fullMatch(String)
	case partialMatch(Array<String>)
	}

	private enum SkipResult {
	case empty
	case finished(String)
	case next(String.Index)
	}

	private var	mComplementState:	ComplementState
	private var 	mCommandNames:		Array<String>
	private var	mCommandTable:		Dictionary<String, String>

	public var complementState: ComplementState {
		get { return mComplementState }
	}

	public init() {
		mComplementState	= .none
		mCommandTable		= [:]
		mCommandNames		= []
	}

	public func beginComplement(commandString cmdstr: String, console cons: CNConsole, environment env: CNEnvironment, terminalInfo terminfo: CNTerminalInfo) -> ComplementState {
		if mCommandNames.count == 0 {
			updateCommandNameList(environment: env)
		}
		switch matchedItems(commandString: cmdstr, environment: env) {
		case .none:
			mComplementState = .none
		case .fullMatch(let name):
			mComplementState = .matched(name)
		case .partialMatch(let matched):
			guard matched.count > 0 else {
				mComplementState = .none
				return mComplementState
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
		return mComplementState
	}

	private func matchedItems(commandString cmdstr: String, environment env: CNEnvironment) -> MatchResult {
		let end   = cmdstr.endIndex
		var idx   = cmdstr.startIndex
		var count = 0

		while idx < end {
			/* Skip first spaces */
			if let next = skipSpapces(index: idx, of: cmdstr) {
				idx = next
			} else {
				return .none
			}

			/* Scan last word */
			switch skipNonSpaces(index: idx, of: cmdstr) {
			case .empty:
				return .none
			case .finished(let word):
				if count == 0 {
					return matchByCommand(commandString: word)
				} else {
					let result: MatchResult
					switch matchByFilePath(filePath: word, environment: env) {
					case .none:
						result = .none
					case .fullMatch(let matched):
						let head = cmdstr[cmdstr.startIndex ..< idx]
						result = .fullMatch(head + matched)
					case .partialMatch(let matches):
						result = .partialMatch(matches)
					}
					return result
				}
			case .next(let next):
				idx = next
			}

			/* Word count */
			count += 1
		}
		return .none
	}

	private func skipSpapces(index idx: String.Index, of str: String) -> String.Index? {
		var ptr = idx
		let end = str.endIndex
		while ptr < end {
			if str[ptr].isWhitespace {
				ptr = str.index(after: ptr)
			} else {
				break
			}
		}
		if ptr < end {
			return ptr
		} else {
			return nil
		}
	}

	private func skipNonSpaces(index idx: String.Index, of str: String) -> SkipResult {
		var ptr = idx
		let end = str.endIndex
		while ptr < end {
			if !str[ptr].isWhitespace {
				ptr = str.index(after: ptr)
			} else {
				break
			}
		}
		if ptr < end {
			return .next(ptr)
		} else {
			if idx < ptr {
				let substr = String(str[idx..<ptr])
				return .finished(substr)
			} else {
				return .empty
			}
		}
	}

	private func matchByCommand(commandString cmdstr: String) -> MatchResult {
		var matched: Array<String> = []
		for name in mCommandNames {
			if name.hasPrefix(cmdstr) {
				matched.append(name)
			}
		}
		let result: MatchResult
		switch matched.count {
		case 0: 	result = .none
		case 1: 	result = .fullMatch(matched[0] + " ")	// space after command
		default:	result = .partialMatch(matched)
		}
		return result
	}

	private func matchByArgument(commandString cmdstr: String, arguments args: Array<String>, environment env: CNEnvironment) -> MatchResult {
		let cmdname = (cmdstr as NSString).lastPathComponent
		if searchMachedCommand(commandName: cmdname) {
			if let lastname = args.last {
				return matchByFilePath(filePath: lastname, environment: env)
			}
		}
		return .none
	}

	private func searchMachedCommand(commandName name: String) -> Bool {
		for cmd in mCommandNames {
			if cmd == name {
				return true
			}
		}
		return false
	}

	private func matchByFilePath(filePath path: String, environment env: CNEnvironment) -> MatchResult {
		let nspath   = path as NSString
		let subdir   = nspath.deletingLastPathComponent
		let lastcomp = nspath.lastPathComponent
		if let dir = matchBySubdirPath(dirPath: subdir, environment: env) {
			do {
				let contents = try FileManager.default.contentsOfDirectory(atPath: dir)
				var matched: Array<String> = []
				for item in contents {
					if item.hasPrefix(lastcomp) {
						matched.append(item)
					}
				}
				let result: MatchResult
				switch matched.count {
				case 0:
					result = .none
				case 1:
					if subdir.isEmpty {
						result = .fullMatch(matched[0])
					} else {
						result = .fullMatch(subdir + "/" + matched[0])
					}
				default:
					result = .partialMatch(matched)
				}
				return result
			} catch _ {
				return .none
			}
		}
		return .none
	}

	private func matchBySubdirPath(dirPath dir: String, environment env: CNEnvironment) -> String? {
		if dir.isEmpty || dir == "." {
			return env.currentDirectory.path
		} else {
			let result: String?
			let path = env.currentDirectory.path + "/" + dir
			switch FileManager.default.checkFileType(pathString: path) {
			case .File, .NotExist:
				result = nil
			case .Directory:
				result = path
			}
			return result
		}
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
			break
		case .matched(_):
			break
		case .popup(let lines):
			/* Scroll down */
			cons.print(string: CNEscapeCode.scrollDown(lines).encode())
			/* Restore current cursor position */
			cons.print(string: CNEscapeCode.restoreCursorPosition.encode())
		}
		/* Reset */
		mComplementState = .none
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

	private func updateCommandTable(commandName name: String, environment env: CNEnvironment) -> String? {
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

