/**
 * @file	CNToken.swift
 * @brief	Define CNToken class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public enum CNTokenType {
	case ReservedWordToken(Int)
	case SymbolToken(Character)
	case IdentifierToken(String)
	case BoolToken(Bool)
	case UIntToken(UInt)
	case IntToken(Int)
	case DoubleToken(Double)
	case StringToken(String)
	case TextToken(String)

	public func description() -> String {
		let result: String
		switch self {
		case .ReservedWordToken(let val):
			result = "ReservedWord(\(val))"
		case .SymbolToken(let val):
			result = "SymbolToken(\(val))"
		case .IdentifierToken(let val):
			result = "IdentifierToken(\(val))"
		case .BoolToken(let val):
			result = "BoolToken(\(val))"
		case .IntToken(let val):
			result = "IntToken(\(val))"
		case .UIntToken(let val):
			result = "UIntToken(\(val))"
		case .DoubleToken(let val):
			result = "DoubleToken(\(val))"
		case .StringToken(let val):
			result = "StringToken(\(val))"
		case .TextToken(let val):
			result = "TextToken(\(val))"
		}
		return result
	}
}

public struct CNToken {
	private var mType:	CNTokenType
	private var mLineNo:	Int

	public init(type t: CNTokenType, lineNo no: Int){
		mType   = t
		mLineNo = no
	}

	public var type: CNTokenType { return mType }
	public var lineNo: Int { return mLineNo }

	public var description: String {
		return mType.description()
	}

	public func getReservedWord() -> Int? {
		let result: Int?
		switch self.type {
		case .ReservedWordToken(let val):
			result = val
		default:
			result = nil
		}
		return result
	}

	public func getSymbol() -> Character? {
		let result: Character?
		switch self.type {
		case .SymbolToken(let c):
			result = c
		default:
			result = nil
		}
		return result
	}

	public func getIdentifier() -> String? {
		let result: String?
		switch self.type {
		case .IdentifierToken(let s):
			result = s
		default:
			result = nil
		}
		return result
	}

	public func getBool() -> Bool? {
		let result: Bool?
		switch self.type {
		case .BoolToken(let v):
			result = v
		default:
			result = nil
		}
		return result
	}

	public func getInt() -> Int? {
		let result: Int?
		switch self.type {
		case .IntToken(let v):
			result = v
		default:
			result = nil
		}
		return result
	}

	public func getUInt() -> UInt? {
		let result: UInt?
		switch self.type {
		case .UIntToken(let v):
			result = v
		default:
			result = nil
		}
		return result
	}

	public func getDouble() -> Double? {
		let result: Double?
		switch self.type {
		case .DoubleToken(let v):
			result = v
		default:
			result = nil
		}
		return result
	}

	public func getString() -> String? {
		let result: String?
		switch self.type {
		case .StringToken(let s):
			result = s
		default:
			result = nil
		}
		return result
	}

	public func getText() -> String? {
		let result: String?
		switch self.type {
		case .TextToken(let s):
			result = s
		default:
			result = nil
		}
		return result
	}

	public func toString() -> String {
		let result: String
		switch self.type {
		case .ReservedWordToken(let val):
			result = "rword(\(val))"
		case .SymbolToken(let val):
			result = "\(val)"
		case .IdentifierToken(let val):
			result = "\(val)"
		case .BoolToken(let val):
			if val { result = "true" } else { result = "false" }
		case .IntToken(let val):
			result = "\(val)"
		case .UIntToken(let val):
			result = "\(val)"
		case .DoubleToken(let val):
			result = "\(val)"
		case .StringToken(let val):
			result = val
		case .TextToken(let val):
			result = val
		}
		return result
	}

	public func toValue() -> CNValue? {
		var result: CNValue?
		switch self.type {
		case .ReservedWordToken(_):
			result = nil
		case .SymbolToken(let val):
			result = CNValue(characterValue: val)
		case .IdentifierToken(_):
			result = nil
		case .BoolToken(let val):
			result = CNValue(booleanValue: val)
		case .UIntToken(let val):
			result = CNValue(uIntValue: val)
		case .IntToken(let val):
			result = CNValue(intValue: val)
		case .DoubleToken(let val):
			result = CNValue(doubleValue: val)
		case .StringToken(let val):
			result = CNValue(stringValue: val)
		case .TextToken(let val):
			result = CNValue(stringValue: val)
		}
		return result
	}
}

public func CNStringToToken(string srcstr: String) -> (CNParseError, Array<CNToken>)
{
	let tokenizer = CNTokenizer()
	return tokenizer.tokenize(string: srcstr)
}

private class CNTokenizer
{
	var mCurrentLine: Int

	public init(){
		mCurrentLine = 1
	}

	public func tokenize(string srcstr: String) -> (CNParseError, Array<CNToken>) {
		do {
			let stream = CNStringStream(string: srcstr)
			let tokens = try stringToTokens(stream: stream)
			return (.NoError, tokens)
		} catch let error {
			if let tkerr = error as? CNParseError {
				return (tkerr, [])
			} else {
				fatalError("Unknown error")
			}
		}
	}

	private func stringToTokens(stream srcstream: CNStringStream) throws -> Array<CNToken> {
		mCurrentLine = 1
		var result : Array<CNToken> = []
		while true {
			skipSpaces(stream: srcstream)
			if srcstream.isEmpty() {
				break
			}
			let token = try getTokenFromStream(stream: srcstream)
			result.append(token)
		}
		return result
	}

	private func getTokenFromStream(stream srcstream: CNStringStream) throws -> CNToken {
		if let c1 = srcstream.peek(offset: 0) {
			if c1 == "0" {
				if let c2 = srcstream.peek(offset: 1) {
					switch c2 {
					case ".":
						return try getDigitTokenFromStream(stream: srcstream)
					case "x", "X":
						return try getHexTokenFromStream(stream: srcstream)
					default:
						let _ = srcstream.getc() // drop 1st character
						return CNToken(type: .UIntToken(0), lineNo: mCurrentLine)
					}
				} else {
					let _ = srcstream.getc() // drop 1st character
					return CNToken(type: .UIntToken(0), lineNo: mCurrentLine)
				}
			} else if c1.isDigit() {
				return try getDigitTokenFromStream(stream: srcstream)
			} else if c1.isAlpha() || c1 == "_" {
				return try getIdentifierTokenFromStream(stream: srcstream)
			} else if c1 == "\"" {
				return try getStringTokenFromStream(stream: srcstream)
			} else if c1 == "%" {
				if let c2 = srcstream.peek(offset: 1) {
					switch c2 {
					case "{":
						return try getTextTokenFromStream(stream: srcstream)
					default:
						let _ = srcstream.getc() // drop 1st character
						return CNToken(type: .SymbolToken(c1), lineNo: mCurrentLine)
					}
				} else {
					let _ = srcstream.getc() // drop 1st character
					return CNToken(type: .SymbolToken(c1), lineNo: mCurrentLine)
				}
			} else {
				let _ = srcstream.getc() // drop 1st character
				return CNToken(type: .SymbolToken(c1), lineNo: mCurrentLine)
			}
		} else {
			fatalError("Can not reach here: srcrange=\(srcstream.description)")
		}
	}

	private func getDigitTokenFromStream(stream srcstream: CNStringStream) throws -> CNToken {
		var hasperiod = false
		let resstr = getAnyStringFromStream(stream: srcstream, matchingFunc: {
			(_ c: Character) -> Bool in
			if c.isDigit() {
				return true
			} else if c == "." {
				hasperiod = true
				return true
			} else {
				return false
			}
		})
		if hasperiod {
			if let value = Double(resstr) {
				return CNToken(type:.DoubleToken(value), lineNo: mCurrentLine)
			} else {
				throw CNParseError.TokenizeError(mCurrentLine, "Double value is expected but \"\(resstr)\" is given")
			}
		} else {
			if let value = UInt(resstr, radix: 10) {
				return CNToken(type: .UIntToken(value), lineNo: mCurrentLine)
			} else {
				throw CNParseError.TokenizeError(mCurrentLine, "Integer value is expected but \"\(resstr)\" is given")
			}
		}
	}

	private func getHexTokenFromStream(stream srcstream: CNStringStream) throws -> CNToken {
		let _ = srcstream.gets(count: 2) // drop first "0x"
		let resstr = getAnyStringFromStream(stream: srcstream, matchingFunc: {
			(_ c: Character) -> Bool in
			if c.isHex() {
				return true
			} else {
				return false
			}
		})
		if let value = UInt(resstr, radix: 16) {
			return CNToken(type: .UIntToken(value), lineNo: mCurrentLine)
		} else {
			throw CNParseError.TokenizeError(mCurrentLine, "Hex integer value is expected but \"\(resstr)\" is given")
		}
	}

	private func getIdentifierTokenFromStream(stream srcstream: CNStringStream) throws -> CNToken {
		let resstr = getAnyStringFromStream(stream: srcstream, matchingFunc: {
			(_ c: Character) -> Bool in
			return c.isAlphaOrNum() || c == "_"
		})
		let lresstr = resstr.lowercased()
		if lresstr == "true"{
			return CNToken(type: .BoolToken(true), lineNo: mCurrentLine)
		} else if lresstr == "false" {
			return CNToken(type: .BoolToken(false), lineNo: mCurrentLine)
		} else {
			return CNToken(type: .IdentifierToken(resstr), lineNo: mCurrentLine)
		}
	}

	private func getStringTokenFromStream(stream srcstream: CNStringStream) throws -> CNToken {
		let _ = srcstream.getc() // drop first "
		var prevprevchar: Character? = nil
		var prevchar:     Character? = nil
		var hasquot		     = false
		let resstr = getAnyStringFromStream(stream: srcstream, matchingFunc: {
			(_ c: Character) -> Bool in
			if c == "\"" {
				let hasescape = (prevprevchar != "\\" && prevchar == "\\")
				if !hasescape {
					hasquot = true
					return false
				}
			}
			prevprevchar = prevchar
			prevchar     = c
			return true
		})
		if hasquot {
			let _ = srcstream.getc() // drop last "
			return CNToken(type: .StringToken(resstr), lineNo: mCurrentLine)
		} else {
			throw CNParseError.TokenizeError(mCurrentLine, "String value is not ended by \" but \"\(resstr)\" is given")
		}
	}

	private func getTextTokenFromStream(stream srcstream: CNStringStream) throws -> CNToken {
		let _ = srcstream.gets(count: 2) // drop first %{
		var prevchar	: Character? = nil
		var haspercent	= false
		let resstr = getAnyStringFromStream(stream: srcstream, matchingFunc: {
			(_ c: Character) -> Bool in
			if prevchar == "%" && c == "}" {
				haspercent = true
				return false
			}
			prevchar = c
			return true
		})
		if haspercent {
			/* Delete last "%" */
			let sidx = resstr.startIndex
			let eidx = resstr.index(before: resstr.endIndex)
			let substr = resstr[sidx..<eidx]

			let _ = srcstream.getc() // drop last %
			return CNToken(type: .TextToken(String(substr)), lineNo: mCurrentLine)
		} else {
			throw CNParseError.TokenizeError(mCurrentLine, "Text value is not ended by %} but \"\(resstr)\" is given")
		}
	}

	private func getAnyStringFromStream(stream srcstream: CNStringStream, matchingFunc matchfunc: (_ c:Character) -> Bool) -> String {
		var result: String = ""
		while true {
			if let c = srcstream.getc() {
				if matchfunc(c) {
					result.append(c)
				} else {
					let _ = srcstream.ungetc()
					break
				}
			} else {
				break
			}
		}
		return result
	}

	private func skipSpaces(stream srcstream: CNStringStream)
	{
		while true {
			if let c = srcstream.getc() {
				if !c.isSpace() {
					let _ = srcstream.ungetc()
					break
				} else if c == "\n" {
					mCurrentLine += 1
				}
			} else {
				break
			}
		}
	}
}

