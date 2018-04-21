/*
 * @file	CNValueUtil.swift
 * @brief	Define utility functions for CNValue
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public func CNTokenToValue(token tkn: CNToken) -> CNValue
{
	let result: CNValue
	switch tkn.type {
	case .ReservedWordToken(let rid):
		result = CNValue(intValue: rid)
	case .SymbolToken(let charval):
		result = CNValue(characterValue: charval)
	case .BoolToken(let boolval):
		result = CNValue(booleanValue: boolval)
	case .IdentifierToken(let identval):
		result = CNValue(stringValue: identval)
	case .UIntToken(let uintval):
		result = CNValue(uIntValue: uintval)
	case .IntToken(let intval):
		result = CNValue(intValue: intval)
	case .DoubleToken(let dblval):
		result = CNValue(doubleValue: dblval)
	case .StringToken(let strval):
		result = CNValue(stringValue: strval)
	case .TextToken(let txtval):
		result = CNValue(stringValue: txtval)
	}
	return result
}

public func CNStringToValue(targetType type: CNValueType, string str: String) -> CNValue?
{
	var result: CNValue? = nil
	switch type {
	case .VoidType:
		break
	case .BooleanType:
		let lstr = str.lowercased()
		if lstr == "true" {
			result = CNValue(booleanValue: true)
		} else if lstr == "false" {
			result = CNValue(booleanValue: false)
		}
	case .CharacterType:
		if let c = str.first {
			result = CNValue(characterValue: c)
		}
	case .IntType:
		if let val = Int(str) {
			result = CNValue(intValue: val)
		}
	case .UIntType:
		if let val = UInt(str) {
			result = CNValue(uIntValue: val)
		}
	case .FloatType:
		if let val = Float(str) {
			result = CNValue(floatValue: val)
		}
	case .DoubleType:
		if let val = Double(str) {
			result = CNValue(doubleValue: val)
		}
	case .StringType:
		result = CNValue(stringValue: str)
	case .DateType:
		if let dval = Double(str) {
			let interval = TimeInterval(dval)
			result = CNValue(dateValue: Date(timeIntervalSince1970: interval))
		}
	case .ArrayType, .DictionaryType:
		NSLog("Not supported yet")
	}
	return result
}

