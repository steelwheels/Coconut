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

	open func value(forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> CNMutableValue? {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return nil
	}

	open func set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> Bool {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return false
	}

	open func delete(forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> Bool {
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

	open func toText() -> CNText {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return CNTextLine(string: "?")
	}
}

public class CNMutableScalarValue: CNMutableValue
{
	private var mScalarValue: CNValue

	public init(scalarValue val: CNValue){
		mScalarValue = val
		super.init(type: .scaler)
	}

	public override func value(forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> CNMutableValue? {
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

	public override func set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> Bool {
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

	public override func delete(forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> Bool {
		CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		return false
	}

	public override func clone() -> CNMutableValue {
		return CNMutableScalarValue(scalarValue: mScalarValue)
	}

	public override func toValue() -> CNValue {
		return mScalarValue
	}

	public override func toText() -> CNText {
		return mScalarValue.toText()
	}
}

public class CNMutableArrayValue: CNMutableValue
{
	private var mArrayValue:	Array<CNMutableValue>

	public init(){
		mArrayValue = []
		super.init(type: .array)
	}

	public func append(value val: CNMutableValue){
		mArrayValue.append(val)
	}

	public override func value(forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> CNMutableValue? {
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
					result = mArrayValue[idx].value(forPath: rest, fromPackageDirectory: package)
				} else {
					CNLog(logLevel: .error, message: "Invalid array index: \(idx)", atFunction: #function, inFile: #file)
					result = nil
				}
			}
		}
		return result
	}

	public override func set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> Bool {
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
					result = mArrayValue[idx].set(value: val, forPath: rest, fromPackageDirectory: package)
				} else {
					CNLog(logLevel: .error, message: "Invalid array index: \(idx)", atFunction: #function, inFile: #file)
					result = false
				}
			}
		}
		return result
	}

	public override func delete(forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> Bool {
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
					result = mArrayValue[idx].delete(forPath: rest, fromPackageDirectory: package)
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

	public override func toText() -> CNText {
		let sect = CNTextSection()
		sect.header = "[" ; sect.footer = "]" ; sect.separator = ","
		for elm in mArrayValue {
			sect.add(text: elm.toText())
		}
		return sect
	}
}

public class CNMutableDictionaryValue: CNMutableValue
{
	private var mDictionaryValue:	Dictionary<String, CNMutableValue>

	public init(){
		mDictionaryValue = [:]
		super.init(type: .dictionary)
	}

	public func set(value val: CNMutableValue, forKey key: String){
		mDictionaryValue[key] = val
	}

	public override func value(forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> CNMutableValue? {
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
					result = targ.value(forPath: rest, fromPackageDirectory: package)
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

	public override func set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> Bool {
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
					result = dst.set(value: val, forPath: rest, fromPackageDirectory: package)
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

	public override func delete(forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> Bool {
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
					result = dst.delete(forPath: rest, fromPackageDirectory: package)
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

	public override func toText() -> CNText {
		let sect = CNTextSection()
		sect.header = "{" ; sect.footer = "}" ; sect.separator = ","
		for (key, elm) in mDictionaryValue {
			let elmtxt = elm.toText()
			elmtxt.prepend(string: "\(key): ")
			sect.add(text: elmtxt)
		}
		return sect
	}
}

public class CNMutableValueReference: CNMutableValue
{
	private var mReferenceValue: 	CNValueReference
	private var mContext:		CNMutableValue?

	public init(value val: CNValueReference){
		mReferenceValue 	= val
		mContext		= nil
		super.init(type: .reference)
	}

	public override func value(forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> CNMutableValue? {
		let result: CNMutableValue?
		if let val = load(fromPackageDirectory: package) {
			result = val.value(forPath: path, fromPackageDirectory: package)
		} else {
			result = nil
		}
		return result
	}

	public override func set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> Bool {
		let result: Bool
		if let dst = load(fromPackageDirectory: package) {
			result = dst.set(value: val, forPath: path, fromPackageDirectory: package)
		} else {
			result = false
		}
		return result
	}

	public override func delete(forPath path: Array<CNValuePath.Element>, fromPackageDirectory package: URL) -> Bool {
		let result: Bool
		if let dst = load(fromPackageDirectory: package) {
			result = dst.delete(forPath: path, fromPackageDirectory: package)
		} else {
			result = false
		}
		return result
	}
	
	private func load(fromPackageDirectory package: URL) -> CNMutableValue? {
		let result:  CNMutableValue?
		if let ctxt = mContext {
			result = ctxt
		} else {
			if let src = mReferenceValue.load(fromPackageDirectory: package) {
				let ctxt = CNValueToMutableValue(from: src)
				mContext = ctxt
				result = ctxt
			} else {
				CNLog(logLevel: .error, message: "Failed to load: \(package.path)", atFunction: #function, inFile: #file)
				result = nil
			}
		}
		return result
	}

	public override func clone() -> CNMutableValue {
		return CNMutableValueReference(value: mReferenceValue)
	}

	public override func toValue() -> CNValue {
		return .reference(mReferenceValue)
	}

	public override func toText() -> CNText {
		return CNTextLine(string: mReferenceValue.relativePath)
	}
}

public func CNValueToMutableValue(from val: CNValue) -> CNMutableValue {
	let result: CNMutableValue
	switch val {
	case .arrayValue(let arr):
		let newarr = CNMutableArrayValue()
		for elm in arr {
			newarr.append(value: CNValueToMutableValue(from: elm))
		}
		result = newarr
	case .dictionaryValue(let dict):
		let newdict = CNMutableDictionaryValue()
		for (key, elm) in dict {
			let newelm = CNValueToMutableValue(from: elm)
			newdict.set(value: newelm, forKey: key)
		}
		result = newdict
	case .reference(let ref):
		let newref = CNMutableValueReference(value: ref)
		result = newref
	default:
		let newscalar = CNMutableScalarValue(scalarValue: val)
		result = newscalar
	}
	return result
}

