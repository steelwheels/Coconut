/*
 * @file	CNValueComparator.swift
 * @brief	Define CNValueComparator class
 * @par Copyright
 *   Copyright (C) 2018, 2021 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import Foundation

public extension ComparisonResult
{
	func toString() -> String {
		let result: String
		switch self {
		case .orderedAscending:	 	result = "ascending(<)"
		case .orderedDescending: 	result = "descendint(>)"
		case .orderedSame:		result = "equal(==)"
		}
		return result
	}
}

private func CNCastToCompareValue(value val: CNValue) -> CNValue {
	switch val {
	case .enumValue(let eval):
		return .numberValue(NSNumber(integerLiteral: eval.value))
	default:
		return val
	}
}

public func CNCompareValue(nativeValue0 ival0: CNValue, nativeValue1 ival1: CNValue) -> ComparisonResult
{
	let cval0 = CNCastToCompareValue(value: ival0)
	let cval1 = CNCastToCompareValue(value: ival1)

	switch CNValueType.compare(type0: cval0.valueType, type1: cval1.valueType) {
	case .orderedAscending:
		return .orderedAscending
	case .orderedDescending:
		return .orderedDescending
	case .orderedSame:
		break // continue
	}

	var result: ComparisonResult? = nil
	switch cval0.valueType {
	case .voidType:
		result = .orderedSame
	case .anyType:
		result = .orderedSame
	case .boolType:
		if let s0 = cval0.toBool(), let s1 = cval1.toBool() {
			result = compare(bool0: s0, bool1: s1)
		}
	case .numberType:
		if let s0 = cval0.toNumber(), let s1 = cval1.toNumber() {
			result = s0.compare(s1)
		}
	case .stringType:
		if let s0 = cval0.toString(), let s1 = cval1.toString() {
			result = s0.compare(s1)
		}
	case .enumType:
		/* Cast operation replace this type */
		CNLog(logLevel: .error, message: "Failed to compare enum", atFunction: #function, inFile: #file)
	case .dictionaryType:
		if let s0 = cval0.toDictionary(), let s1 = cval1.toDictionary() {
			result = compare(dictionary0: s0, dictionary1: s1)
		}
	case .arrayType:
		if let s0 = cval0.toArray(), let s1 = cval1.toArray() {
			result = compare(array0: s0, array1: s1)
		}
	case .setType:
		if let s0 = cval0.toSet(), let s1 = cval1.toSet() {
			result = CNValueSet.compare(set0: s0, set1: s1)
		}
	case .recordType(_):
		if let s0 = cval0.toRecord(), let s1 = cval1.toRecord() {
			result = compare(record0: s0, record1: s1)
		}
	case .objectType(_), .functionType(_, _):
		CNLog(logLevel: .error, message: "Failed to compare object", atFunction: #function, inFile: #file)
	}

	if let res = result {
		return res
	} else {
		CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		return .orderedAscending
	}
}

public func CNIsSameValue(nativeValue0 val0: CNValue, nativeValue1 val1: CNValue) -> Bool
{
	let result: Bool
	switch CNCompareValue(nativeValue0: val0, nativeValue1: val1) {
	case .orderedAscending, .orderedDescending:
		result = false
	case .orderedSame:
		result = true
	}
	return result
}

private func compare(bool0 s0: Bool, bool1 s1: Bool) -> ComparisonResult {
	let result: ComparisonResult
	if s0 == s1 {
		result = .orderedSame
	} else if s0 { // s0:true,  s1: false
		result = .orderedDescending
	} else {       // s0:false, s1: true
		result = .orderedAscending
	}
	return result
}

private func compare(color0 s0: CNColor, color1 s1: CNColor) -> ComparisonResult {
	var r0 : CGFloat = 0.0, g0 : CGFloat = 0.0, b0 : CGFloat = 0.0, a0 : CGFloat = 0.0
	s0.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)

	var r1 : CGFloat = 0.0, g1 : CGFloat = 0.0, b1 : CGFloat = 0.0, a1 : CGFloat = 0.0
	s1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)

	let resr = compare(float0: r0, float1: r1)
	switch resr {
	case .orderedAscending, .orderedDescending:
		return resr
	case .orderedSame:
		break // continue
	}

	let resg = compare(float0: g0, float1: g1)
	switch resg {
	case .orderedAscending, .orderedDescending:
		return resg
	case .orderedSame:
		break // continue
	}

	let resb = compare(float0: b0, float1: b1)
	switch resb {
	case .orderedAscending, .orderedDescending:
		return resb
	case .orderedSame:
		break // continue
	}

	return .orderedSame
}

private func compare(array0 s0: Array<CNValue>, array1 s1: Array<CNValue>) -> ComparisonResult {
	switch compare(int0: s0.count, int1: s1.count) {
	case .orderedAscending:
		return .orderedAscending
	case .orderedDescending:
		return .orderedDescending
	case .orderedSame:
		break
	}
	for i in 0..<s0.count {
		switch CNCompareValue(nativeValue0: s0[i], nativeValue1: s1[i]) {
		case .orderedAscending:
			return .orderedAscending
		case .orderedDescending:
			return .orderedDescending
		case .orderedSame:
			break // continue
		}
	}
	return .orderedSame
}

private func compare(dictionary0 s0: Dictionary<String, CNValue>, dictionary1 s1: Dictionary<String, CNValue>) -> ComparisonResult {
	let keys0 = s0.keys
	let keys1 = s1.keys
	switch compare(int0: keys0.count, int1: keys1.count){
	case .orderedAscending:
		return .orderedAscending
	case .orderedDescending:
		return .orderedDescending
	case .orderedSame:
		break // continue
	}
	let skeys0 = keys0.sorted()
	let skeys1 = keys1.sorted()
	for i in 0..<skeys0.count {
		switch skeys0[i].compare(skeys1[i]) {
		case .orderedAscending:
			return .orderedAscending
		case .orderedDescending:
			return .orderedDescending
		case .orderedSame:
			break
		}
	}
	for i in 0..<skeys0.count {
		let key = skeys0[i]
		if let v0 = s0[key], let v1 = s1[key] {
			switch CNCompareValue(nativeValue0: v0, nativeValue1: v1) {
			case .orderedAscending:
				return .orderedAscending
			case .orderedDescending:
				return .orderedDescending
			case .orderedSame:
				break
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen at function \(#function) in file \(#file)", atFunction: #function, inFile: #file)
		}
	}
	return .orderedSame
}

private func compare(int0 s0: Int, int1 s1: Int) -> ComparisonResult {
	let result: ComparisonResult
	if s0 > s1 {
		result = .orderedDescending
	} else if s0 < s1 {
		result = .orderedAscending
	} else {
		result = .orderedSame
	}
	return result
}

private func compare(float0 s0: CGFloat, float1 s1: CGFloat) -> ComparisonResult {
	let result: ComparisonResult
	if s0 > s1 {
		result = .orderedDescending
	} else if s0 < s1 {
		result = .orderedAscending
	} else {
		result = .orderedSame
	}
	return result
}

private func compare(string0 s0: String, string1 s1: String) -> ComparisonResult {
	let result: ComparisonResult
	if s0 > s1 {
		result = .orderedDescending
	} else if s0 < s1 {
		result = .orderedAscending
	} else {
		result = .orderedSame
	}
	return result
}

private func compare(record0 s0: CNRecord, record1 s1: CNRecord) -> ComparisonResult {
	let d0 = s0.toDictionary()
	let d1 = s1.toDictionary()
	return compare(dictionary0: d0, dictionary1: d1)
}

