/*
 * @file	CNValueSet.swift
 * @brief	Define CNValueSet class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNValueSet
{
	public static let ClassName	= "Set"

	/* The element is sorted in ascending order */
	private var mValues:	Array<CNValue>

	public init(){
		mValues = []
	}

	public var values: Array<CNValue> { get {
		return mValues
	}}

	public var count: Int { get {
		return mValues.count
	}}

	public func insert(value src: CNValue){
		for i in 0..<mValues.count {
			switch CNCompareValue(nativeValue0: src, nativeValue1: mValues[i]) {
			case .orderedAscending:		// src < mValues
				mValues.insert(src, at: i)
				return	// finish insertions
			case .orderedSame:		// src == mValues
				return	// already defined
			case .orderedDescending:	//       mValues[i] < src
				break	// continue
			}
		}
		mValues.append(src)
	}

	public func remove(value src: CNValue) -> Bool {
		for i in 0..<mValues.count {
			switch CNCompareValue(nativeValue0: src, nativeValue1: mValues[i]) {
			case .orderedAscending:		// src < mValues[i]
				return false		// continue
			case .orderedDescending:	// src > mValues[i]
				break		// continue
			case .orderedSame:
				mValues.remove(at: i)
				return true	// Removed
			}
		}
		return false // not found
	}

	public func has(value src: CNValue) -> Bool {
		for i in 0..<mValues.count {
			switch CNCompareValue(nativeValue0: src, nativeValue1: mValues[i]) {
			case .orderedAscending:		// mValues[i] < src
				break		// continue
			case .orderedDescending:	// src < mValues[i]
				return false	// Not found
			case .orderedSame:
				return true	// Found
			}
		}
		return false
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNValueSet? {
		guard CNValue.hasClassName(inValue: val, className: CNValueSet.ClassName) else {
			return nil
		}
		if let vals = val["values"] {
			if let arr = vals.toArray() {
				let newval = CNValueSet()
				for elm in arr {
					newval.insert(value: elm)
				}
				return newval
			}
		}
		return nil
	}

	public func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"class"  : .stringValue(CNValueSet.ClassName),
			"values" : .arrayValue(self.values)
		]
		return result
	}

	public func toText() -> CNText {
		let val: CNValue = .dictionaryValue(self.toValue())
		return val.toText()
	}
}

