/*
 * @file	CNValueReference.swift
 * @brief	Define CNValueReference class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNValueReference
{
	public static let ClassName		= "reference"
	public static let RelativePathItem	= "relativePath"

	public var relativePath	: String
	private var mContext	: CNValue?

	public init(relativePath rpath: String){
		relativePath	= rpath
		mContext	= nil
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNValueReference? {
		if let rpathval = val[CNValueReference.RelativePathItem] {
			if let rpath = rpathval.toString() {
				return CNValueReference(relativePath: rpath)
			}
		}
		return nil
	}

	public func load(fromPackageDirectory packdir: URL) -> CNValue? {
		if let ctxt = mContext {
			return ctxt
		} else {
			let url = packdir.appendingPathComponent(self.relativePath)
			var result: CNValue? = nil
			if let source = url.loadContents() {
				let parser = CNValueParser()
				switch parser.parse(source: source as String) {
				case .ok(let val):
					mContext = val
					result   = val
				case .error(let err):
					CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
				}
			}
			return result
		}
	}

	public func store(toPackageDirectory resdir: URL) -> Bool {
		if let context = mContext {
			let file = resdir.appendingPathComponent(self.relativePath)
			let txt  = context.toText().toStrings().joined(separator: "\n")
			return file.storeContents(contents: txt)
		} else {
			return false
		}
	}

	func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"class"					: .stringValue(CNValueReference.ClassName),
			CNValueReference.RelativePathItem	: .stringValue(self.relativePath)
		]
		return result
	}

	func compare(_ val: CNValueReference) -> ComparisonResult {
		if self.relativePath < val.relativePath {
			return .orderedAscending
		} else if self.relativePath > val.relativePath {
			return .orderedDescending
		} else {
			return .orderedSame
		}
	}
}

