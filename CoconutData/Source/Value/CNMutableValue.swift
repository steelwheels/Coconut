/*
 * @file	CNMutableValue.swift
 * @brief	Define CNMutableValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNMutableValue
{
	public enum ValueType {
		case scaler
		case array
		case dictionary
		case reference
	}

	private var mType: ValueType

	public var type: ValueType { get { return mType }}

	public init(type t: ValueType){
		mType = t
	}

	open func value(forPath path: Array<CNValuePath.Element>) -> CNMutableValue? {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return nil
	}

	open func set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>) -> Bool {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return false
	}

	open func append(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>) -> Bool {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return false
	}

	open func delete(forPath path: Array<CNValuePath.Element>) -> Bool {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return false
	}

	open func clone() -> CNMutableValue {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return CNMutableValue(type: mType)
	}

	open func toValue() -> CNValue {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return .nullValue
	}
}

public class CNMutableScalarValue: CNMutableValue
{
	private var mScalarValue: CNValue

	public init(scalarValue val: CNValue){
		mScalarValue = val
		super.init(type: .scaler)
	}

	public override func value(forPath path: Array<CNValuePath.Element>) -> CNMutableValue? {
		let result: CNMutableValue?
		if path.count == 0 {
			let newval = CNMutableScalarValue(scalarValue: mScalarValue)
			result = newval
		} else {
			CNLog(logLevel: .error, message: "Non-empty path for scalar value", atFunction: #function, inFile: #file)
			result = nil
		}
		return result
	}

	public override func set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>) -> Bool {
		let result: Bool
		if path.count == 0 {
			mScalarValue = val.toValue()
			result = true
		} else {
			CNLog(logLevel: .error, message: "Non-empty path for scalar value", atFunction: #function, inFile: #file)
			result = false
		}
		return result
	}

	public override func append(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>) -> Bool {
		CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		return false
	}

	public override func delete(forPath path: Array<CNValuePath.Element>) -> Bool {
		CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		return false
	}

	public override func clone() -> CNMutableValue {
		return CNMutableScalarValue(scalarValue: mScalarValue)
	}

	public override func toValue() -> CNValue {
		return mScalarValue
	}
}

public class CNMutableArrayValue: CNMutableValue
{
	private var mArrayValue:	Array<CNMutableValue>

	public init(){
		mArrayValue = []
		super.init(type: .array)
	}

	public var values: Array<CNMutableValue> { get { return mArrayValue }}

	public func append(value val: CNMutableValue){
		mArrayValue.append(val)
	}

	public override func value(forPath path: Array<CNValuePath.Element>) -> CNMutableValue? {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for array value", atFunction: #function, inFile: #file)
			return nil
		}
		let result: CNMutableValue?
		switch first {
		case .member(let member):
			CNLog(logLevel: .error, message: "Array index is required but key is given: \(member)", atFunction: #function, inFile: #file)
			result = nil
		case .index(let idx):
			let rest = Array(path.dropFirst())
			if rest.count == 0 {
				if 0<=idx && idx<mArrayValue.count {
					result = mArrayValue[idx]
				} else {
					CNLog(logLevel: .error, message: "Invalid array index: \(idx)", atFunction: #function, inFile: #file)
					result = nil
				}
			} else {
				if 0<=idx && idx<mArrayValue.count {
					result = mArrayValue[idx].value(forPath: rest)
				} else {
					CNLog(logLevel: .error, message: "Invalid array index: \(idx)", atFunction: #function, inFile: #file)
					result = nil
				}
			}
		}
		return result
	}

	public override func set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>) -> Bool {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for array value", atFunction: #function, inFile: #file)
			return false
		}
		let result: Bool
		switch first {
		case .member(let member):
			CNLog(logLevel: .error, message: "Array index is required but key is given: \(member)", atFunction: #function, inFile: #file)
			result = false
		case .index(let idx):
			let rest = Array(path.dropFirst())
			if rest.count == 0 {
				if 0<=idx && idx<mArrayValue.count {
					mArrayValue[idx] = val.clone()
					result = true
				} else if idx == mArrayValue.count {
					mArrayValue.append(val.clone())
					result = true
				} else {
					CNLog(logLevel: .error, message: "Invalid array index: \(idx)", atFunction: #function, inFile: #file)
					result = false
				}
			} else {
				if 0<=idx && idx<mArrayValue.count {
					result = mArrayValue[idx].set(value: val, forPath: rest)
				} else {
					CNLog(logLevel: .error, message: "Invalid array index: \(idx)", atFunction: #function, inFile: #file)
					result = false
				}
			}
		}
		return result
	}

	public override func append(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>) -> Bool {
		let result: Bool
		if let first = path.first {
			switch first {
			case .member(let member):
				CNLog(logLevel: .error, message: "Array index is required but key is given: \(member)", atFunction: #function, inFile: #file)
				result = false
			case .index(let idx):
				if 0<=idx && idx<mArrayValue.count {
					let dst  = mArrayValue[idx]
					let rest = Array(path.dropFirst())
					result = dst.append(value: val, forPath: rest)
				} else {
					CNLog(logLevel: .error, message: "Array index overflow: \(idx)", atFunction: #function, inFile: #file)
					result = false
				}
			}
		} else {
			mArrayValue.append(val)
			result = true
		}
		return result
	}

	public override func delete(forPath path: Array<CNValuePath.Element>) -> Bool {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for array value", atFunction: #function, inFile: #file)
			return false
		}
		let result: Bool
		switch first {
		case .member(let member):
			CNLog(logLevel: .error, message: "Array index is required but key is given: \(member)", atFunction: #function, inFile: #file)
			result = false
		case .index(let idx):
			let rest = Array(path.dropFirst())
			if rest.count == 0 {
				if 0<=idx && idx<mArrayValue.count {
					mArrayValue.remove(at: idx)
					result = true
				} else {
					result = false
				}
			} else {
				if 0<=idx && idx<mArrayValue.count {
					result = mArrayValue[idx].delete(forPath: rest)
				} else {
					result = false
				}
			}
		}
		return result
	}

	public override func clone() -> CNMutableValue {
		let result = CNMutableArrayValue()
		for elm in mArrayValue {
			result.append(value: elm.clone())
		}
		return result
	}

	public override func toValue() -> CNValue {
		var result: Array<CNValue> = []
		for elm in mArrayValue {
			result.append(elm.toValue())
		}
		return .arrayValue(result)
	}
}

public class CNMutableDictionaryValue: CNMutableValue
{
	private var mDictionaryValue:	Dictionary<String, CNMutableValue>

	public init(){
		mDictionaryValue = [:]
		super.init(type: .dictionary)
	}

	public var keys:   Array<String>         { get { return Array(mDictionaryValue.keys) }}
	public var values: Array<CNMutableValue> { get { return Array(mDictionaryValue.values) }}

	public func set(value val: CNMutableValue, forKey key: String){
		mDictionaryValue[key] = val
	}

	public override func value(forPath path: Array<CNValuePath.Element>) -> CNMutableValue? {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for dictionary value", atFunction: #function, inFile: #file)
			return nil
		}
		let result: CNMutableValue?
		switch first {
		case .member(let member):
			let rest = Array(path.dropFirst(1))
			if rest.count == 0 {
				if let targ = mDictionaryValue[member] {
					result = targ
				} else {
					result = nil
				}
			} else {
				if let targ = mDictionaryValue[member] {
					result = targ.value(forPath: rest)
				} else {
					result = nil
				}
			}
		case .index(let idx):
			CNLog(logLevel: .error, message: "Dictionary key is required but index is given: \(idx)", atFunction: #function, inFile: #file)
			result = nil
		}
		return result
	}

	public override func set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>) -> Bool {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for dictionary value", atFunction: #function, inFile: #file)
			return false
		}
		let result: Bool
		switch first {
		case .member(let member):
			let rest = Array(path.dropFirst(1))
			if rest.count == 0 {
				mDictionaryValue[member] = val.clone()
				result = true
			} else {
				if let dst = mDictionaryValue[member] {
					result = dst.set(value: val, forPath: rest)
				} else {
					/* append new sub-tree */
					let newval = CNMakePathValue(value: val, forPath: rest)
					mDictionaryValue[member] = newval
					result = true
				}
			}
		case .index(let idx):
			CNLog(logLevel: .error, message: "Dictionary key is required but index is given: \(idx)", atFunction: #function, inFile: #file)
			result = false
		}
		return result
	}

	public override func append(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>) -> Bool {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for dictionary value", atFunction: #function, inFile: #file)
			return false
		}
		let result: Bool
		switch first {
		case .member(let member):
			let rest = Array(path.dropFirst(1))
			if let dst = mDictionaryValue[member] {
				result = dst.append(value: val, forPath: rest)
			} else {
				/* append new sub-tree */
				let newval = CNMakePathValue(value: val, forPath: rest)
				mDictionaryValue[member] = newval
				result = true
			}
		case .index(let idx):
			CNLog(logLevel: .error, message: "Dictionary key is required but index is given: \(idx)", atFunction: #function, inFile: #file)
			result = false
		}
		return result
	}

	public override func delete(forPath path: Array<CNValuePath.Element>) -> Bool {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for dictionary value", atFunction: #function, inFile: #file)
			return false
		}
		let result: Bool
		switch first {
		case .member(let member):
			let rest = Array(path.dropFirst(1))
			if rest.count == 0 {
				if let _ = mDictionaryValue[member] {
					mDictionaryValue.removeValue(forKey: member)
					result = true
				} else {
					CNLog(logLevel: .error, message: "Unexpected key: \(member)", atFunction: #function, inFile: #file)
					result = false
				}
			} else {
				if let dst = mDictionaryValue[member] {
					result = dst.delete(forPath: rest)
				} else {
					CNLog(logLevel: .error, message: "Unexpected key: \(member)", atFunction: #function, inFile: #file)
					result = false
				}
			}
		case .index(let idx):
			CNLog(logLevel: .error, message: "Dictionary key is required but index is given: \(idx)", atFunction: #function, inFile: #file)
			result = false
		}
		return result
	}

	public override func clone() -> CNMutableValue {
		let result = CNMutableDictionaryValue()
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

public class CNMutableValueReference: CNMutableValue
{
	private var mReferenceValue: 	CNValueReference
	private var mSourceDirectory:	URL
	private var mCacheDirectory:	URL
	private var mContext:		CNMutableValue?

	public init(value val: CNValueReference, sourceDirectory srcdir: URL, cacheDirectory cachedir: URL){
		mReferenceValue 	= val
		mSourceDirectory	= srcdir
		mCacheDirectory		= cachedir
		mContext		= nil
		super.init(type: .reference)
	}

	public var sourceDirectory: URL     { get { return mSourceDirectory }}
	public var cacheDirectory:  URL     { get { return mCacheDirectory  }}
	public var context: CNMutableValue? { get { return mContext         }}

	public var sourceFile: URL { get {
		return mSourceDirectory.appendingPathComponent(mReferenceValue.relativePath)
	}}
	public var cacheFile: URL { get {
		return mCacheDirectory.appendingPathComponent(mReferenceValue.relativePath)
	}}

	public override func value(forPath path: Array<CNValuePath.Element>) -> CNMutableValue? {
		let result: CNMutableValue?
		if let val = load() {
			result = val.value(forPath: path)
		} else {
			result = nil
		}
		return result
	}

	public override func set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>) -> Bool {
		let result: Bool
		if let dst = load() {
			result = dst.set(value: val, forPath: path)
		} else {
			result = false
		}
		return result
	}

	public override func append(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>) -> Bool {
		let result: Bool
		if let dst = load() {
			result = dst.append(value: val, forPath: path)
		} else {
			result = false
		}
		return result
	}

	public override func delete(forPath path: Array<CNValuePath.Element>) -> Bool {
		let result: Bool
		if let dst = load() {
			result = dst.delete(forPath: path)
		} else {
			result = false
		}
		return result
	}

	private func load() -> CNMutableValue? {
		let result:  CNMutableValue?
		if let ctxt = mContext {
			result = ctxt
		} else {
			if let src = mReferenceValue.load(fromSourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory) {
				let ctxt = CNValueToMutableValue(from: src, sourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory)
				mContext = ctxt
				result = ctxt
			} else {
				CNLog(logLevel: .error, message: "Failed to load: \(mCacheDirectory.path)", atFunction: #function, inFile: #file)
				result = nil
			}
		}
		return result
	}

	public override func clone() -> CNMutableValue {
		return CNMutableValueReference(value: mReferenceValue, sourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory)
	}

	public override func toValue() -> CNValue {
		return .reference(mReferenceValue)
	}
}

private func CNMakePathValue(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>) -> CNMutableValue {
	if path.count == 0 {
		return val
	} else {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for dictionary value", atFunction: #function, inFile: #file)
			return val
		}
		let result: CNMutableValue
		switch first {
		case .member(let member):
			let rest    = Array(path.dropFirst(1))
			let subval  = CNMakePathValue(value: val, forPath: rest)
			let newdict = CNMutableDictionaryValue()
			newdict.set(value: subval, forKey: member)
			result = newdict
		case .index(let idx):
			let rest    = Array(path.dropFirst(1))
			let subval  = CNMakePathValue(value: val, forPath: rest)
			let newarr  = CNMutableArrayValue()
			for _ in 0..<idx {
				newarr.append(value: CNMutableScalarValue(scalarValue: .nullValue))
			}
			newarr.append(value: subval)
			result = newarr
		}
		return result
	}
}

public func CNValueToMutableValue(from val: CNValue, sourceDirectory srcdir: URL, cacheDirectory cachedir: URL) -> CNMutableValue {
	let result: CNMutableValue
	switch val {
	case .arrayValue(let arr):
		let newarr = CNMutableArrayValue()
		for elm in arr {
			newarr.append(value: CNValueToMutableValue(from: elm, sourceDirectory: srcdir, cacheDirectory: cachedir))
		}
		result = newarr
	case .dictionaryValue(let dict):
		let newdict = CNMutableDictionaryValue()
		for (key, elm) in dict {
			let newelm = CNValueToMutableValue(from: elm, sourceDirectory: srcdir, cacheDirectory: cachedir)
			newdict.set(value: newelm, forKey: key)
		}
		result = newdict
	case .reference(let ref):
		let newref = CNMutableValueReference(value: ref, sourceDirectory: srcdir, cacheDirectory: cachedir)
		result = newref
	default:
		let newscalar = CNMutableScalarValue(scalarValue: val)
		result = newscalar
	}
	return result
}

public func CNAllReferencesInValue(value val: CNMutableValue) -> Array<CNMutableValueReference> {
	var result: Array<CNMutableValueReference> = []
	switch val.type {
	case .scaler:
		break
	case .dictionary:
		if let dict = val as? CNMutableDictionaryValue {
			for child in dict.values {
				let cres = CNAllReferencesInValue(value: child)
				result.append(contentsOf: cres)
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen (1)", atFunction: #function, inFile: #file)
		}
	case .array:
		if let arr = val as? CNMutableArrayValue {
			for child in arr.values {
				let cres = CNAllReferencesInValue(value: child)
				result.append(contentsOf: cres)
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen (2)", atFunction: #function, inFile: #file)
		}
	case .reference:
		if let ref = val as? CNMutableValueReference {
			result.append(ref)
		} else {
			CNLog(logLevel: .error, message: "Can not happen (3)", atFunction: #function, inFile: #file)
		}
	}
	return result
}
