/*
 * @file	CNUnixCommand.swift
 * @brief	Define CNUnixCommand class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNUnixCommandTable
{
	private static var mUnixCommandTable: CNUnixCommandTable? = nil

	public static var shared: CNUnixCommandTable {
		get {
			if let table = mUnixCommandTable {
				return table
			} else {
				let newtable = CNUnixCommandTable()
				mUnixCommandTable = newtable
				return newtable
			}
		}
	}

	public struct CommandInfo {
		var 	path: String

		init(path pstr: String){
			path = pstr
		}
	}

	private var mCommandTable: Dictionary<String, CommandInfo>

	private init() {
		mCommandTable	= [:]

		#if os(OSX)
			let fmanager = FileManager.default
			let cmddirs  = ["/bin", "/usr/bin"]
			for cmddir in cmddirs {
				do {
					let cmdnames = try fmanager.contentsOfDirectory(atPath: cmddir)
					for cmdname in cmdnames {
						let cmdinfo = CommandInfo(path: cmddir)
						mCommandTable[cmdname] = cmdinfo
					}
				} catch {
					NSLog("Can not access directory: \(cmddir)")
				}
			}
		#endif
	}

	public var commandNames: Array<String> {
		get { return Array(mCommandTable.keys) }
	}
}
