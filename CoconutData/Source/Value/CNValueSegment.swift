/*
 * @file	CNValueSegment.swift
 * @brief	Define CNValueSegment class
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public class CNValueSegment
{
	public static let ClassName		= "segment"
	public static let RelativePathItem	= "relativePath"

	public var relativePath	: String
	private var mContext	: CNValue?

	public init(relativePath rpath: String){
		relativePath	= rpath
		mContext	= nil
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNValueSegment? {
		if let rpathval = val[CNValueSegment.RelativePathItem] {
			if let rpath = rpathval.toString() {
				return CNValueSegment(relativePath: rpath)
			}
		}
		return nil
	}

	public func load(fromSourceDirectory srcdir: URL, cacheDirectory cachedir: URL) -> CNValue? {
		if let ctxt = mContext {
			return ctxt
		} else {
			/* Copy the source file into cache file */
			let srcfile   = srcdir.appendingPathComponent(self.relativePath)
			let cachefile = cachedir.appendingPathComponent(self.relativePath)

			guard let contents = CNValueStorage.createCacheFile(cacheFile: cachefile, sourceFile: srcfile) else {
				CNLog(logLevel: .error, message: "Failed to create cache file: \(cachefile.path)", atFunction: #function, inFile: #file)
				return nil
			}
			var result: CNValue? = nil
			let parser = CNValueParser()
			switch parser.parse(source: contents) {
			case .ok(let val):
				mContext = val
				result   = val
			case .error(let err):
				CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
			}
			return result
		}
	}

	public func store(toCacheDirectory cachedir: URL) -> Bool {
		if let context = mContext {
			let file = cachedir.appendingPathComponent(self.relativePath)
			let txt  = context.toText().toStrings().joined(separator: "\n")
			return file.storeContents(contents: txt)
		} else {
			return false
		}
	}

	func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"class"				: .stringValue(CNValueSegment.ClassName),
			CNValueSegment.RelativePathItem	: .stringValue(self.relativePath)
		]
		return result
	}

	func compare(_ val: CNValueSegment) -> ComparisonResult {
		if self.relativePath < val.relativePath {
			return .orderedAscending
		} else if self.relativePath > val.relativePath {
			return .orderedDescending
		} else {
			return .orderedSame
		}
	}
}

