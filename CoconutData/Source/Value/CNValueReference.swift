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

	public convenience init?(value val: Dictionary<String, CNValue>) {
		if let rpathval = val[CNValueReference.RelativePathItem] {
			if let rpath = rpathval.toString() {
				self.init(relativePath: rpath)
				return
			}
		}
		return nil
	}

	public convenience init?(value val: CNValue){
		if let dict = val.toDictionary() {
			self.init(value: dict)
			return
		} else {
			return nil
		}
	}

	public func load(from base: URL) -> CNValue? {
		if let ctxt = mContext {
			return ctxt
		} else {
			let url    = base.appendingPathComponent(self.relativePath)
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

	public func store(to base: URL) -> Bool {
		if let context = mContext {
			let file = base.appendingPathComponent(self.relativePath)
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

