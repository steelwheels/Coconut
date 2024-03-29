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
		case scaler(CNValueType)
		case array
		case set
		case dictionary
		case record(CNInterfaceType)
		case segment
		case pointer

		public func compare(_ src: ValueType) -> ComparisonResult {
			switch self {
			case .scaler(let thistype):
				switch src {
				case .scaler(let srctype):
					return CNValueType.compare(type0: thistype, type1: srctype)
				default:
					break
				}
			default:
				break
			}
			return CNCompare(self.intValue, src.intValue)
		}

		private var intValue: Int { get {
			let result: Int
			switch self {
			case .scaler(_):	result = 0
			case .array:		result = 1
			case .set:		result = 2
			case .dictionary:	result = 3
			case .record:		result = 4
			case .segment:		result = 5
			case .pointer:		result = 6
			}
			return result
		}}

		public static func from(valueType src: CNValueType) -> ValueType {
			let result: ValueType
			switch src {
			case .voidType, .anyType, .boolType, .numberType, .stringType, .functionType(_, _), .enumType(_), .objectType(_):
				result = scaler(src)
			case .arrayType(_):
				result = .array
			case .dictionaryType(_):
				result = .dictionary
			case .setType(_):
				result = .set
			case .interfaceType(let iftyp):
				result = .record(iftyp)
			}
			return result
		}
	}

	fileprivate var mType:    	ValueType
	private var	mLabelTable:	CNValueLabels?
	public var	type:    	ValueType { get { return mType    }}
	public var 	isDirty:	Bool

	private var mSourceDirectory:	URL
	private var mCacheDirectory:	URL

	public var sourceDirectory: URL     { get { return mSourceDirectory }}
	public var cacheDirectory:  URL     { get { return mCacheDirectory  }}

	public init(type t: ValueType, sourceDirectory srcdir: URL, cacheDirectory cachedir: URL){
		mType			= t
		mLabelTable		= nil
		mSourceDirectory	= srcdir
		mCacheDirectory		= cachedir
		isDirty			= false
	}

	public func value(forPath path: Array<CNValuePath.Element>) -> Result<CNValue?, NSError> {
		switch self._value(forPath: path, in: self) {
		case .success(let mvalp):
			if let mval = mvalp {
				return .success(mval.toValue())
			} else {
				return .success(nil)
			}
		case .failure(let err):
			return .failure(err)
		}
	}

	public func set(value val: CNValue, forPath path:  Array<CNValuePath.Element>) -> NSError? {
		return self._set(value: val, forPath: path, in: self)
	}

	public func append(value val: CNValue, forPath path:  Array<CNValuePath.Element>) -> NSError? {
		return self._append(value: val, forPath: path, in: self)
	}

	public func delete(forPath path: Array<CNValuePath.Element>) -> NSError? {
		return self._delete(forPath: path, in: self)
	}

	public func search(name nm: String, value val: String) -> Result<Array<CNValuePath.Element>?, NSError> {
		return self._search(name: nm, value: val, in: self)
	}

	public func labelTable() -> CNValueLabels {
		if let table = mLabelTable {
			return table
		} else {
			let newtbl  = CNValueLabels()
			mLabelTable = newtbl
			return newtbl
		}
	}

	public func makeLabelTable(property name: String) -> Dictionary<String, Array<CNValuePath.Element>> {
		return _makeLabelTable(property: name, path: [])
	}

	open func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Result<CNMutableValue?, NSError> {
		return .failure(NSError.parseError(message: "Must be override: _value"))
	}

	open func _set(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		return NSError.parseError(message: "Must be override: _set")
	}

	open func _append(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		return NSError.parseError(message: "Must be override: _append")
	}

	open func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		return NSError.parseError(message: "Must be override: _delete")
	}

	open func _search(name nm: String, value val: String, in root: CNMutableValue) -> Result<Array<CNValuePath.Element>?, NSError> {
		return .failure(NSError.parseError(message: "Must be override: _search"))
	}

	open func _makeLabelTable(property name: String, path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return [:]
	}

	open func clone() -> CNMutableValue {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return CNMutableScalarValue(scalarValue: CNValue.null, sourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory)
	}

	open func toValue() -> CNValue {
		CNLog(logLevel: .error, message: "Do override", atFunction: #function, inFile: #file)
		return CNValue.null
	}

	public func unmatchedPathError(path pth: Array<CNValuePath.Element>, place pstr: String) -> NSError {
		let pathdesc = CNValuePath.toExpression(identifier: nil, elements: pth)
		return NSError.parseError(message: "Unmatched path error: \(pathdesc) at \(pstr)")
	}

	public func canNotHappenError(path pth: Array<CNValuePath.Element>, place pstr: String) -> NSError {
		let pathdesc = CNValuePath.toExpression(identifier: nil, elements: pth)
		return NSError.parseError(message: "Can not happen error: \(pathdesc) at \(pstr)")
	}

	public func noPointedValueError(path pth: Array<CNValuePath.Element>, place pstr: String) -> NSError {
		let pathdesc = CNValuePath.toExpression(identifier: nil, elements: pth)
		return NSError.parseError(message: "No pointed value error: \(pathdesc) at \(pstr)")
	}

	public func toMutableValue(from val: CNValue) -> CNMutableValue {
		return CNMutableValue.valueToMutableValue(from: val, sourceDirectory: self.sourceDirectory, cacheDirectory: self.cacheDirectory)
	}

	public static func valueToMutableValue(from val: CNValue, sourceDirectory srcdir: URL, cacheDirectory cachedir: URL) -> CNMutableValue {
		let result: CNMutableValue
		switch val {
		case .arrayValue(let arr):
			let newarr = CNMutableArrayValue(sourceDirectory: srcdir, cacheDirectory: cachedir)
			for elm in arr {
				let newelm = valueToMutableValue(from: elm, sourceDirectory: srcdir, cacheDirectory: cachedir)
				newarr.append(value: newelm)
			}
			result = newarr
		case .setValue(let set):
			let newset = CNMutableSetValue(sourceDirectory: srcdir, cacheDirectory: cachedir)
			for elm in set {
				let newelm = valueToMutableValue(from: elm, sourceDirectory: srcdir, cacheDirectory: cachedir)
				newset.append(value: newelm)
			}
			result = newset
		case .dictionaryValue(let dict):
			if let seg = CNValueSegment.fromValue(value: dict) {
				let newseg = CNMutableValueSegment(value: seg, sourceDirectory: srcdir, cacheDirectory: cachedir)
				result = newseg
			} else if let ptr = CNPointerValue.fromValue(value: dict) {
				let newptr = CNMutablePointerValue(pointer: ptr, sourceDirectory: srcdir, cacheDirectory: cachedir)
				result = newptr
			} else {
				let newdict = CNMutableDictionaryValue(sourceDirectory: srcdir, cacheDirectory: cachedir)
				for (key, elm) in dict {
					let newelm = valueToMutableValue(from: elm, sourceDirectory: srcdir, cacheDirectory: cachedir)
					newdict.set(value: newelm, forKey: key)
				}
				result = newdict
			}
		case .interfaceValue(let ifval):
			let newrec = CNMutableRecordValue(fieldTypes: ifval.type, sourceDirectory: srcdir, cacheDirectory: cachedir)
			for (key, elm) in ifval.values {
				let newelm = valueToMutableValue(from: elm, sourceDirectory: srcdir, cacheDirectory: cachedir)
				newrec.set(value: newelm, forKey: key)
			}
			result = newrec
		default:
			let newscalar = CNMutableScalarValue(scalarValue: val, sourceDirectory: srcdir, cacheDirectory: cachedir)
			result = newscalar
		}
		return result
	}
}

