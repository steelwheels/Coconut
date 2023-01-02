/**
 * @file	CNValuePointer.swift
 * @brief	Define CNValuePointer class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNPointerValue
{
	public static let ClassName	= "pointer"
	public static let PathItem	= "path"

	private var mPath:	CNValuePath

	public var path: CNValuePath { get { return mPath }}

	public init(path p: CNValuePath) {
		mPath	= p
	}

	public var description: String { get {
		return self.toValue().description
	}}

	public static func fromValue(value val: CNValue) -> CNPointerValue? {
		if let dict = val.toDictionary() {
			return fromValue(value: dict)
		} else {
			return nil
		}
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNPointerValue? {
		if CNValue.hasClassName(inValue: val, className: CNPointerValue.ClassName) {
			if let pathval = val[CNPointerValue.PathItem] {
				if let pathstr = pathval.toString() {
					switch CNValuePath.pathExpression(string: pathstr) {
					case .success(let path):
						return CNPointerValue(path: path)
					case .failure(let err):
						CNLog(logLevel: .error, message: err.toString())
						return nil
					}
				}
			}
		}
		return nil
	}

	func toValue() -> Dictionary<String, CNValue> {
		let pathstr = CNValuePath.toExpression(identifier: mPath.identifier, elements: mPath.elements)
		let result: Dictionary<String, CNValue> = [
			"class"			: .stringValue(CNPointerValue.ClassName),
			CNPointerValue.PathItem	: .stringValue(pathstr)
		]
		return result
	}

	func compare(_ val: CNPointerValue) -> ComparisonResult {
		return self.mPath.compare(val.mPath)
	}
}

