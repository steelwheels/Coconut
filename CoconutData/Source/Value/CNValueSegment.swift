/*
 * @file	CNValueSegment.swift
 * @brief	Define CNValueSegment class
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public class CNValueSegment
{
	public static let ClassName	= "segment"
	public static let FileItem	= "file"

	public var  filePath	: String
	private var mContext	: CNValue?

	public init(filePath rpath: String){
		filePath	= rpath
		mContext	= nil
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNValueSegment? {
		if CNValue.hasClassName(inValue: val, className: CNValueSegment.ClassName) {
			if let rpathval = val[CNValueSegment.FileItem] {
				if let rpath = rpathval.toString() {
					return CNValueSegment(filePath: rpath)
				}
			} else {
				CNLog(logLevel: .error, message: "No \(CNValueSegment.FileItem) property", atFunction: #function, inFile: #file)
			}
		}
		return nil
	}

	public func load(fromSourceDirectory srcdir: URL, cacheDirectory cachedir: URL) -> CNValue? {
		if let ctxt = mContext {
			return ctxt
		} else {
			/* Copy the source file into cache file */
			let srcfile   = srcdir.appendingPathComponent(self.filePath)
			let cachefile = cachedir.appendingPathComponent(self.filePath)

			guard let contents = CNValueStorage.createCacheFile(cacheFile: cachefile, sourceFile: srcfile) else {
				CNLog(logLevel: .error, message: "Failed to create cache file: \(cachefile.path)", atFunction: #function, inFile: #file)
				return nil
			}
			var result: CNValue? = nil
			let parser = CNValueParser()
			switch parser.parse(source: contents) {
			case .success(let val):
				mContext = val
				result   = val
			case .failure(let err):
				CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
			}
			return result
		}
	}

	public func store(toCacheDirectory cachedir: URL) -> Bool {
		if let context = mContext {
			let file = cachedir.appendingPathComponent(self.filePath)
			let txt  = context.toText().toStrings().joined(separator: "\n")
			return file.storeContents(contents: txt)
		} else {
			return false
		}
	}

	func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"class"			: .stringValue(CNValueSegment.ClassName),
			CNValueSegment.FileItem	: .stringValue(self.filePath)
		]
		return result
	}

	func compare(_ val: CNValueSegment) -> ComparisonResult {
		if self.filePath < val.filePath {
			return .orderedAscending
		} else if self.filePath > val.filePath {
			return .orderedDescending
		} else {
			return .orderedSame
		}
	}
}

