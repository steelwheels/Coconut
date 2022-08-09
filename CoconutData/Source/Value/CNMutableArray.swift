/*
 * @file	CNMutableArrayValue.swift
 * @brief	Define CNMutableArrayValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNMutableArrayValue: CNMutableValue
{
	private var mValues:	Array<CNMutableValue>

	public init(sourceDirectory srcdir: URL, cacheDirectory cachedir: URL){
		mValues = []
		super.init(type: .array, sourceDirectory: srcdir, cacheDirectory: cachedir)
	}

	public var values: Array<CNMutableValue> { get { return mValues }}

	public func append(value val: CNMutableValue){
		mValues.append(val)
	}

	public func insert(value val: CNMutableValue, at pos: Int) {
		mValues.insert(val, at: pos)
	}

	public override func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Result<CNMutableValue?, NSError> {
		guard let first = path.first else {
			/* Return entire array */
			return  .success(self)
		}
		let rest = Array(path.dropFirst())
		let result: Result<CNMutableValue?, NSError>
		switch first {
		case .member(let member):
			result = .failure(NSError.parseError(message: "Array index is required but key is given: \(member)"))
		case .index(let idx):
			if 0<=idx && idx<mValues.count {
				result = mValues[idx]._value(forPath: rest, in: root)
			} else {
				result = .failure(NSError.parseError(message: "Invalid array index: \(idx)"))
			}
		case .keyAndValue(let srckey, let srcval):
			if let (_, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					/* Return child itself */
					result = .success(curdict)
				} else {
					/* Trace child */
					result = curdict._value(forPath: rest, in: root)
				}
			} else {
				result = .failure(NSError.parseError(message: "Invalid key or value: \(srckey):\(srcval.description)"))
			}
		}
		return result
	}

	public override func _set(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for array value", atFunction: #function, inFile: #file)
			return unmatchedPathError(path: path, place: #function)
		}
		let rest = Array(path.dropFirst())
		let result: NSError?
		switch first {
		case .member(let member):
			result = NSError.parseError(message: "Array index is required but key is given: \(member)")
		case .index(let idx):
			if rest.count == 0 {
				if 0<=idx && idx<mValues.count {
					mValues[idx] = toMutableValue(from: val)
					root.isDirty = true
					result = nil
				} else if idx == mValues.count {
					mValues.append(toMutableValue(from: val))
					root.isDirty = true
					result = nil
				} else {
					result = NSError.parseError(message: "Invalid array index: \(idx)")
				}
			} else {
				if 0<=idx && idx<mValues.count {
					result = mValues[idx]._set(value: val, forPath: rest, in: root)
				} else {
					result = NSError.parseError(message: "Invalid array index: \(idx)")
				}
			}
		case .keyAndValue(let srckey, let srcval):
			if let (curidx, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					/* Replace child itself */
					mValues[curidx] = toMutableValue(from: val)
					root.isDirty = true
					result = nil
				} else {
					/* Trace child */
					result = curdict._set(value: val, forPath: rest, in: root)
				}
			} else {
				result = NSError.parseError(message: "Invalid key or value: \(srckey):\(srcval.description)")
			}
		}
		return result
	}

	public override func _append(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		let result: NSError?
		if let first = path.first {
			let rest = Array(path.dropFirst())
			switch first {
			case .member(let member):
				result = NSError.parseError(message: "Array index is required but key is given: \(member)")
			case .index(let idx):
				if 0<=idx && idx<mValues.count {
					result = mValues[idx]._append(value: val, forPath: rest, in: root)
				} else {
					result = NSError.parseError(message: "Array index overflow: \(idx)")
				}
			case .keyAndValue(let srckey, let srcval):
				if let (_, curdict) = searchChild(key: srckey, value: srcval) {
					if rest.count == 0 {
						result = NSError.parseError(message: "Invalid key or value: \(srckey):\(srcval.description)")
					} else {
						/* Trace child */
						result = curdict._append(value: val, forPath: rest, in: root)
					}
				} else {
					result = NSError.parseError(message: "Invalid key or value: \(srckey):\(srcval.description)")
				}
			}
		} else {
			mValues.append(toMutableValue(from: val))
			root.isDirty = true
			result = nil
		}
		return result
	}

	public override func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		guard let first = path.first else {
			return unmatchedPathError(path: path, place: #function)
		}
		let rest = Array(path.dropFirst())
		let result: NSError?
		switch first {
		case .member(let member):
			result = NSError.parseError(message: "Array index is required but key is given: \(member)")
		case .index(let idx):
			if rest.count == 0 {
				if 0<=idx && idx<mValues.count {
					mValues.remove(at: idx)
					root.isDirty = true
					result = nil
				} else {
					result = NSError.parseError(message: "Invalid array index: value:\(idx) >= count:\(mValues.count)")
				}
			} else {
				if 0<=idx && idx<mValues.count {
					result = mValues[idx]._delete(forPath: rest, in: root)
				} else {
					result = NSError.parseError(message: "Invalid array index: value:\(idx) >= count:\(mValues.count)")
				}
			}
		case .keyAndValue(let srckey, let srcval):
			if let (curidx, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					/* Delete child itself */
					mValues.remove(at: curidx)
					root.isDirty = true
					result = nil
				} else {
					/* Trace child */
					result = curdict._delete(forPath: rest, in: root)
				}
			} else {
				result = NSError.parseError(message: "Invalid key or value: \(srckey):\(srcval.description)")
			}
		}
		return result
	}

	private func searchChild(key srckey: String, value srcval: CNValue) -> (Int, CNMutableDictionaryValue)? {
		for i in 0..<mValues.count {
			if let dict = mValues[i] as? CNMutableDictionaryValue {
				if let curval = dict.get(forKey: srckey) {
					if CNIsSameValue(nativeValue0: curval.toValue(), nativeValue1: srcval){
						return (i, dict)
					}
				}
			}
		}
		return nil
	}

	public override func _search(name nm: String, value val: String, in root: CNMutableValue) -> Result<Array<CNValuePath.Element>?, NSError> {
		for i in 0..<mValues.count {
			let elm = mValues[i]
			switch elm._search(name: nm, value: val, in: root) {
			case .success(let path):
				if var mpath = path {
					mpath.insert(.index(i), at: 0)
					return .success(mpath)
				}
			case .failure(let err):
				return .failure(err)
			}
		}
		return .success(nil) // not found
	}

	public override func _makeLabelTable(property name: String, path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		var result: Dictionary<String, Array<CNValuePath.Element>> = [:]
		for i in 0..<mValues.count {
			var curpath: Array<CNValuePath.Element> = []
			curpath.append(contentsOf: pth)
			curpath.append(.index(i))
			let subres = mValues[i]._makeLabelTable(property: name, path: curpath)
			for (skey, sval) in subres {
				result[skey] = sval
			}
		}
		return result
	}

	public override func clone() -> CNMutableValue {
		let result = CNMutableArrayValue(sourceDirectory: self.sourceDirectory, cacheDirectory: self.cacheDirectory)
		for elm in mValues {
			result.append(value: elm.clone())
		}
		return result
	}

	public override func toValue() -> CNValue {
		var result: Array<CNValue> = []
		for elm in mValues {
			result.append(elm.toValue())
		}
		return .arrayValue(result)
	}
}