public enum CNValueSegmentTraceOption {
	case noTrace
	case traceNonNull
	case traceAll
}

public func CNSegmentsInValue(value val: CNMutableValue, traceOption trace: CNValueSegmentTraceOption) -> Array<CNMutableValueSegment> {
	var result: Array<CNMutableValueSegment> = []
	switch val.type {
	case .scaler:
		break
	case .dictionary:
		if let dict = val as? CNMutableDictionaryValue {
			for child in dict.values {
				let cres = CNSegmentsInValue(value: child, traceOption: trace)
				result.append(contentsOf: cres)
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen (dictionary)", atFunction: #function, inFile: #file)
		}
	case .record(_):
		if let rec = val as? CNMutableRecordValue {
			for child in rec.values {
				let cres = CNSegmentsInValue(value: child, traceOption: trace)
				result.append(contentsOf: cres)
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen (record)", atFunction: #function, inFile: #file)
		}
	case .array:
		if let arr = val as? CNMutableArrayValue {
			for child in arr.values {
				let cres = CNSegmentsInValue(value: child, traceOption: trace)
				result.append(contentsOf: cres)
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen (array)", atFunction: #function, inFile: #file)
		}
	case .set:
		if let set = val as? CNMutableSetValue {
			for child in set.values {
				let cres = CNSegmentsInValue(value: child, traceOption: trace)
				result.append(contentsOf: cres)
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen (set)", atFunction: #function, inFile: #file)
		}
	case .segment:
		if let ref = val as? CNMutableValueSegment {
			result.append(ref)
			switch trace {
			case .noTrace:
				break
			case .traceNonNull:
				if let ctxt = ref.context {
					let cres = CNSegmentsInValue(value: ctxt, traceOption: trace)
					result.append(contentsOf: cres)
				}
			case .traceAll:
				switch ref.load() {
				case .success(let mval):
					let cres = CNSegmentsInValue(value: mval, traceOption: trace)
					result.append(contentsOf: cres)
				case .failure(let err):
					CNLog(logLevel: .error, message: "Error: \(err.toString())", atFunction: #function, inFile: #file)
				}
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen (segment)", atFunction: #function, inFile: #file)
		}
	case .pointer:
		break
	}
	return result
}

public func CNCompareMutableValue(value0 v0: CNMutableValue, value1 v1: CNMutableValue) -> ComparisonResult {
	switch v0.mType.compare(v1.mType) {
	case .orderedAscending:
		return .orderedAscending
	case .orderedDescending:
		return .orderedDescending
	case .orderedSame:
		return CNCompareValue(nativeValue0: v0.toValue(), nativeValue1: v1.toValue())
	}
}

