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
				switch parseObject(tokenStream: CNTokenStream(source: tokens)) {
				case .success(let val):
					let dec = decodeObject(value: val)
					result = .success(dec)
				case .failure(let err):
					result = .failure(err)
				}
			} else {
				result = .failure(NSError.parseError(message: "Unexpected end of stream", location: #function))
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

	private func parseObject(tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		if let c = checkSymbol(in: stream) {
			switch c {
			case "[":
				var result: Array<CNValue> = []
				var is1st = true
				parse_loop: while true {
					if let c = checkSymbol(in: stream) {
						if c == "]" {
							break parse_loop
						} else if !is1st && c == "," {
							/* Continue */
						} else {
							/* Ignore */
							let _ = stream.unget()
						}
					}
					switch parseValue(tokenStream: stream) {
					case .success(let val):
						result.append(val)
					case .failure(let err):
						return .failure(err)
					}
					is1st = false
				}
				return .success(.arrayValue(result))
			case "{":
				var result: Dictionary<String, CNValue> = [:]
				var is1st = true
				parse_loop: while true {
					if let c = checkSymbol(in: stream) {
						if c == "}" {
							break parse_loop
						} else if !is1st && c == "," {
							/* Continue */
						} else {
							/* Ignore */
							let _ = stream.unget()
						}
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
			default:
				return .failure(NSError.parseError(message: "Unexpected symbol \(c)", location: #function))
			}
		}
		if let token = stream.get() {
			return .failure(NSError.parseError(message: "Unexpected token \(token.description) at \(token.lineNo)", location: #function))
		} else {
			return .failure(NSError.parseError(message: "Unexpected end of token", location: #function))
		}
	}

	public func parseArrayValue(tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		var vals: Array<CNValue> = []
		var is1st = true
		parse_loop: while true {
			if let c = checkSymbol(in: stream) {
				if c == "]" {
					break parse_loop
				} else if c == "," && !is1st {
					/* Continue */
				} else  {
					/* ignore */
					let _ = stream.unget()
				}
			}
			switch parseValue(tokenStream: stream) {
			case .success(let val):
				vals.append(val)
			case .failure(let err):
				return .failure(err)
			}
			is1st = false
		}
		return .success(.arrayValue(vals))
	}

	private func parseProperty(tokenStream stream: CNTokenStream) -> Result<Property, NSError> {
		if let ident = checkIdentifier(in: stream) {
			if let err = requireSymbol(symbol: ":", in: stream) {
				return .failure(err)
			} else {
				switch parseValue(tokenStream: stream) {
				case .success(let val):
					return .success(Property(name: ident, value: val))
				case .failure(let err):
					return .failure(err)
				}
			}
		} else {
			return .failure(NSError.parseError(message: "Identifier for property is required"))
		}
	}

	public func parseValue(tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		if let token = stream.get() {
			let result: CNValue
			if let c = token.getSymbol() {
				if c == "[" {
					switch parseArrayValue(tokenStream: stream) {
					case .success(let val):
						result = val
					case .failure(let err):
						return .failure(err)
					}
				} else if c == "{" {
					let _   = stream.unget() // unget for previous "["
					switch parseObject(tokenStream: stream) {
					case .success(let val):
						result = val
					case .failure(let err):
						return .failure(err)
					}
				} else {
					return .failure(NSError.parseError(message: "Unexpected token \(token.description) at \(token.lineNo)", location: #function))
				}
			} else {
				switch token.type {
				case .BoolToken(let value):	result = .numberValue(NSNumber(value: value))
				case .IntToken(let value):	result = .numberValue(NSNumber(value: value))
				case .UIntToken(let value):	result = .numberValue(NSNumber(value: value))
				case .DoubleToken(let value):	result = .numberValue(NSNumber(value: value))
				case .StringToken(let value):	result = .stringValue(value)
				case .TextToken(let value):	result = .stringValue(value)
				case .ReservedWordToken(let rid):
					return .failure(NSError.parseError(message: "Reserved word is not supported: \(rid)", location: #function))
				case .SymbolToken(_):
					return .failure(NSError.parseError(message: "Can not happen (0)", location: #function))
				case .IdentifierToken(let str):
					switch str.lowercased() {
					case "null":
						result = .nullValue
					default:
						return .failure(NSError.parseError(message: "Unknown identifier: \(str)", location: #function))
					}
				case .CommentToken(_):
					return .failure(NSError.parseError(message: "Can not happen (1)", location: #function))
				}
			}
			return .success(result)
		} else {
			return .failure(NSError.parseError(message: "Unexpected end of stream", location: #function))
		}
	}

	private func requireSymbol(symbol sym: Character, in stream: CNTokenStream) -> NSError? {
		if let token = stream.get() {
			if let c = token.getSymbol() {
				if c == sym {
					return nil // No error
				} else {
					return NSError.parseError(message: "Unexpected symbol \(c)", location: #function)
				}
			} else {
				return NSError.parseError(message: "Unexpected token \(token.description) at \(token.lineNo)", location: #function)
			}
		} else {
			return NSError.parseError(message: "Unexpected end of stream", location: #function)
		}
	}

	private func checkSymbol(in stream: CNTokenStream) -> Character? {
		if let token = stream.get() {
			if let c = token.getSymbol() {
				return c
			} else {
				let _ = stream.unget()
				return nil
			}
		} else {
			return nil
		}
	}

	private func checkIdentifier(in stream: CNTokenStream) -> String? {
		if let token = stream.get() {
			if let ident = token.getIdentifier() {
				return ident
			} else {
				let _ = stream.unget()
				return nil
			}
		} else {
			return nil
		}
	}

	private func lineNo(tokenStream stream: CNTokenStream) -> Int {
		if let no = stream.lineNo {
			return no
		} else {
			return 0
		}
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
}

