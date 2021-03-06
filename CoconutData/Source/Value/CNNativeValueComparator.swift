/*
 * @file	CNNativeValueComparator.swift
 * @brief	Define CNNativeValueComparator class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import Foundation

public extension ComparisonResult {
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

public func CNCompareNativeValueType(type0 t0: CNNativeType, type1 t1: CNNativeType) -> ComparisonResult {
	return compare(int0: t0.rawValue, int1: t1.rawValue)
}

public func CNCompareNativeValue(nativeValue0 val0: CNNativeValue, nativeValue1 val1: CNNativeValue) -> ComparisonResult
{
	switch CNCompareNativeValueType(type0: val0.valueType, type1: val1.valueType){
	case .orderedAscending:
		return .orderedAscending
	case .orderedDescending:
		return .orderedDescending
	case .orderedSame:
		break // continue
	}

	var result: ComparisonResult? = nil
	switch val0.valueType {
	case .nullType:
		result = .orderedSame
	case .numberType:
		if let s0 = val0.toNumber(), let s1 = val1.toNumber() {
			result = s0.compare(s1)
		}
	case .stringType:
		if let s0 = val0.toString(), let s1 = val1.toString() {
			result = s0.compare(s1)
		}
	case .dateType:
		if let s0 = val0.toDate(), let s1 = val1.toDate() {
			result = s0.compare(s1)
		}
	case .rangeType:
		if let s0 = val0.toRange(), let s1 = val1.toRange() {
			result = compare(range0: s0, range1: s1)
		}
	case .pointType:
		if let s0 = val0.toPoint(), let s1 = val1.toPoint() {
			result = compare(point0: s0, point1: s1)
		}
	case .sizeType:
		if let s0 = val0.toSize(), let s1 = val1.toSize() {
			result = compare(size0: s0, size1: s1)
		}
	case .rectType:
		if let s0 = val0.toRect(), let s1 = val1.toRect() {
			result = compare(rect0: s0, rect1: s1)
		}
	case .enumType:
		if let (s0, v0) = val0.toEnum(), let (s1, v1) = val1.toEnum() {
			switch s0.compare(s1) {
			case .orderedAscending:
				result = .orderedAscending
			case .orderedDescending:
				result = .orderedDescending
			case .orderedSame:
				result = compare(int0: Int(v0), int1: Int(v1))
			}
		}
	case .dictionaryType:
		if let s0 = val0.toDictionary(), let s1 = val1.toDictionary() {
			result = compare(dictionary0: s0, dictionary1: s1)
		}
	case .arrayType:
		if let s0 = val0.toArray(), let s1 = val1.toArray() {
			result = compare(array0: s0, array1: s1)
		}
	case .URLType:
		if let s0 = val0.toURL(), let s1 = val1.toURL() {
			result = compare(URL0: s0, URL1: s1)
		}
	case .colorType:
		if let s0 = val0.toColor(), let s1 = val1.toColor() {
			result = compare(color0: s0, color1: s1)
		}
	case .imageType:
		if let s0 = val0.toImage(), let s1 = val1.toImage() {
			CNLog(logLevel: .error, message: "Failed to compare image", atFunction: #function, inFile: #file)
			result = s0.description.compare(s1.description)
		}
	case .objectType:
		if let s0 = val0.toObject(), let s1 = val1.toObject() {
			CNLog(logLevel: .error, message: "Failed to compare object", atFunction: #function, inFile: #file)
			result = s0.description.compare(s1.description)
		}
	}

	if let res = result {
		return res
	} else {
		CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		return .orderedAscending
	}
}

private func compare(range0 s0: NSRange, range1 s1: NSRange) -> ComparisonResult {
	let result: ComparisonResult
	switch compare(int0: s0.location, int1: s1.location) {
	case .orderedAscending:
		result = .orderedAscending
	case .orderedDescending:
		result = .orderedDescending
	case .orderedSame:
		result = compare(int0: s0.length, int1: s1.length)
	}
	return result
}

private func compare(point0 s0: CGPoint, point1 s1: CGPoint) -> ComparisonResult {
	let result: ComparisonResult
	switch compare(float0: s0.x, float1: s1.x) {
	case .orderedAscending:
		result = .orderedAscending
	case .orderedDescending:
		result = .orderedDescending
	case .orderedSame:
		result = compare(float0: s0.y, float1: s1.y)
	}
	return result
}

private func compare(size0 s0: CGSize, size1 s1: CGSize) -> ComparisonResult {
	let result: ComparisonResult
	switch compare(float0: s0.width, float1: s1.width) {
	case .orderedAscending:
		result = .orderedAscending
	case .orderedDescending:
		result = .orderedDescending
	case .orderedSame:
		result = compare(float0: s0.height, float1: s1.height)
	}
	return result
}

private func compare(rect0 s0: CGRect, rect1 s1: CGRect) -> ComparisonResult {
	let result: ComparisonResult
	switch compare(point0: s0.origin, point1: s1.origin) {
	case .orderedAscending:
		result = .orderedAscending
	case .orderedDescending:
		result = .orderedDescending
	case .orderedSame:
		result = compare(size0: s0.size, size1: s1.size)
	}
	return result
}

private func compare(URL0 s0: URL, URL1 s1: URL) -> ComparisonResult {
	return s0.absoluteString.compare(s1.absoluteString)
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

private func compare(array0 s0: Array<CNNativeValue>, array1 s1: Array<CNNativeValue>) -> ComparisonResult {
	switch compare(int0: s0.count, int1: s1.count) {
	case .orderedAscending:
		return .orderedAscending
	case .orderedDescending:
		return .orderedDescending
	case .orderedSame:
		break
	}
	for i in 0..<s0.count {
		switch CNCompareNativeValue(nativeValue0: s0[i], nativeValue1: s1[i]) {
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

private func compare(dictionary0 s0: Dictionary<String, CNNativeValue>, dictionary1 s1: Dictionary<String, CNNativeValue>) -> ComparisonResult {
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
			switch CNCompareNativeValue(nativeValue0: v0, nativeValue1: v1) {
			case .orderedAscending:
				return .orderedAscending
			case .orderedDescending:
				return .orderedDescending
			case .orderedSame:
				break
			}
		} else {
			CNLog(logLevel: .error, message: "Can not happen (2)", atFunction: #function, inFile: #file)
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

