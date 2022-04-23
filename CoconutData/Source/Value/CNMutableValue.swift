/*
 * @file	CNMutableValue.swift
 * @brief	Define CNMutableValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNMutableValue
{
	public typealias LabelTable = Dictionary<String, Array<CNValuePath.Element>>

	public enum ValueType {
		case scaler
		case array
		case dictionary
		case segment
		case pointer
	}

	private var 	mType:    	ValueType

	public var	type:    	ValueType { get { return mType    }}
	public var 	isDirty:	Bool

	private var	mLabelTable:	LabelTable?

	public init(type t: ValueType){
		mType		= t
		isDirty		= false
		mLabelTable	= nil
	}

	public func value(forPath path: Array<CNValuePath.Element>) -> CNMutableValue? {
		return self._value(forPath: path, in: self)
	}

	public func set(value val: CNMutableValue, forPath path:  Array<CNValuePath.Element>) -> Bool {
		return self._set(value: val, forPath: path, in: self)
	}

	public func append(value val: CNMutableValue, forPath path:  Array<CNValuePath.Element>) -> Bool {
		return self._append(value: val, forPath: path, in: self)
	}

	public func delete(forPath path: Array<CNValuePath.Element>) -> Bool {
		return self._delete(forPath: path, in: self)
	}

	public func search(name nm: String, value val: String) -> Array<CNValuePath.Element>? {
		return self._search(name: nm, value: val, in: self)
	}

	public static func labelTable(in root: CNMutableValue) -> LabelTable {
		if let table = root.mLabelTable {
			return table
		} else {
			let newtable = root._makeLabelTable(path: [])
			root.mLabelTable  = newtable
			return newtable
		}
	}

	public func clearLabelTable(){
		mLabelTable = nil
	}

	open func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> CNMutableValue? {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return nil
	}

	open func _set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return false
	}

	open func _append(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return false
	}

	open func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return false
	}

	open func _search(name nm: String, value val: String, in root: CNMutableValue) -> Array<CNValuePath.Element>? {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return nil
	}

	open func _makeLabelTable(path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return [:]
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

	public override func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> CNMutableValue? {
		let result: CNMutableValue?
		if path.count == 0 {
			result = self.clone()
		} else {
			let pathdesc = CNValuePath.toExpression(identifier: nil, elements: path)
			CNLog(logLevel: .error, message: "Non-empty path for scalar value: \(pathdesc)", atFunction: #function, inFile: #file)
			result = nil
		}
		return result
	}

	public override func _set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		let result: Bool
		if path.count == 0 {
			mScalarValue = val.toValue()
			root.isDirty = true
			result       = true
		} else {
			let pathdesc = CNValuePath.toExpression(identifier: nil, elements: path)
			CNLog(logLevel: .error, message: "Non-empty path for scalar value: \(pathdesc)", atFunction: #function, inFile: #file)
			result = false
		}
		return result
	}

	public override func _append(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		return false
	}

	public override func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		return false
	}

	public override func _search(name nm: String, value val: String, in root: CNMutableValue) -> Array<CNValuePath.Element>? {
		return nil // not found
	}

	public override func _makeLabelTable(path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		/* Not mached */
		return [:]
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

	public override func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> CNMutableValue? {
		guard let first = path.first else {
			/* Return entire array */
			return self.clone()
		}
		let rest = Array(path.dropFirst())
		let result: CNMutableValue?
		switch first {
		case .member(let member):
			CNLog(logLevel: .error, message: "Array index is required but key is given: \(member)", atFunction: #function, inFile: #file)
			result = nil
		case .index(let idx):

			if 0<=idx && idx<mArrayValue.count {
				result = mArrayValue[idx]._value(forPath: rest, in: root)
			} else {
				CNLog(logLevel: .error, message: "Invalid array index: \(idx)", atFunction: #function, inFile: #file)
				result = nil
			}
		case .keyAndValue(let srckey, let srcval):
			if let (_, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					/* Return child itself */
					result = curdict
				} else {
					/* Trace child */
					result = curdict._value(forPath: rest, in: root)
				}
			} else {
				let valtxt = srcval.toText().toStrings().joined(separator: "\n")
				CNLog(logLevel: .error, message: "Invalid key or value: \(srckey):\(valtxt)", atFunction: #function, inFile: #file)
				result = nil
			}
		}
		return result
	}

	public override func _set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for array value", atFunction: #function, inFile: #file)
			return false
		}
		let rest = Array(path.dropFirst())
		let result: Bool
		switch first {
		case .member(let member):
			CNLog(logLevel: .error, message: "Array index is required but key is given: \(member)", atFunction: #function, inFile: #file)
			result = false
		case .index(let idx):
			if rest.count == 0 {
				if 0<=idx && idx<mArrayValue.count {
					let dval = val.clone()
					mArrayValue[idx] = dval
					root.isDirty = true
					result = true
				} else if idx == mArrayValue.count {
					let dval = val.clone()
					mArrayValue.append(dval)
					root.isDirty = true
					result = true
				} else {
					CNLog(logLevel: .error, message: "Invalid array index: \(idx)", atFunction: #function, inFile: #file)
					result = false
				}
			} else {
				if 0<=idx && idx<mArrayValue.count {
					result = mArrayValue[idx]._set(value: val, forPath: rest, in: root)
				} else {
					CNLog(logLevel: .error, message: "Invalid array index: \(idx)", atFunction: #function, inFile: #file)
					result = false
				}
			}
		case .keyAndValue(let srckey, let srcval):
			if let (curidx, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					/* Replace child itself */
					mArrayValue[curidx] = val
					root.isDirty = true
					result = true
				} else {
					/* Trace child */
					result = curdict._set(value: val, forPath: rest, in: root)
				}
			} else {
				let valtxt = srcval.toText().toStrings().joined(separator: "\n")
				CNLog(logLevel: .error, message: "Invalid key or value: \(srckey):\(valtxt)", atFunction: #function, inFile: #file)
				result = false
			}
		}
		return result
	}

	public override func _append(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		let result: Bool
		if let first = path.first {
			let rest = Array(path.dropFirst())
			switch first {
			case .member(let member):
				CNLog(logLevel: .error, message: "Array index is required but key is given: \(member)", atFunction: #function, inFile: #file)
				result = false
			case .index(let idx):
				if 0<=idx && idx<mArrayValue.count {
					let dst  = mArrayValue[idx]

					let dval = val.clone()
					result = dst._append(value: dval, forPath: rest, in: root)
				} else {
					CNLog(logLevel: .error, message: "Array index overflow: \(idx)", atFunction: #function, inFile: #file)
					result = false
				}
			case .keyAndValue(let srckey, let srcval):
				if let (_, curdict) = searchChild(key: srckey, value: srcval) {
					if rest.count == 0 {
						let valtxt = srcval.toText().toStrings().joined(separator: "\n")
						CNLog(logLevel: .error, message: "Invalid key or value: \(srckey):\(valtxt)", atFunction: #function, inFile: #file)
						result = false
					} else {
						/* Trace child */
						result = curdict._append(value: val, forPath: rest, in: root)
					}
				} else {
					let valtxt = srcval.toText().toStrings().joined(separator: "\n")
					CNLog(logLevel: .error, message: "Invalid key or value: \(srckey):\(valtxt)", atFunction: #function, inFile: #file)
					result = false
				}
			}
		} else {
			let dval = val.clone()
			mArrayValue.append(dval)
			root.isDirty = true
			result = true
		}
		return result
	}

	public override func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for array value", atFunction: #function, inFile: #file)
			return false
		}
		let rest = Array(path.dropFirst())
		let result: Bool
		switch first {
		case .member(let member):
			CNLog(logLevel: .error, message: "Array index is required but key is given: \(member)", atFunction: #function, inFile: #file)
			result = false
		case .index(let idx):
			if rest.count == 0 {
				if 0<=idx && idx<mArrayValue.count {
					mArrayValue.remove(at: idx)
					root.isDirty = true
					result = true
				} else {
					result = false
				}
			} else {
				if 0<=idx && idx<mArrayValue.count {
					result = mArrayValue[idx]._delete(forPath: rest, in: root)
				} else {
					result = false
				}
			}
		case .keyAndValue(let srckey, let srcval):
			if let (curidx, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					/* Delete child itself */
					mArrayValue.remove(at: curidx)
					root.isDirty = true
					result = true
				} else {
					/* Trace child */
					result = curdict._delete(forPath: rest, in: root)
				}
			} else {
				let valtxt = srcval.toText().toStrings().joined(separator: "\n")
				CNLog(logLevel: .error, message: "Invalid key or value: \(srckey):\(valtxt)", atFunction: #function, inFile: #file)
				result = false
			}
		}
		return result
	}

	private func searchChild(key srckey: String, value srcval: CNValue) -> (Int, CNMutableDictionaryValue)? {
		for i in 0..<mArrayValue.count {
			if let dict = mArrayValue[i] as? CNMutableDictionaryValue {
				if let curval = dict.get(forKey: srckey) {
					if CNIsSameValue(nativeValue0: curval.toValue(), nativeValue1: srcval){
						return (i, dict)
					}
				}
			}
		}
		return nil
	}

	public override func _search(name nm: String, value val: String, in root: CNMutableValue) -> Array<CNValuePath.Element>? {
		for i in 0..<mArrayValue.count {
			let elm = mArrayValue[i]
			if var rpath = elm._search(name: nm, value: val, in: root) {
				rpath.insert(.index(i), at: 0)
				return rpath
			}
		}
		return nil
	}

	public override func _makeLabelTable(path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		var result: Dictionary<String, Array<CNValuePath.Element>> = [:]
		for i in 0..<mArrayValue.count {
			var curpath: Array<CNValuePath.Element> = []
			curpath.append(contentsOf: pth)
			curpath.append(.index(i))
			let subres = mArrayValue[i]._makeLabelTable(path: curpath)
			for (skey, sval) in subres {
				result[skey] = sval
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

	public func get(forKey key: String) -> CNMutableValue? {
		return mDictionaryValue[key]
	}

	public override func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> CNMutableValue? {
		guard let first = path.first else {
			/* Return entire dicrectory */
			return self.clone()
		}
		let rest = Array(path.dropFirst(1))
		let result: CNMutableValue?
		switch first {
		case .member(let member):
			if let targ = mDictionaryValue[member] {
				result = targ._value(forPath: rest, in: root)
			} else {
				result = nil
			}
		case .index(let idx):
			CNLog(logLevel: .error, message: "Dictionary key is required but index is given: \(idx)", atFunction: #function, inFile: #file)
			result = nil
		case .keyAndValue(let srckey, let srcval):
			if let (_, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					/* Return child itself */
					result = curdict
				} else {
					/* Trace child */
					result = curdict._value(forPath: rest, in: root)
				}
			} else {
				let valtxt = srcval.toText().toStrings().joined(separator: "\n")
				CNLog(logLevel: .error, message: "Invalid key or value: \(srckey):\(valtxt)", atFunction: #function, inFile: #file)
				result = nil
			}
		}
		return result
	}

	public override func _set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for dictionary value", atFunction: #function, inFile: #file)
			return false
		}
		let rest = Array(path.dropFirst(1))
		let result: Bool
		switch first {
		case .member(let member):
			if rest.count == 0 {
				let dval = val.clone()
				mDictionaryValue[member] = dval
				root.isDirty = true
				result = true
			} else {
				if let dst = mDictionaryValue[member] {
					result = dst._set(value: val, forPath: rest, in: root)
				} else {
					/* append new sub-tree */
					mDictionaryValue[member] = val.clone()
					root.isDirty = true
					result = true
				}
			}
		case .index(let idx):
			CNLog(logLevel: .error, message: "Dictionary key is required but index is given: \(idx)", atFunction: #function, inFile: #file)
			result = false
		case .keyAndValue(let srckey, let srcval):
			if let (curkey, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					/* Replace child itself */
					mDictionaryValue[curkey] = val
					root.isDirty = true
					result = true
				} else {
					/* Trace child */
					result = curdict._set(value: val, forPath: rest, in: root)
				}
			} else {
				let valtxt = srcval.toText().toStrings().joined(separator: "\n")
				CNLog(logLevel: .error, message: "Invalid key or value: \(srckey):\(valtxt)", atFunction: #function, inFile: #file)
				result = false
			}
		}
		return result
	}

	public override func _append(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for dictionary value", atFunction: #function, inFile: #file)
			return false
		}
		let rest = Array(path.dropFirst(1))
		let result: Bool
		switch first {
		case .member(let member):
			if let dst = mDictionaryValue[member] {
				result = dst._append(value: val, forPath: rest, in: root)
			} else {
				mDictionaryValue[member] = val.clone()
				root.isDirty = true
				result = true
			}
		case .index(let idx):
			CNLog(logLevel: .error, message: "Dictionary key is required but index is given: \(idx)", atFunction: #function, inFile: #file)
			result = false
		case .keyAndValue(let srckey, let srcval):
			if let (_, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					let valtxt = srcval.toText().toStrings().joined(separator: "\n")
					CNLog(logLevel: .error, message: "Invalid key or value: \(srckey):\(valtxt)", atFunction: #function, inFile: #file)
					result = false
				} else {
					/* Trace child */
					result = curdict._append(value: val, forPath: rest, in: root)
				}
			} else {
				let valtxt = srcval.toText().toStrings().joined(separator: "\n")
				CNLog(logLevel: .error, message: "Invalid key or value: \(srckey):\(valtxt)", atFunction: #function, inFile: #file)
				result = false
			}
		}
		return result
	}

	public override func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		guard let first = path.first else {
			CNLog(logLevel: .error, message: "Empty path for dictionary value", atFunction: #function, inFile: #file)
			return false
		}
		let rest = Array(path.dropFirst(1))
		let result: Bool
		switch first {
		case .member(let member):
			if rest.count == 0 {
				if let _ = mDictionaryValue[member] {
					mDictionaryValue.removeValue(forKey: member)
					root.isDirty = true
					result = true
				} else {
					CNLog(logLevel: .error, message: "Unexpected key: \(member)", atFunction: #function, inFile: #file)
					result = false
				}
			} else {
				if let dst = mDictionaryValue[member] {
					result = dst._delete(forPath: rest, in: root)
				} else {
					CNLog(logLevel: .error, message: "Unexpected key: \(member)", atFunction: #function, inFile: #file)
					result = false
				}
			}
		case .index(let idx):
			CNLog(logLevel: .error, message: "Dictionary key is required but index is given: \(idx)", atFunction: #function, inFile: #file)
			result = false
		case .keyAndValue(let srckey, let srcval):
			if let (curkey, curdict) = searchChild(key: srckey, value: srcval) {
				if rest.count == 0 {
					/* Delete child itself */
					mDictionaryValue[curkey] = nil
					root.isDirty = true
					result = true
				} else {
					/* Trace child */
					result = curdict._delete(forPath: rest, in: root)
				}
			} else {
				let valtxt = srcval.toText().toStrings().joined(separator: "\n")
				CNLog(logLevel: .error, message: "Invalid key or value: \(srckey):\(valtxt)", atFunction: #function, inFile: #file)
				result = false
			}
		}
		return result
	}

	private func searchChild(key srckey: String, value srcval: CNValue) -> (String, CNMutableDictionaryValue)? {
		for key in mDictionaryValue.keys {
			if let dict = mDictionaryValue[key] as? CNMutableDictionaryValue {
				if let curval = dict.get(forKey: srckey) {
					if CNIsSameValue(nativeValue0: curval.toValue(), nativeValue1: srcval){
						return (key, dict)
					}
				}
			}
		}
		return nil
	}

	public override func _search(name nm: String, value val: String, in root: CNMutableValue) -> Array<CNValuePath.Element>? {
		/* Search itself */
		if let elm = mDictionaryValue[nm] {
			if let estr = elm.toValue().toString() {
				if estr == val {
					return [.member(nm)]
				}
			}
		}
		/* Search children */
		for key in mDictionaryValue.keys {
			if let elm = mDictionaryValue[key] {
				if var rpath = elm._search(name: nm, value: val, in: root) {
					rpath.insert(.member(key), at: 0)
					return rpath
				}
			}
		}
		return nil
	}

	public override func _makeLabelTable(path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		var result: Dictionary<String, Array<CNValuePath.Element>> = [:]
		/* Update itsel */
		if let val = mDictionaryValue["id"] {
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
			let subres = val._makeLabelTable(path: curpath)
			for (skey, sval) in subres {
				result[skey] = sval
			}
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

public class CNMutableValueSegment: CNMutableValue
{
	private var mSegmentValue: 	CNValueSegment
	private var mSourceDirectory:	URL
	private var mCacheDirectory:	URL
	private var mContext:		CNMutableValue?

	public init(value val: CNValueSegment, sourceDirectory srcdir: URL, cacheDirectory cachedir: URL){
		mSegmentValue 		= val
		mSourceDirectory	= srcdir
		mCacheDirectory		= cachedir
		mContext		= nil
		super.init(type: .segment)
	}

	public var sourceDirectory: URL     { get { return mSourceDirectory }}
	public var cacheDirectory:  URL     { get { return mCacheDirectory  }}
	public var context: CNMutableValue? { get { return mContext         }}

	public var sourceFile: URL { get {
		return mSourceDirectory.appendingPathComponent(mSegmentValue.filePath)
	}}
	public var cacheFile: URL { get {
		return mCacheDirectory.appendingPathComponent(mSegmentValue.filePath)
	}}

	public override func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> CNMutableValue? {
		let result: CNMutableValue?
		if let val = load() {
			result = val._value(forPath: path, in: root)
		} else {
			result = nil
		}
		return result
	}

	public override func _set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		let result: Bool
		if let dst = load() {
			result = dst._set(value: val, forPath: path, in: root)
		} else {
			result = false
		}
		return result
	}

	public override func _append(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		let result: Bool
		if let dst = load() {
			result = dst._append(value: val, forPath: path, in: root)
		} else {
			result = false
		}
		return result
	}

	public override func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		let result: Bool
		if let dst = load() {
			result = dst._delete(forPath: path, in: root)
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
			if let src = mSegmentValue.load(fromSourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory) {
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

	public override func _search(name nm: String, value val: String, in root: CNMutableValue) -> Array<CNValuePath.Element>? {
		let result: Array<CNValuePath.Element>?
		if let dst = load() {
			result = dst._search(name: nm, value: val, in: root)
		} else {
			result = nil
		}
		return result
	}

	public override func _makeLabelTable(path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		if let dst = load() {
			return dst._makeLabelTable(path: pth)
		} else {
			return [:]
		}
	}

	public override func clone() -> CNMutableValue {
		return CNMutableValueSegment(value: mSegmentValue, sourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory)
	}

	public override func toValue() -> CNValue {
		return .segmentValue(mSegmentValue)
	}
}


public class CNMutablePointerValue: CNMutableValue
{
	private var mPointerValue:	CNPointerValue
	private var mContext:		CNMutableValue?

	public init(pointer val: CNPointerValue){
		mPointerValue		= val
		mContext		= nil
		super.init(type: .pointer)
	}

	public var context: CNMutableValue? { get { return mContext         }}

	public override func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> CNMutableValue? {
		let result: CNMutableValue?
		if let pvalue = pointedValue(in: root) {
			result = pvalue._value(forPath: path, in: root)
		} else {
			result = nil
		}
		return result
	}

	public override func _set(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		let result: Bool
		if path.count == 0 {
			/* Overide this value */
			if let newptr = val as? CNMutablePointerValue {
				mPointerValue = newptr.mPointerValue
				root.isDirty = true
				result = true
			} else {
				CNLog(logLevel: .error, message: "Only pointer value can be set", atFunction: #function, inFile: #file)
				result = false
			}
		} else {
			if let pvalue = pointedValue(in: root) {
				result = pvalue._set(value: val, forPath: path, in: root)
			} else {
				result = false
			}
		}
		return result
	}

	public override func _append(value val: CNMutableValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		let result: Bool
		if path.count > 0 {
			if let pvalue = pointedValue(in: root) {
				result = pvalue._append(value: val, forPath: path, in: root)
			} else {
				result = false
			}
		} else {
			CNLog(logLevel: .error, message: "Only pointer value can be append", atFunction: #function, inFile: #file)
			result = false
		}
		return result
	}

	public override func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Bool {
		let result: Bool
		if path.count > 0 {
			if let pvalue = pointedValue(in: root) {
				result = pvalue._delete(forPath: path, in: root)
			} else {
				result = false
			}
		} else {
			CNLog(logLevel: .error, message: "Only pointer value can be delete", atFunction: #function, inFile: #file)
			result = false
		}
		return result
	}

	public override func _search(name nm: String, value val: String, in root: CNMutableValue) -> Array<CNValuePath.Element>? {
		let result: Array<CNValuePath.Element>?
		if let pvalue = pointedValue(in: root) {
			result = pvalue._search(name: nm, value: val, in: root)
		} else {
			result = nil
		}
		return result
	}

	private func pointedValue(in root: CNMutableValue) -> CNMutableValue? {
		let elms: Array<CNValuePath.Element>
		if let ident = mPointerValue.path.identifier {
			let table = CNMutableValue.labelTable(in: root)
			if let top = table[ident] {
				var fullelms = top
				fullelms.append(contentsOf: mPointerValue.path.elements)
				elms = fullelms
			} else {
				CNLog(logLevel: .error, message: "Label \(ident) is not found: \(mPointerValue.path.description)", atFunction: #function, inFile: #file)
				elms = mPointerValue.path.elements
			}
		} else {
			elms = mPointerValue.path.elements
		}

		let result: CNMutableValue?
		if let val = root._value(forPath: elms, in: root) {
			result = val
		} else {
			let path = CNValuePath.toExpression(identifier: nil, elements: elms)
			CNLog(logLevel: .error, message: "Pointed value is not found: \(path)")
			result = nil
		}
		return result
	}

	public override func _makeLabelTable(path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		return [:]
	}

	public override func clone() -> CNMutableValue {
		return CNMutablePointerValue(pointer: mPointerValue)
	}

	public override func toValue() -> CNValue {
		return .pointerValue(mPointerValue)
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
	case .segmentValue(let ref):
		let newref = CNMutableValueSegment(value: ref, sourceDirectory: srcdir, cacheDirectory: cachedir)
		result = newref
	case .pointerValue(let ptr):
		let newptr = CNMutablePointerValue(pointer: ptr)
		result = newptr
	default:
		let newscalar = CNMutableScalarValue(scalarValue: val)
		result = newscalar
	}
	return result
}

public func CNAllSegmentsInValue(value val: CNMutableValue) -> Array<CNMutableValueSegment> {
	var result: Array<CNMutableValueSegment> = []
	switch val.type {
	case .scaler:
		break
	case .dictionary:
		if let dict = val as? CNMutableDictionaryValue {
			for child in dict.values {
				let cres = CNAllSegmentsInValue(value: child)
				result.append(contentsOf: cres)
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen (1)", atFunction: #function, inFile: #file)
		}
	case .array:
		if let arr = val as? CNMutableArrayValue {
			for child in arr.values {
				let cres = CNAllSegmentsInValue(value: child)
				result.append(contentsOf: cres)
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen (2)", atFunction: #function, inFile: #file)
		}
	case .segment:
		if let ref = val as? CNMutableValueSegment {
			result.append(ref)
		} else {
			CNLog(logLevel: .error, message: "Can not happen (3)", atFunction: #function, inFile: #file)
		}
	case .pointer:
		break
	}
	return result
}


