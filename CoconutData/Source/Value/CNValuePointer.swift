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

	public static func fromValue(value val: Dictionary<String, CNValue>) -> Result<CNPointerValue, NSError> {
		if CNValue.hasClassName(inValue: val, className: CNPointerValue.ClassName) {
			if let pathval = val[CNPointerValue.PathItem] {
				if let pathstr = pathval.toString() {
					switch CNValuePath.pathExpression(string: pathstr) {
					case .success(let path):
						return .success(CNPointerValue(path: path))
					case .failure(let err):
						return .failure(err)
					}
				}
			}
		}
		return .failure(NSError.parseError(message: "Incorrect format for \(CNPointerValue.ClassName) class"))
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

