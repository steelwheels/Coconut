/*
 * @file  CNCommandTable.swift
 * @brief  Define CNCommandTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNCommandTable
{
	private var mCommandTable: Dictionary<String, String>	// command-name, command-path

	public init(){
		mCommandTable = [:]
	}

	public var names: Array<String> {
		get { return Array<String>(mCommandTable.keys) }
	}

	public func read(from env: CNEnvironment) {
		let fmgr  = FileManager.default
		let paths = env.paths
		for path in paths {
			do {
				let fnames = try fmgr.contentsOfDirectory(atPath: path)
				for fname in fnames {
					let pathname = path + "/" + fname
					mCommandTable[fname] = pathname
				}
			}
			catch let err as NSError {
				NSLog("[Error] \(err.toString()) at \(#function)")
			}
		}
	}

	public func matchPrefix(string src: String) -> Array<String> {
		let cmds  = mCommandTable.keys
		let matched = cmds.filter { $0.hasPrefix(src) }
		return matched.sorted()
	}
}
