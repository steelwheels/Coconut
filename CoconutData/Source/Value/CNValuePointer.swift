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

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNPointerValue? {
		if CNValue.hasClassName(inValue: val, className: CNPointerValue.ClassName) {
			if let pathval = val[CNPointerValue.PathItem] {
				if let pathstr = pathval.toString() {
					if let pathelm = CNValuePath.pathExpression(string: pathstr) {
						let path = CNValuePath(elements: pathelm)
						return CNPointerValue(path: path)
					}
				}
			}
		}
		return nil
	}

	func toValue() -> Dictionary<String, CNValue> {
		let pathstr = CNValuePath.toExpression(elements: mPath.elements)
		let result: Dictionary<String, CNValue> = [
			"class"			: .stringValue(CNPointerValue.ClassName),
			CNValueSegment.FileItem	: .stringValue(pathstr)
		]
		return result
	}

	func compare(_ val: CNPointerValue) -> ComparisonResult {
		return self.mPath.compare(val.mPath)
	}
}

