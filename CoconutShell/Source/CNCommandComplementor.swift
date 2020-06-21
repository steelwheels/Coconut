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
	private var	mIsComplementing:	Bool
	private var	mCommandTable:		Dictionary<String, String> = [:]

	public var isComplementing: Bool { get { return mIsComplementing }}

	public init() {
		mIsComplementing	= false
		mCommandTable		= [:]
	}

	public func beginComplement(commandLine cmdline: String) {
		mIsComplementing = true
	}

	public func endComplement() {
		mIsComplementing = false
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

