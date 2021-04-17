/**
 * @file	CNCommandComplementer.swift
 * @brief	Define CNCommandComplementer class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNCommandComplemeter
{
	public enum ComplementationResult {
		case none
		case matched(String)
		case candidates(Array<String>)
	}

	private var mTerminalInfo:	CNTerminalInfo
	private var mCommandTable:	CNCommandTable

	public init(terminalInfo terminfo: CNTerminalInfo, commandTable table: CNCommandTable){
		mTerminalInfo	= terminfo
		mCommandTable	= table
	}

	public func complement(string str: String, index idx: String.Index) -> ComplementationResult {
		let line  = str.prefix(upTo: idx)
		if line.count > 0 {
			let words = line.components(separatedBy: .whitespaces)
			if words.count == 1 {
				let matches = mCommandTable.matchPrefix(string: words[0])
				if matches.count > 1 {
					let table = makeTable(commands: matches)
					return .candidates(table)
				} else if matches.count == 1 {
					return .matched(matches[0] + " ")
				}
			}
		}
		return .none
	}

	private func makeTable(commands cmds: Array<String>) -> Array<String> {
		/* get the length of commands */
		var maxlen = 0
		cmds.forEach {
			maxlen = max(maxlen, $0.count + 1) // +1 for space
		}
		guard maxlen > 0 else {
			return []
		}

		/* When the max length > terminal width, truncate the command */
		let cmds0: Array<String>
		if maxlen > mTerminalInfo.width {
			maxlen = mTerminalInfo.width
			cmds0  = cmds.map { String($0.prefix(maxlen)) }
		} else {
			cmds0  = cmds
		}

		/* How many command names can be in 1 line */
		let colnum = mTerminalInfo.width / maxlen

		var result: Array<String> = []
		for i in 0..<cmds0.count {
			/* Prepare one command string */
			var cmd    = cmds0[i]
			let cmdlen = cmd.count
			if cmdlen < maxlen {
				cmd.append(String(repeating: " ", count: maxlen - cmdlen))
			}
			/* Make result table */
			let col = i % colnum
			let row = i / colnum
			if col == 0 {
				result.append(cmd)
			} else {
				result[row].append(cmd)
			}
		}
		return result
	}
}

