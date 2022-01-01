/*
 * @file	CNValueCache.swift
 * @brief	Define CNValueCache class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public class CNValueCache
{
	public typealias Result = CNValueParser.Result

	private var mRootURL:		URL
	private var mRootValue:		Dictionary<String, CNValue>
	private var mParentCache:	CNValueCache?

	public init(root rooturl: URL, parentCache pc: CNValueCache?) {
		mRootURL	= rooturl
		mRootValue	= [:]
		mParentCache	= pc
	}

	/* The cache which has no file to load/save contents */
	public static func allocateVolatileValueCache() -> CNValueCache {
		return CNValueCache(root: URL.null(), parentCache: nil)
	}

	public func load(relativePath rpath: String) -> Result {
		let url = mRootURL.appendingPathComponent(rpath, isDirectory: false)
		guard let ctxt = url.loadContents() else {
			let err = NSError.fileError(message: "Failed to read file from \(url.path)")
			return .error(err)
		}
		let parser = CNValueParser()
		let result: Result
		switch parser.parse(source: ctxt as String) {
		case .ok(let val):
			switch val {
			case .dictionaryValue(let dict):
				mRootValue = dict
				result = .ok(val)
			default:
				let err = NSError.fileError(message: "Not dictionary data")
				result = .error(err)
			}
		case .error(let err):
			result = .error(err)
		}
		return result
	}

	public func value(forPath path: Array<String>) -> CNValue? {
		if let locval = self.localValue(forPath: path) {
			return locval
		} else if let cashval = mParentCache?.localValue(forPath: path) {
			return cashval
		} else {
			return nil
		}
	}

	private func localValue(forPath path: Array<String>) -> CNValue? {
		guard let prop = path.last else {
			return nil
		}
		let midpath = path.dropLast()
		var owner: Dictionary<String, CNValue> = mRootValue
		for mid in midpath {
			var hasnext = false
			if let child = owner[mid] {
				switch child {
				case .dictionaryValue(let childdic):
					owner   = childdic
					hasnext = true
				case .reference(let childref):
					if let childval = childref.load(from: mRootURL) {
						if let childdic = childval.toDictionary() {
							owner   = childdic
							hasnext = true
						}
					}
				default:
					break
				}
			}
			if !hasnext {
				return nil
			}
		}
		switch owner[prop] {
		case .reference(let refval):
			return refval.load(from: mRootURL)
		default:
			return owner[prop]
		}
	}

	public func set(value val: CNValue, forPath path: Array<String>) -> Bool {
		guard path.count > 0 else {
			return false
		}
		mRootValue = localSet(destination: mRootValue, source: val, forPath: path)
		return true
	}

	private func localSet(destination dst: Dictionary<String, CNValue>, source src: CNValue, forPath path: Array<String>) -> Dictionary<String, CNValue> {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
			return [:]
		}
		let rest   = Array(path.dropFirst())
		var newdst = dst
		if rest.count == 0 {
			newdst[first] = src
			return newdst
		} else {
			if let dstelm = dst[first] {
				switch dstelm {
				case .dictionaryValue(let dstdic):
					let newdic = localSet(destination: dstdic, source: src, forPath: rest)
					newdst[first] = .dictionaryValue(newdic)
					return newdst
				case .reference(let dstref):
					if let refval = dstref.load(from: mRootURL) {
						if let dstdic = refval.toDictionary() {
							let newdic = localSet(destination: dstdic, source: src, forPath: rest)
							newdst[first] = .dictionaryValue(newdic)
							return newdst
						}
					}
				default:
					let pathstr = path.joined(separator: ".")
					CNLog(logLevel: .error, message: "No such member: \(pathstr)", atFunction: #function, inFile: #file)
				}
			}
			/* Not found */
			let pathstr = path.joined(separator: ".")
			CNLog(logLevel: .error, message: "No such member: \(pathstr)", atFunction: #function, inFile: #file)
			return newdst
		}
	}

	public func store(relativePath rpath: String) -> Bool {
		/* Store child cache */
		storeChildren(value: mRootValue)
		/* Save to file */
		let file = mRootURL.appendingPathComponent(rpath)
		let txt  = CNValue.dictionaryValue(mRootValue).toText().toStrings().joined(separator: "\n")
		return file.storeContents(contents: txt + "\n")
	}

	private func storeChildren(value val: Dictionary<String, CNValue>) {
		for (_, elm) in val {
			switch elm {
			case .dictionaryValue(let dict):
				storeChildren(value: dict)
			case .reference(let val):
				if !val.store(to: mRootURL) {
					CNLog(logLevel: .error, message: "Failed to store cache", atFunction: #function, inFile: #file)
				}
			default:
				break
			}
		}
	}
}


