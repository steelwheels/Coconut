/*
 * @file	CNValue.swift
 * @brief	Define CNValue class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public enum CNValueType {
	case VoidType
	case BooleanType
	case CharacterType
	case IntType
	case UIntType
	case FloatType
	case DoubleType
	case StringType
	case DateType
	case ArrayType
	case DictionaryType

	public var description: String {
		get {
			var result: String
			switch self {
			case .VoidType:		result = "Void"
			case .BooleanType:	result = "Bool"
			case .CharacterType:	result = "Character"
			case .IntType:		result = "Int"
			case .UIntType:		result = "UInt"
			case .FloatType:	result = "Float"
			case .DoubleType:	result = "Double"
			case .StringType:	result = "String"
			case .DateType:		result = "Date"
			case .ArrayType:	result = "Array"
			case .DictionaryType:	result = "Dictionary"
			}
			return result
		}
	}

	public static func decode(typeName name: String) -> CNValueType? {
		var result: CNValueType?
		switch name {
		case "Void":		result = .VoidType
		case "Bool":		result = .BooleanType
		case "Charancter":	result = .CharacterType
		case "Int":		result = .IntType
		case "UInt":		result = .UIntType
		case "Float":		result = .FloatType
		case "Double":		result = .DoubleType
		case "String":		result = .StringType
		case "Date":		result = .DateType
		case "Array":		result = .ArrayType
		case "Dictionary":	result = .DictionaryType
		default:		result = nil
		}
		return result
	}
}

private enum CNValueData {
	case BooleanValue(value: Bool)
	case CharacterValue(value: Character)
	case IntValue(value: Int)
	case UIntValue(value: UInt)
	case FloatValue(value: Float)
	case DoubleValue(value: Double)
	case StringValue(value: String)
	case DateValue(value: Date)
	case ArrayValue(value: Array<CNValue>)
	case DictionaryValue(value: Dictionary<String, CNValue>)

	public var booleanValue: Bool? {
		get {
			switch self {
			case .BooleanValue(let val):	return val
			default:			return nil
			}
		}
	}

	public var characterValue: Character? {
		get {
			switch self {
			case .CharacterValue(let val):	return val
			default:			return nil
			}
		}
	}

	public var intValue: Int? {
		get {
			switch self {
			case .IntValue(let val):	return val
			default:			return nil
			}
		}
	}

	public var uIntValue: UInt? {
		get {
			switch self {
			case .UIntValue(let val):	return val
			default:			return nil
			}
		}
	}

	public var floatValue: Float? {
		get {
			switch self {
			case .FloatValue(let val):	return val
			default:			return nil
			}
		}
	}

	public var doubleValue: Double? {
		get {
			switch self {
			case .DoubleValue(let val):	return val
			default:			return nil
			}
		}
	}

	public var stringValue: String? {
		get {
			switch self {
			case .StringValue(let val):	return val
			default:			return nil
			}
		}
	}

	public var dateValue: Date? {
		get {
			switch self {
			case .DateValue(let val):	return val
			default:			return nil
			}
		}
	}

	public var arrayValue: Array<CNValue>? {
		get {
			switch self {
			case .ArrayValue(let val):	return val
			default:			return nil
			}
		}
	}

	public var dictionaryValue: Dictionary<String, CNValue>? {
		get {
			switch self {
			case .DictionaryValue(let val):	return val
			default:			return nil
			}
		}
	}

	public var hashValue: Int {
		var result	: Int
		let MASK	: Int = 0x00FF_FFFF
		switch self {
		case .BooleanValue(let val):
			result = 0x0100_0000 | (val ? 0x1 : 0x0)
		case .CharacterValue(let val):
			result = 0x0200_0000 | (val.hashValue & MASK)
		case .IntValue(let val):
			result = 0x0300_0000 | (Int(val) & MASK)
		case .UIntValue(let val):
			result = 0x0400_0000 | (Int(val) & MASK)
		case .FloatValue(let val):
			result = 0x0500_0000 | (Int(val * 100.0) & MASK)
		case .DoubleValue(let val):
			result = 0x0600_0000 | (Int(val * 100.0) & MASK)
		case .StringValue(let val):
			result = 0x0700_0000 | (Int(val.lengthOfBytes(using: .utf8)) & MASK)
		case .DateValue(let val):
			result = 0x0800_0000 | (val.hashValue & MASK)
		case .ArrayValue(let val):
			result = 0x0900_0000 | (Int(val.count) & MASK)
		case .DictionaryValue(let val):
			result = 0x0A00_0000 | (Int(val.count) & MASK)
		}
		return result
	}

	public var description: String {
		get {
			var result: String
			switch self {
			case .BooleanValue(let val):	result = "\(val)"
			case .CharacterValue(let val):	result = "\(val)"
			case .IntValue(let val):	result = "\(val)"
			case .UIntValue(let val):	result = "\(val)"
			case .FloatValue(let val):	result = "\(val)"
			case .DoubleValue(let val):	result = "\(val)"
			case .StringValue(let val):	result = "\"" + val + "\""
			case .DateValue(let val):	result = val.description
			case .ArrayValue(let arr):
				var str:String = "["
				var is1st      = true
				for elm in arr {
					if !is1st {
						str = str + ", "
					} else {
						is1st = false
					}
					str = str + elm.description
				}
				result = str + "]"
			case .DictionaryValue(let dict):
				var str:String = "["
				var is1st      = true
				for (key, elm) in dict {
					if !is1st {
						str = str + ", "
					} else {
						is1st = false
					}
					str = str + key + ":" + elm.description
				}
				result = str + "]"
			}
			return result
		}
	}
}

public class CNValue: NSObject, Comparable
{
	private var mType: CNValueType
	private var mData: CNValueData

	public var type: CNValueType {
		get { return mType }
	}

	public init(booleanValue val: Bool){
		mType = .BooleanType
		mData = .BooleanValue(value: val)
	}

	public init(characterValue val: Character){
		mType = .CharacterType
		mData = .CharacterValue(value: val)
	}

	public init(intValue val: Int){
		mType = .IntType
		mData = .IntValue(value: val)
	}

	public init(uIntValue val: UInt){
		mType = .UIntType
		mData = .UIntValue(value: val)
	}

	public init(floatValue val: Float){
		mType = .FloatType
		mData = .FloatValue(value: val)
	}

	public init(doubleValue val: Double){
		mType = .DoubleType
		mData = .DoubleValue(value: val)
	}

	public init(stringValue val: String){
		mType = .StringType
		mData = .StringValue(value: val)
	}

	public init(dateValue val: Date){
		mType = .DateType
		mData = .DateValue(value: val)
	}

	public init(arrayValue val: Array<CNValue>){
		mType = .ArrayType
		mData = .ArrayValue(value: val)
	}

	public init(dictionaryValue val: Dictionary<String, CNValue>){
		mType = .DictionaryType
		mData = .DictionaryValue(value: val)
	}

	public var booleanValue: Bool?		{ return mData.booleanValue }
	public var characterValue: Character?	{ return mData.characterValue }
	public var intValue: Int?		{ return mData.intValue }
	public var uIntValue: UInt?		{ return mData.uIntValue }
	public var floatValue: Float?		{ return mData.floatValue }
	public var doubleValue: Double?		{ return mData.doubleValue }
	public var stringValue: String?		{ return mData.stringValue }
	public var dateValue: Date?		{ return mData.dateValue }
	public var arrayValue: Array<CNValue>?	{ return mData.arrayValue }
	public var dictionaryValue: Dictionary<String, CNValue>?
						{ return mData.dictionaryValue }
	public override var description: String {
		get { return mData.description }
	}

	public var typeDescription: String {
		get { return mType.description }
	}

	public func cast(to dsttype: CNValueType) -> CNValue? {
		switch dsttype {
		case .BooleanType:
			switch type {
			case .BooleanType:
				return self
			default:
				return nil
			}
		case .CharacterType:
			switch type {
			case .CharacterType:
				return self
			case .StringType:
				if let str = stringValue {
					if str.count == 1 {
						if let c = str.first {
							return CNValue(characterValue: c)
						}
					}
				}
				return nil
			default:
				return nil
			}
		case .IntType:
			switch type {
			case .IntType:
				return self
			case .UIntType:
				return CNValue(intValue: Int(uIntValue!))
			case .FloatType:
				return CNValue(intValue: Int(floatValue!))
			case .DoubleType:
				return CNValue(intValue: Int(doubleValue!))
			default:
				return nil
			}
		case .UIntType:
			switch type {
			case .IntType:
				return CNValue(uIntValue: UInt(intValue!))
			case .UIntType:
				return self
			case .FloatType:
				return CNValue(uIntValue: UInt(floatValue!))
			case .DoubleType:
				return CNValue(uIntValue: UInt(doubleValue!))
			default:
				return nil
			}
		case .FloatType:
			switch type {
			case .IntType:
				return CNValue(floatValue: Float(intValue!))
			case .UIntType:
				return CNValue(floatValue: Float(uIntValue!))
			case .FloatType:
				return self
			case .DoubleType:
				return CNValue(floatValue: Float(doubleValue!))
			default:
				return nil
			}
		case .DoubleType:
			switch type {
			case .IntType:
				return CNValue(doubleValue: Double(intValue!))
			case .UIntType:
				return CNValue(doubleValue: Double(uIntValue!))
			case .FloatType:
				return CNValue(doubleValue: Double(floatValue!))
			case .DoubleType:
				return self
			default:
				return nil
			}
		case .StringType:
			return CNValue(stringValue: description)
		case .DateType:
			switch type {
			case .DateType:
				return self
			default:
				return nil
			}
		case .ArrayType:
			switch type {
			case .ArrayType:
				return self
			default:
				return nil
			}
		case .DictionaryType:
			switch type {
			case .DictionaryType:
				return self
			default:
				return nil
			}
		case .VoidType:
			switch type {
			case .VoidType:
				return self
			default:
				return nil
			}
		}
	}

	static public func < (_ lhs: CNValue, _ rhs: CNValue) -> Bool {
		return compareValue(lhs, rhs) == .orderedAscending
	}

	static public func == (_ lhs: CNValue, _ rhs: CNValue) -> Bool {
		return compareValue(lhs, rhs) == .orderedSame
	}

	static private func compareValue(_ lhs: CNValue, _ rhs: CNValue) -> ComparisonResult {
		if lhs.type == rhs.type {
			var result: ComparisonResult
			switch lhs.type {
			case .BooleanType:
				let v0 = lhs.booleanValue! ? 1 : 0
				let v1 = rhs.booleanValue! ? 1 : 0
				result = compareElement(v0, v1)
			case .CharacterType:
				result = compareElement(lhs.characterValue!, rhs.characterValue!)
			case .IntType:
				result = compareElement(lhs.intValue!, rhs.intValue!)
			case .UIntType:
				result = compareElement(lhs.uIntValue!, rhs.uIntValue!)
			case .FloatType:
				result = compareElement(lhs.floatValue!, rhs.floatValue!)
			case .DoubleType:
				result = compareElement(lhs.doubleValue!, rhs.doubleValue!)
			case .StringType:
				result = compareElement(lhs.stringValue!, rhs.stringValue!)
			case .DateType:
				result = compareElement(lhs.dateValue!, rhs.dateValue!)
			case .ArrayType:
				result = compareArray(lhs.arrayValue!, rhs.arrayValue!)
			case .DictionaryType:
				result = compareDictionary(lhs.dictionaryValue!, rhs.dictionaryValue!)
			case .VoidType:
				result = .orderedSame
			}
			return result
		} else {
			let res = compareElement(lhs.type.description, rhs.type.description)
			assert(res != .orderedSame)
			return res
		}
	}

	static private func compareArray(_ s0: Array<CNValue>, _ s1: Array<CNValue>) -> ComparisonResult {
		let count0 = s0.count
		let count1 = s1.count
		if count0 == count1 {
			for i in 0..<count0 {
				let eres = compareValue(s0[i], s1[i])
				if eres != .orderedSame {
					return eres
				}
			}
			return .orderedSame
		} else {
			return compareElement(count0, count1)
		}
	}

	static private func compareSet(_ s0: Set<CNValue>, _ s1: Set<CNValue>) -> ComparisonResult {
		let count0 = s0.count
		let count1 = s1.count
		if count0 == count1 {
			let a0 = s0.sorted()
			let a1 = s1.sorted()
			return compareArray(a0, a1)
		} else {
			return compareElement(count0, count1)
		}
	}

	static private func compareDictionary(_ s0: Dictionary<String, CNValue>, _ s1: Dictionary<String, CNValue>) -> ComparisonResult {
		let keys0 = Array<String>(s0.keys)
		let keys1 = Array<String>(s1.keys)
		if keys0.count == keys1.count {
			let sorted0 = keys0.sorted()
			let sorted1 = keys1.sorted()
			let resA = compareSortedArray(sorted0, sorted1)
			if resA == .orderedSame {
				/* Keys are same */
				for key in sorted0 {
					let val0 = s0[key]
					let val1 = s1[key]
					let resB = compareValue(val0!, val1!)
					if resB != .orderedSame {
						return resB
					}
				}
				return .orderedSame
			} else {
				return resA
			}
		} else {
			return compareElement(keys0.count, keys1.count)
		}
	}

	static private func compareSortedArray(_ s0: Array<String>, _ s1: Array<String>) -> ComparisonResult {
		let count0 = s0.count
		let count1 = s1.count
		if count0 == count1 {
			for i in 0..<count0 {
				let resA = compareElement(s0[i], s1[i])
				if resA != .orderedSame {
					return resA
				}
			}
			return .orderedSame
		} else {
			return compareElement(count0, count1)
		}
	}

	static private func compareElement<T:Comparable>(_ s0: T, _ s1: T) -> ComparisonResult {
		if s0 < s1 {
			return .orderedAscending
		} else if s0 > s1 {
			return .orderedDescending
		} else {
			return .orderedSame
		}
	}
}


