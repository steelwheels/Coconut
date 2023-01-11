/*
 * @file	CNMutableScalarValue.swift
 * @brief	Define CNMutableScalarValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNMutableScalarValue: CNMutableValue
{
	private var mScalarValue: CNValue

	public init(scalarValue val: CNValue, sourceDirectory srcdir: URL, cacheDirectory cachedir: URL){
		mScalarValue = val
		super.init(type: .scaler(val.valueType), sourceDirectory: srcdir, cacheDirectory: cachedir)
	}

	public override func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Result<CNMutableValue?, NSError> {
		let result: Result<CNMutableValue?, NSError>
		if path.count == 0 {
			result = .success(self)
		} else {
			result = .failure(unmatchedPathError(path: path, place: #function))
		}
		return result
	}

	public override func _set(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		let result: NSError?
		if path.count == 0 {
			mScalarValue = val
			root.isDirty = true
			result       = nil
		} else {
			result       = unmatchedPathError(path: path, place: #function)
		}
		return result
	}

	public override func _append(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		return canNotHappenError(path: path, place: #function)
	}

	public override func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		return canNotHappenError(path: path, place: #function)
	}

	public override func _search(name nm: String, value val: String, in root: CNMutableValue) -> Result<Array<CNValuePath.Element>?, NSError> {
		return .success(nil)
	}

	public override func _makeLabelTable(property name: String, path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		/* Not mached */
		return [:]
	}

	public override func clone() -> CNMutableValue {
		return CNMutableScalarValue(scalarValue: mScalarValue, sourceDirectory: self.sourceDirectory, cacheDirectory: self.cacheDirectory)
	}

	public override func toValue() -> CNValue {
		return mScalarValue
	}
}

