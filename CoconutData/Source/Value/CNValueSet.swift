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

	public static func isSet(dictionary dict: Dictionary<String, CNValue>) -> Bool {
		if let clsname = dict["class"] {
			switch clsname {
			case .stringValue(let str):
				return str == CNValueSet.ClassName
			default:
				break
			}
		}
		return false
	}

	public static func fromValue(value val: CNValue) -> CNValue? {
		if let dict = val.toDictionary() {
			return fromValue(value: dict)
		} else {
			return nil
		}
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNValue? {
		guard CNValue.hasClassName(inValue: val, className: CNValueSet.ClassName) else {
			return nil
		}
		if let vals = val["values"] {
			if let srcs = vals.toArray() {
				var newarr: Array<CNValue> = []
				for elm in srcs {
					CNValueSet.insert(target: &newarr, element: elm)
				}
				return .setValue(newarr)
			}
		}
		return nil
	}

	public static func toValue(values vals: Array<CNValue>) -> CNValue {
		let result: Dictionary<String, CNValue> = [
			"class":	.stringValue(CNValueSet.ClassName),
			"values":	.arrayValue(vals)
		]
		return .dictionaryValue(result)
	}

	public static func insert(target targ: inout Array<CNValue>, element elm: CNValue) {
		let cnt = targ.count
		for i in 0..<cnt {
			switch CNCompareValue(nativeValue0: elm, nativeValue1: targ[i]) {
			case .orderedAscending:		// src < mValues
				targ.insert(elm, at: i)
				return	// finish insertions
			case .orderedSame:		// src == mValues
				return	// already defined
			case .orderedDescending:	//       mValues[i] < src
				break   // continue
			}
		}
		targ.append(elm)
	}

	public static func compare(set0 s0: Array<CNValue>, set1 s1: Array<CNValue>) -> ComparisonResult {
		let c0 = s0.count
		let c1 = s1.count
		if(c0 < c1){
			return .orderedAscending
		} else if(c0 > c1) {
			return .orderedDescending
		} else { // c0 == c1
			for i in 0..<c0 {
				switch CNCompareValue(nativeValue0: s0[i], nativeValue1: s1[i]) {
				case .orderedAscending:
					return .orderedAscending
				case .orderedSame:
					break	// continue
				case .orderedDescending:
					return .orderedDescending
				}
			}
			return .orderedSame
		}
	}
}

