/*
 * @file	CNValueType.swift
 * @brief	Define CNValueType class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation


/**
 * The data to present JSValue as native data
 */
public indirect enum CNValueType
{
	case	voidType
	case	anyType
	case	boolType
	case	numberType
	case	stringType
	case	enumType(CNEnumType)				// enum-type
	case	dictionaryType(CNValueType)			// element type
	case	arrayType(CNValueType)				// element type
	case	setType(CNValueType)				// element type
	case	objectType(String?)				// class name or unkown
	case 	interfaceType(CNInterfaceType)			// interface name
	case	functionType(CNValueType, Array<CNValueType>)	// (return-type, parameter-types)

	public static func encode(valueType vtype: CNValueType) -> String {
		return CNValueTypeCoder.encode(valueType: vtype)
	}

	public static func decode(code str: String) -> Result<CNValueType, NSError> {
		return CNValueTypeCoder.decode(code: str)
	}

	public static func compare(type0 t0: CNValueType, type1 t1: CNValueType) -> ComparisonResult {
		let str0 = encode(valueType: t0)
		let str1 = encode(valueType: t1)
		if str0 > str1 {
			return .orderedAscending
		} else if str0 < str1 {
			return .orderedDescending
		} else {
			return .orderedSame
		}
	}
}

private class CNValueTypeCoder
{
	private static let 	VoidTypeIdentifier		= "v"
	private static let	AnyTypeIdentifier		= "y"
	private static let 	BoolTypeIdentifier		= "b"
	private static let	NumberTypeIdentifier		= "n"
	private static let	StringTypeIdentifier		= "s"
	private static let	EnumTypeIdentifier		= "e"
	private static let	DictionaryTypeIdentifier	= "d"
	private static let	ArrayTypeIdentifier		= "a"
	private static let	SetTypeIdentifier		= "t"
	private static let 	RecordTypeIdentifier		= "r"
	private static let	ObjectTypeIdentifier		= "o"
	private static let	FunctionTypeIdentifier		= "f"
	private static let 	InterfaceTypeIdentifier		= "i"

	public static func encode(valueType vtype: CNValueType) -> String {
		let result: String
		switch vtype {
		case .voidType:
			result = VoidTypeIdentifier
		case .anyType:
			result = AnyTypeIdentifier
		case .boolType:
			result = BoolTypeIdentifier
		case .numberType:
			result = NumberTypeIdentifier
		case .stringType:
			result = StringTypeIdentifier
		case .enumType(let etype):
			result = EnumTypeIdentifier + "(" + etype.typeName + ")"
		case .dictionaryType(let elmtype):
			let elmstr = encode(valueType: elmtype)
			result = DictionaryTypeIdentifier + "(" + elmstr + ")"
		case .arrayType(let elmtype):
			let elmstr = encode(valueType: elmtype)
			result = ArrayTypeIdentifier + "(" + elmstr + ")"
		case .setType(let elmtype):
			let elmstr = encode(valueType: elmtype)
			result = SetTypeIdentifier + "(" + elmstr + ")"
		case .objectType(let clsnamep):
			let clsname = clsnamep ?? "-"
			result = ObjectTypeIdentifier + "(" + clsname + ")"
		case .interfaceType(let iftype):
			result = InterfaceTypeIdentifier + "(" + iftype.name + ")"
		case .functionType(let rettype, let paramtypes):
			let retstr   = encode(valueType: rettype)
			let paramstr = paramtypes.map { encode(valueType: $0) }
			result = FunctionTypeIdentifier + "(" + retstr + ",["
				+ paramstr.joined(separator: ",") + "])"
		}
		return result
	}

	public static func decode(code str: String) -> Result<CNValueType, NSError> {
		let conf   = CNParserConfig(allowIdentiferHasPeriod: false)
		switch CNStringToToken(string: str, config: conf) {
		case .ok(let tokens):
			let strm = CNTokenStream(source: tokens)
			return decode(stream: strm)
		case .error(let err):
			return .failure(err)
		}
	}

