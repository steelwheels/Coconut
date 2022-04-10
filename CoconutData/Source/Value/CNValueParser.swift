/**
 * @file	CNValueParser.swift
 * @brief	Define CNValueParser class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNValueParser
{
	public enum Result {
		case ok(CNValue)
		case error(NSError)
	}

	public init(){
	}

	public func parse(source src: String) -> Result {
		/* Remove comments in the string */
		let lines = removeComments(lines: src.components(separatedBy: "\n"))
		let msrc  = lines.joined(separator: "\n")
		/* Get tokens from source text*/
		let conf = CNParserConfig(allowIdentiferHasPeriod: false)
		let result: Result
		switch CNStringToToken(string: msrc, config: conf) {
		case .ok(let tokens):
			do {
				if tokens.count > 0 {
					/* Parse object */
					let obj = try parseObject(tokenStream: CNTokenStream(source: tokens))
					let dec = decodeObject(value: obj)
					result = .ok(dec)
				} else {
					result = .error(NSError.parseError(message: "Unexpected end of stream", location: #function))
				}
			} catch let err as NSError {
				result = .error(err)
			} catch {
				result = .error(NSError.parseError(message: "Unknown error", location: #function))
			}
		case .error(let err):
			result = .error(err)
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

	private func parseObject(tokenStream stream: CNTokenStream) throws -> CNValue {
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
					let val = try parseValue(tokenStream: stream)
					result.append(val)
					is1st = false
				}
				return .arrayValue(result)
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
					if let (ident, val) = try parseProperty(tokenStream: stream) {
						result[ident] = val
					} else {
						break parse_loop
					}
					is1st = false
				}
				return .dictionaryValue(result)
			default:
				break
			}
		}
		if let token = stream.get() {
			throw NSError.parseError(message: "Unexpected token \(token.description) at \(token.lineNo)", location: #function)
		} else {
			throw NSError.parseError(message: "Unexpected end of token", location: #function)
		}
	}

	private func parseProperty(tokenStream stream: CNTokenStream) throws -> (String, CNValue)? {
		if let ident = checkIdentifier(in: stream) {
			try requireSymbol(symbol: ":", in: stream)
			let value = try parseValue(tokenStream: stream)
			return (ident, value)
		}
		return nil
	}

	public func parseValue(tokenStream stream: CNTokenStream) throws -> CNValue {
		if let token = stream.get() {
			let result: CNValue
			if let c = token.getSymbol() {
				if c == "[" {
					result = try parseArrayValue(tokenStream: stream)
				} else if c == "{" {
					let _   = stream.unget()
					result = try parseObject(tokenStream: stream)
				} else {
					throw NSError.parseError(message: "Unexpected token \(token.description) at \(token.lineNo)", location: #function)
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
					throw NSError.parseError(message: "Reserved word is not supported: \(rid)", location: #function)
				case .SymbolToken(_):
					throw NSError.parseError(message: "Can not happen (0)", location: #function)
				case .IdentifierToken(let str):
					switch str.lowercased() {
					case "null":
						result = .nullValue
					default:
						throw NSError.parseError(message: "Unknown identifier: \(str)", location: #function)
					}
				case .CommentToken(_):
					throw NSError.parseError(message: "Can not happen (1)", location: #function)
				}
			}
			return result
		} else {
			throw NSError.parseError(message: "Unexpected end of stream", location: #function)
		}
	}

	public func parseArrayValue(tokenStream stream: CNTokenStream) throws -> CNValue {
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
			let val = try parseValue(tokenStream: stream)
			vals.append(val)
			is1st = false
		}
		return .arrayValue(vals)
	}

	private func requireSymbol(symbol sym: Character, in stream: CNTokenStream) throws {
		if let token = stream.get() {
			if let c = token.getSymbol() {
				if c != sym {
					throw NSError.parseError(message: "Unexpected symbol \(c)", location: #function)
				}
			} else {
				throw NSError.parseError(message: "Unexpected token \(token.description) at \(token.lineNo)", location: #function)
			}
		} else {
			throw NSError.parseError(message: "Unexpected end of stream", location: #function)
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

