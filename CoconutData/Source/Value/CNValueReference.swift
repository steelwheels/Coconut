/*
 * @file	CNValueReference.swift
 * @brief	Define CNValueReference class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNValueReference
{
	static let ClassName	= "reference"

	static let RelativePathItem	= "relativePath"
	static let ContextItem		= "context"

	public var relativePath	: String
	public var context	: CNValue?

	public init(relativePath rpath: String){
		relativePath	= rpath
		context		= nil
	}

	public convenience init?(value val: Dictionary<String, CNValue>) {
		if let rpathval = val[CNValueReference.RelativePathItem] {
			if let rpath = rpathval.toString() {
				self.init(relativePath: rpath)
				if let ctxt = val[CNValueReference.ContextItem] {
					self.context = ctxt
				}
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

	func toValue() -> Dictionary<String, CNValue> {
		let context: CNValue
		if let ctxt = self.context {
			context = ctxt
		} else {
			context = .nullValue
		}
		let result: Dictionary<String, CNValue> = [
			"class"					: .stringValue(CNValueReference.ClassName),
			CNValueReference.RelativePathItem	: .stringValue(self.relativePath),
			CNValueReference.ContextItem		: context
		]
		return result
	}

	func compare(_ val: CNValueReference) -> ComparisonResult {
		if self.relativePath < val.relativePath {
			return .orderedAscending
		} else if self.relativePath > val.relativePath {
			return .orderedDescending
		} else { // url0 == url1
			let dat0 = self.context
			let dat1 = val.context
			if let v0 = dat0 {
				if let v1 = dat1 {
					return CNCompareValue(nativeValue0: v0, nativeValue1: v1)
				} else { // v0 != nil && v1 == nil
					return .orderedDescending
				}
			} else if let _ = dat1 { // v0 == nil && v1 != nil
				return .orderedAscending
			} else { // v0 == nil && v1 == nil
				return .orderedSame
			}
		}
	}
}

