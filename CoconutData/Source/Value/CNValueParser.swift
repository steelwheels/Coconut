/**
 * @file	CNValueParser.swift
 * @brief	Define CNValueParser class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNValueParser
{
	public struct Property {
		public var 	name	: String
		public var 	value	: CNValue
		public init(name nm: String, value val: CNValue){
			name 	= nm
			value	= val
		}
	}

	public init(){
	}

	public func parse(source src: String) -> Result<CNValue, NSError> {
		/* Remove comments in the string */
		let lines = removeComments(lines: src.components(separatedBy: "\n"))
		let msrc  = lines.joined(separator: "\n")
		/* Get tokens from source text*/
		let conf = CNParserConfig(allowIdentiferHasPeriod: false)
		let result: Result<CNValue, NSError>
		switch CNStringToToken(string: msrc, config: conf) {
		case .ok(let tokens):
			if tokens.count > 0 {
				/* Parse object */
				switch parseValue(tokenStream: CNTokenStream(source: tokens)) {
				case .success(let val):
					let dec = decodeObject(value: val)
					result = .success(dec)
				case .failure(let err):
					result = .failure(err)
				}
			} else {
				result = .failure(NSError.parseError(message: "No contents"))
			}
		case .error(let err):
			result = .failure(err)
		}
		return result
	}

	private func removeComments(lines lns: Array<String>) -> Array<String> {
		var result: Array<String> = []
		for line in lns {
			let parts = line.components(separatedBy: "//")
			result.append(parts[0])
		}
		return result
	}

	private func decodeObject(value src: CNValue) -> CNValue {
		let dst: CNValue
		switch src {
		case .nullValue, .boolValue(_), .numberValue(_), .stringValue(_),
		     .dateValue(_), .rangeValue(_), .pointValue(_), .sizeValue(_),
		     .rectValue(_), .enumValue(_), .URLValue(_), .colorValue(_), .imageValue(_),
		     .recordValue(_), .objectValue(_), .segmentValue(_), .pointerValue(_):
			dst = src
		case .dictionaryValue(let dict):
			if let obj = CNValue.dictionaryToValue(dictionary: dict) {
				dst = obj
			} else {
				var newdict: Dictionary<String, CNValue> = [:]
				for (key, val) in dict {
					newdict[key] = decodeObject(value: val)
				}
				dst = .dictionaryValue(newdict)
			}
		case .arrayValue(let arr):
			var newarr: Array<CNValue> = []
			for elm in arr {
				let newelm = decodeObject(value: elm)
				newarr.append(newelm)
			}
			dst = .arrayValue(newarr)
		}
		return dst
	}

	private func parseValue(tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		if let c = stream.requireSymbol() {
			switch c {
			case "{":
				let _ = stream.unget()
				return parseObjectValue(tokenStream: stream)
			case "[":
				let _ = stream.unget()
				return parseArrayValue(tokenStream: stream)
			default:
				return .failure(NSError.parseError(message: "Unexpected symbol \"\(c)\" \(near(stream))"))
			}
		} else {
			return parseScalarValue(tokenStream: stream)
		}
	}

	private func parseObjectValue(tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		guard stream.requireSymbol() == "{" else {
			return .failure(NSError.parseError(message: "Symbol \"{\" is required \(near(stream))"))
		}
		var result: Dictionary<String, CNValue> = [:]
		var is1st = true
		parse_loop: while true {
			if stream.requireSymbol(symbol: "}") {
				break parse_loop
			}
			if !is1st {
				/* ignore comma (option) */
				let _ = stream.requireSymbol(symbol: ",")
			}
			switch parseProperty(tokenStream: stream) {
			case .success(let prop):
				result[prop.name] = prop.value
			case .failure(let err):
				return .failure(err)
			}
			is1st = false
		}
		return .success(.dictionaryValue(result))
	}

	private func parseArrayValue(tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		guard stream.requireSymbol() == "[" else {
			return .failure(NSError.parseError(message: "Symbol \"{\" is required \(near(stream))"))
		}
		var result: Array<CNValue> = []
		var is1st = true
		parse_loop: while true {
			if stream.requireSymbol(symbol: "]") {
				break parse_loop
			}
			if !is1st {
				/* Ignore comma (option) */
				let _ = stream.requireSymbol(symbol: ",")
			}
			switch parseValue(tokenStream: stream) {
			case .success(let elm):
				result.append(elm)
			case .failure(let err):
				return .failure(err)
			}
			is1st = false
		}
		return .success(.arrayValue(result))
	}

	private func parseProperty(tokenStream stream: CNTokenStream) -> Result<Property, NSError> {
		guard let ident = stream.requireIdentifier() else {
			return .failure(NSError.parseError(message: "Identifier for property name is required \(near(stream))"))
		}
		guard stream.requireSymbol(symbol: ":") else {
			return .failure(NSError.parseError(message: "Symbol \":\" is required between property name and value\(near(stream))"))
		}
		switch parseValue(tokenStream: stream) {
		case .success(let val):
			return .success(Property(name: ident, value: val))
		case .failure(let err):
			return .failure(err)
		}
	}

	private func parseScalarValue(tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		guard let token = stream.get() else {
			return .failure(NSError.parseError(message: "Unexpected end of stream \(near(stream))"))
		}
		let result: CNValue
		switch token.type {
		case .BoolToken(let value):	result = .numberValue(NSNumber(value: value))
		case .IntToken(let value):	result = .numberValue(NSNumber(value: value))
		case .UIntToken(let value):	result = .numberValue(NSNumber(value: value))
		case .DoubleToken(let value):	result = .numberValue(NSNumber(value: value))
		case .StringToken(let value):	result = .stringValue(value)
		case .TextToken(let value):	result = .stringValue(value)
		case .ReservedWordToken(let rid):
			return .failure(NSError.parseError(message: "Reserved word is not supported: \(rid) \(near(stream))"))
		case .SymbolToken(_):
			return .failure(NSError.parseError(message: "Can not happen (0) \(near(stream))"))
		case .IdentifierToken(let str):
			switch str.lowercased() {
			case "null":
				result = .nullValue
			default:
				switch parseEnumValue(typeName: str, tokenStream: stream) {
				case .success(let val):
					result = val
				case .failure(let err):
					return .failure(err)
				}
			}
		case .CommentToken(_):
			return .failure(NSError.parseError(message: "Can not happen \(near(stream))"))
		}
		return .success(result)
	}

	public func parseEnumValue(typeName tname: String, tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		guard let sym = stream.getSymbol() else {
			return .failure(NSError.parseError(message: "\".\" is required after enum type  \(near(stream))"))
		}
		guard sym == "." else {
			return .failure(NSError.parseError(message: "\".\" is required after enum type \(near(stream))"))
		}
		guard let mname = stream.getIdentifier() else {
			return .failure(NSError.parseError(message: "Enum member name is required after \".\" \(near(stream))"))
		}
		return parseEnumValue(typeName: tname, memberName: mname, tokenStream: stream)
	}

	public func parseEnumValue(typeName tnamep: String?, memberName mname: String, tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		let etable = CNEnumTable.currentEnumTable()
		if let tname = tnamep {
			if let val = etable.search(byTypeName: tname, memberName: mname) {
				return .success(CNValue.numberValue(NSNumber(integerLiteral: val)))
			}
			return .failure(NSError.parseError(message: "Enumvalue \(tname).\(mname) is not found \(near(stream))"))
		} else {
			let vals = etable.search(byMemberName: mname)
			switch vals.count {
			case 0:
				return .failure(NSError.parseError(message: "Enum member .\(mname) is not found \(near(stream))"))
			case 1:
				return .success(CNValue.numberValue(NSNumber(integerLiteral: vals[0])))
			default: // 2 or more
				CNLog(logLevel: .error, message: "Enum member .\(mname) is used by multiple enum types \(near(stream))")
				return .success(CNValue.numberValue(NSNumber(integerLiteral: vals[0])))
			}
		}
	}

	private func near(_ strm: CNTokenStream) -> String {
		var result = ""
		if let token = strm.peek(offset: 0) {
			result += ": near \"" + token.toString() + "\""
		}
		if let no = strm.lineNo {
			result += " at line \(no)"
		}
		return result
	}
}

