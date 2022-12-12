/*
 * @file	CNMutableArrayValue.swift
 * @brief	Define CNMutableArrayValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNMutableDictionaryValue: CNMutableValue
{
	private var mDictionaryValue:	Dictionary<String, CNMutableValue>

	public init(sourceDirectory srcdir: URL, cacheDirectory cachedir: URL){
		mDictionaryValue = [:]
		super.init(type: .dictionary, sourceDirectory: srcdir, cacheDirectory: cachedir)
	}

	public var keys:   Array<String>         { get { return Array(mDictionaryValue.keys) }}
	public var values: Array<CNMutableValue> { get { return Array(mDictionaryValue.values) }}

	public func set(value val: CNMutableValue, forKey key: String){
		mDictionaryValue[key] = val
	}

	public func get(forKey key: String) -> CNMutableValue? {
		return mDictionaryValue[key]
	}

	public override func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Result<CNMutableValue?, NSError> {
		guard let first = path.first else {
			/* Return entire dicrectory */
			return .success(self)
		}
		let rest = Array(path.dropFirst(1))
		let result: Result<CNMutableValue?, NSError>
		switch first {
		case .member(let member):
			if let targ = mDictionaryValue[member] {
				result = targ._value(forPath: rest, in: root)
			} else {
				result = .success(nil)	// Not found
			}
		case .index(let idx):
			result = .failure(NSError.parseError(message: "Dictionary key is required but index is given: \(idx)"))
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
				result = .failure(NSError.parseError(message: "Invalid key or value: \(srckey):\(srcval.script)"))
			}
		}
		return result
	}

	public override func _set(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		guard let first = path.first else {
			return unmatchedPathError(path: path, place: #function)
		}
		let rest = Array(path.dropFirst(1))
		let result: NSError?
		switch first {
		case .member(let member):
			if rest.count == 0 {
				mDictionaryValue[member] = toMutableValue(from: val)
				root.isDirty = true
				result = nil
			} else {
				if let dst = mDictionaryValue[member] {
					result = dst._set(value: val, forPath: rest, in: root)
				} else {
					/* append new sub-tree */
					mDictionaryValue[member] = toMutableValue(from: val)
					root.isDirty = true
					result = nil
				}
			}
		case .index(let idx):
			result = NSError.parseError(message: "Dictionary key is required but index is given: \(idx)")
		case .keyAndValue(let srckey, let srcval):
			if let (curkey, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					/* Replace child itself */
					mDictionaryValue[curkey] = toMutableValue(from: val)
					root.isDirty = true
					result = nil
				} else {
					/* Trace child */
					result = curdict._set(value: val, forPath: rest, in: root)
				}
			} else {
				result = NSError.parseError(message: "Invalid key or value: \(srckey):\(srcval.script)")
			}
		}
		return result
	}

	public override func _append(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		guard let first = path.first else {
			return unmatchedPathError(path: path, place: #function)
		}
		let rest = Array(path.dropFirst(1))
		let result: NSError?
		switch first {
		case .member(let member):
			if let dst = mDictionaryValue[member] {
				result = dst._append(value: val, forPath: rest, in: root)
			} else {
				mDictionaryValue[member] = toMutableValue(from: val)
				root.isDirty = true
				result = nil
			}
		case .index(let idx):
			result = NSError.parseError(message: "Dictionary key is required but index is given: \(idx)")
		case .keyAndValue(let srckey, let srcval):
			if let (_, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					result = NSError.parseError(message: "Invalid key or value: \(srckey):\(srcval.script)")
				} else {
					/* Trace child */
					result = curdict._append(value: val, forPath: rest, in: root)
				}
			} else {
				result = NSError.parseError(message: "Invalid key or value: \(srckey):\(srcval.script)")
			}
		}
		return result
	}

	public override func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		guard let first = path.first else {
			return unmatchedPathError(path: path, place: #function)
		}
		let rest = Array(path.dropFirst(1))
		let result: NSError?
		switch first {
		case .member(let member):
			if rest.count == 0 {
				if let _ = mDictionaryValue[member] {
					mDictionaryValue.removeValue(forKey: member)
					root.isDirty = true
					result = nil
				} else {
					result = NSError.parseError(message: "Unexpected key: \(member)")
				}
			} else {
				if let dst = mDictionaryValue[member] {
					result = dst._delete(forPath: rest, in: root)
				} else {
					result = NSError.parseError(message: "Unexpected key: \(member)")
				}
			}
		case .index(let idx):
			result = NSError.parseError(message: "Dictionary key is required but index is given: \(idx)")
		case .keyAndValue(let srckey, let srcval):
			if let (curkey, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					/* Delete child itself */
					mDictionaryValue[curkey] = nil
					root.isDirty = true
					result = nil
				} else {
					/* Trace child */
					result = curdict._delete(forPath: rest, in: root)
				}
			} else {
				result = NSError.parseError(message: "Invalid key or value: \(srckey):\(srcval.script)")
			}
		}
		return result
	}

	private func searchChild(key srckey: String, value srcval: CNValue) -> (String, CNMutableDictionaryValue)? {
		for key in mDictionaryValue.keys {
			if let dict = mDictionaryValue[key] as? CNMutableDictionaryValue {
				if let curval = dict.get(forKey: srckey) {
					if CNIsSameValue(value0: curval.toValue(), value1: srcval){
						return (key, dict)
					}
				}
			}
		}
		return nil
	}

	public override func _search(name nm: String, value val: String, in root: CNMutableValue) -> Result<Array<CNValuePath.Element>?, NSError> {
		/* Search itself */
		if let elm = mDictionaryValue[nm] {
			if let estr = elm.toValue().toString() {
				if estr == val {
					return .success([.member(nm)])
				}
			}
		}
		/* Search children */
		for key in mDictionaryValue.keys {
			if let elm = mDictionaryValue[key] {
				switch elm._search(name: nm, value: val, in: root) {
				case .success(let elms):
					if var melms = elms {
						melms.insert(.member(key), at: 0)
						return .success(melms)
					}
				case .failure(let err):
					return .failure(err)
				}
			}
		}
		return .success(nil) // no result
	}

	public override func _makeLabelTable(property name: String, path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		var result: Dictionary<String, Array<CNValuePath.Element>> = [:]
		/* Update itsel */
		if let val = mDictionaryValue[name] {
			if let obj = val as? CNMutableScalarValue {
				switch obj.toValue() {
				case .stringValue(let label):
					result[label] = pth
				default:
					CNLog(logLevel: .error, message: "Invalid value for id", atFunction: #function, inFile: #file)
				}
			}
		}
		/* make table for children */
		for (key, val) in mDictionaryValue {
			var curpath: Array<CNValuePath.Element> = []
			curpath.append(contentsOf: pth)
			curpath.append(.member(key))
			let subres = val._makeLabelTable(property: name, path: curpath)
			for (skey, sval) in subres {
				result[skey] = sval
			}
		}
		return result
	}

	public override func clone() -> CNMutableValue {
		let result = CNMutableDictionaryValue(sourceDirectory: self.sourceDirectory, cacheDirectory: self.cacheDirectory)
		for (key, elm) in mDictionaryValue {
			result.set(value: elm.clone(), forKey: key)
		}
		return result
	}

	public override func toValue() -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for (key, elm) in mDictionaryValue {
			result[key] = elm.toValue()
		}
		return .dictionaryValue(result)
	}
}

