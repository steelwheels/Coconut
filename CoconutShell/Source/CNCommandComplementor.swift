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
	private var 	mCommandNames:		Array<String>
	private var	mMaxNameWidth:		Int
	private var	mCommandTable:		Dictionary<String, String>

	public var isComplementing: Bool { get { return mIsComplementing }}

	public init() {
		mIsComplementing	= false
		mCommandTable		= [:]
		mCommandNames		= []
		mMaxNameWidth		= 0
	}

	public func beginComplement(commandString cmdstr: String, environment env: CNEnvironment) {
		if mCommandNames.count == 0 {
			updateCommandNameList(environment: env)
		}
		mIsComplementing = true
	}

	public func endComplement() {
		mIsComplementing = false
	}

	private func updateCommandNameList(environment env: CNEnvironment) {
		let fmanager = FileManager.default
		mCommandNames = []
		mMaxNameWidth = 0
		for path in env.paths {
			switch fmanager.checkFileType(pathString: path) {
			case .Directory:
				do {
					let fnames = try fmanager.contentsOfDirectory(atPath: path)
					for fname in fnames {
						let fullname = path + "/" + fname
						if fmanager.isExecutableFile(atPath: fullname) {
							mCommandNames.append(fname)
							mMaxNameWidth = max(mMaxNameWidth, fname.lengthOfBytes(using: .utf8))
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

