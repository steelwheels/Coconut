/*
 * @file	CNMutablePointerValue.swift
 * @brief	Define CNMutablePointerValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNMutablePointerValue: CNMutableValue
{
	private var mPointerValue:	CNPointerValue
	private var mContext:		CNMutableValue?

	public init(pointer val: CNPointerValue, sourceDirectory srcdir: URL, cacheDirectory cachedir: URL){
		mPointerValue		= val
		mContext		= nil
		super.init(type: .pointer, sourceDirectory: srcdir, cacheDirectory: cachedir)
	}

	public var context: CNMutableValue? { get { return mContext         }}

	public override func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Result<CNMutableValue?, NSError> {
		let result: Result<CNMutableValue?, NSError>
		switch pointedValue(in: root) {
		case .success(let mval):
			result = mval._value(forPath: path, in: root)
		case .failure(let err):
			result = .failure(err)
		}
		return result
	}

	public override func _set(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		let result: NSError?
		if path.count == 0 {
			/* Overide this value */
			switch val {
			case .pointerValue(let pval):
				mPointerValue = pval
				root.isDirty  = true
				result = nil
			default:
				result = noPointedValueError(path: path, place: #function)
			}
		} else {
			switch pointedValue(in: root) {
			case .success(let mval):
				result = mval._set(value: val, forPath: path, in: root)
			case .failure(let err):
				result = err
			}
		}
		return result
	}

	public override func _append(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		let result: NSError?
		if path.count > 0 {
			switch pointedValue(in: root) {
			case .success(let mval):
				result = mval._append(value: val, forPath: path, in: root)
			case .failure(let err):
				result = err
			}
		} else {
			result = NSError.parseError(message: "Can not append value to pointer")
		}
		return result
	}

	public override func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		let result: NSError?
		if path.count > 0 {
			switch pointedValue(in: root) {
			case .success(let mval):
				result = mval._delete(forPath: path, in: root)
			case .failure(let err):
				result = err
			}
		} else {
			result = NSError.parseError(message: "Can not delete pointer value")
		}
		return result
	}

	public override func _search(name nm: String, value val: String, in root: CNMutableValue) -> Result<Array<CNValuePath.Element>?, NSError> {
		let result: Result<Array<CNValuePath.Element>?, NSError>
		switch pointedValue(in: root) {
		case .success(let mval):
			result = mval._search(name: nm, value: val, in: root)
		case .failure(let err):
			result = .failure(err)
		}
		return result
	}

	private func pointedValue(in root: CNMutableValue) -> Result<CNMutableValue, NSError> {
		let elms = root.labelTable().pointerToPath(pointer: mPointerValue, in: root)
		let result: Result<CNMutableValue, NSError>
		switch root._value(forPath: elms, in: root) {
		case .success(let mvalp):
			if let mval = mvalp {
				result = .success(mval)
			} else {
				result = .failure(unmatchedPathError(path: elms, place: #function))
			}
		case .failure(let err):
			result = .failure(err)
		}
		return result
	}

	public override func _makeLabelTable(property name: String, path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		return [:]
	}

	public override func clone() -> CNMutableValue {
		return CNMutablePointerValue(pointer: mPointerValue, sourceDirectory: self.sourceDirectory, cacheDirectory: self.cacheDirectory)
	}

	public override func toValue() -> CNValue {
		return .pointerValue(mPointerValue)
	}
}