	public static func decode(stream strm: CNTokenStream) -> Result<CNValueType, NSError> {
		guard let ident = strm.requireIdentifier() else {
			return .failure(NSError.parseError(message: "Type identifier is required"))
		}
		let result: CNValueType
		switch ident {
		case VoidTypeIdentifier:
			result = .voidType
		case AnyTypeIdentifier:
			result = .anyType
		case BoolTypeIdentifier:
			result = .boolType
		case NumberTypeIdentifier:
			result = .numberType
		case StringTypeIdentifier:
			result = .stringType
		case EnumTypeIdentifier:
			switch decodeEnumType(stream: strm) {
			case .success(let etype):
				result = .enumType(etype)
			case .failure(let err):
				return .failure(err)
			}
		case DictionaryTypeIdentifier:
			switch decodeElementType(stream: strm) {
			case .success(let elmtype):
				result = .dictionaryType(elmtype)
			case .failure(let err):
				return .failure(err)
			}
		case ArrayTypeIdentifier:
			switch decodeElementType(stream: strm) {
			case .success(let elmtype):
				result = .arrayType(elmtype)
			case .failure(let err):
				return .failure(err)
			}
		case SetTypeIdentifier:
			switch decodeElementType(stream: strm) {
			case .success(let elmtype):
				result = .setType(elmtype)
			case .failure(let err):
				return .failure(err)
			}
		case ObjectTypeIdentifier:
			switch decodeClassName(stream: strm) {
			case .success(let clsname):
				result = .objectType(clsname)
			case .failure(let err):
				return .failure(err)
			}
		case InterfaceTypeIdentifier:
			switch decodeInterfaceName(stream: strm) {
			case .success(let ifname):
				if let iftype = CNInterfaceTable.currentInterfaceTable().search(byTypeName: ifname) {
					result = .interfaceType(iftype)
				} else {
					return .failure(NSError.parseError(message: "Unknown interface name: \(ident)"))
				}
			case .failure(let err):
				return .failure(err)
			}
		case FunctionTypeIdentifier:
			switch decodeFunctionType(stream: strm) {
			case .success(let (rettype, paramtypes)):
				result = .functionType(rettype, paramtypes)
			case .failure(let err):
				return .failure(err)
			}
		default:
			return .failure(NSError.parseError(message: "Unknown type identifier: \(ident)"))
		}
		return .success(result)
	}

	public static func decodeEnumType(stream strm: CNTokenStream) -> Result<CNEnumType, NSError> {
		guard strm.requireSymbol(symbol: "(") else {
			return .failure(NSError.parseError(message: "\"(\" is required for type declaration"))
		}

		guard let ename = strm.requireIdentifier() else {
			return .failure(NSError.parseError(message: "Enum type name is required"))
		}

		guard strm.requireSymbol(symbol: ")") else {
			return .failure(NSError.parseError(message: "\")\" is required for type declaration"))
		}

		let etable = CNEnumTable.currentEnumTable()
		if let etype = etable.search(byTypeName: ename) {
			return .success(etype)
		} else {
			return .failure(NSError.parseError(message: "Unknown enum type name: \(ename)"))
		}
	}

	public static func decodeElementType(stream strm: CNTokenStream) -> Result<CNValueType, NSError> {
		guard strm.requireSymbol(symbol: "(") else {
			return .failure(NSError.parseError(message: "\"(\" is required for type declaration"))
		}

		let elmtype: CNValueType
		switch decode(stream: strm) {
		case .success(let vtype):
			elmtype = vtype
		case .failure(let err):
			return .failure(err)
		}

		guard strm.requireSymbol(symbol: ")") else {
			return .failure(NSError.parseError(message: "\")\" is required for type declaration"))
		}

		return .success(elmtype)
	}

	public static func decodeClassName(stream strm: CNTokenStream) -> Result<String?, NSError> {
		guard strm.requireSymbol(symbol: "(") else {
			return .failure(NSError.parseError(message: "\"(\" is required for type declaration"))
		}
		let clsname: String?
		if let name = strm.requireIdentifier() {
			clsname = name
		} else {
			clsname = nil
		}
		guard strm.requireSymbol(symbol: ")") else {
			return .failure(NSError.parseError(message: "\")\" is required for type declaration"))
		}
		return .success(clsname)
	}

	public static func decodeInterfaceName(stream strm: CNTokenStream) -> Result<String, NSError> {
		guard strm.requireSymbol(symbol: "(") else {
			return .failure(NSError.parseError(message: "\"(\" is required for type declaration"))
		}
		let ifname: String
		if let name = strm.requireIdentifier() {
			ifname = name
		} else {
			return .failure(NSError.parseError(message: "Identifier is required for interface type"))
		}
		guard strm.requireSymbol(symbol: ")") else {
			return .failure(NSError.parseError(message: "\")\" is required for type declaration"))
		}
		return .success(ifname)
	}

	public static func decodeRecordType(stream strm: CNTokenStream) -> Result<Dictionary<String, CNValueType>, NSError> {
		var result: Dictionary<String, CNValueType> = [:]

		guard strm.requireSymbol(symbol: "[") else {
			return .failure(NSError.parseError(message: "\"[\" is required to begin record type declaration"))
		}

		var is1st  = true
		while true {
			if strm.isEmpty() {
				return .failure(NSError.parseError(message: "Unexpected end of stream while decoding record type"))
			} else if strm.requireSymbol(symbol: "]") {
				break
			}
			if is1st {
				is1st = false
			} else if !strm.requireSymbol(symbol: ",") {
				return .failure(NSError.parseError(message: "\",\" is required between record type declarations"))
			}
			let ename: String
			if let ident = strm.requireIdentifier() {
				ename = ident
			} else {
				return .failure(NSError.parseError(message: "Identifier is required for record type declaration"))
			}
			if !strm.requireSymbol(symbol: ":") {
				return .failure(NSError.parseError(message: "\":\" is required between record identifier and type"))
			}
			let etype: CNValueType
			switch decode(stream: strm) {
			case .success(let type):
				etype = type
			case .failure(let err):
				return .failure(err)
			}
			result[ename] = etype
		}

		return .success(result)
	}

	public static func decodeFunctionType(stream strm: CNTokenStream) -> Result<(CNValueType, Array<CNValueType>), NSError> {
		guard strm.requireSymbol(symbol: "(") else {
			return .failure(NSError.parseError(message: "\"(\" is required for funtion type declaration"))
		}

		let rettype: CNValueType
		switch decode(stream: strm) {
		case .success(let vtype):
			rettype = vtype
		case .failure(let err):
			return .failure(err)
		}

		guard strm.requireSymbol(symbol: ",") else {
			return .failure(NSError.parseError(message: "\",\" is required for function type declaration"))
		}

		guard strm.requireSymbol(symbol: "[") else {
			return .failure(NSError.parseError(message: "\"[\" is required for function type declaration"))
		}

		var paramtypes: Array<CNValueType> = []
		var is1st = true
		while true {
			if strm.isEmpty() {
				return .failure(NSError.parseError(message: "Unterminated function type declaration"))
			}
			if strm.requireSymbol(symbol: "]") {
				break
			}
			if is1st {
				is1st = false
			} else if !strm.requireSymbol(symbol: ",") {
				return .failure(NSError.parseError(message: "\",\" is required for function type declaration"))
			}
			switch decode(stream: strm) {
			case .success(let elmtype):
				paramtypes.append(elmtype)
			case .failure(let err):
				return .failure(err)
			}
		}

		guard strm.requireSymbol(symbol: ")") else {
			return .failure(NSError.parseError(message: "\")\" is required for function type declaration"))
		}

		return .success((rettype, paramtypes))
	}
}

