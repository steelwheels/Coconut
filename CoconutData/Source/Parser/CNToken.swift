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
	case CommentToken(String)

	public func description() -> String {
		let result: String
		switch self {
		case .ReservedWordToken(let val):
			result = "reserved word: \(val)"
		case .SymbolToken(let val):
			result = "symbol: \(val)"
		case .IdentifierToken(let val):
			result = "identifier: \(val)"
		case .BoolToken(let val):
			result = "\(val)"
		case .IntToken(let val):
			result = "\(val)"
		case .UIntToken(let val):
			result = "\(val)"
		case .DoubleToken(let val):
			result = "\(val)"
		case .StringToken(let val):
			result = "\(val)"
		case .TextToken(let val):
			result = "\(val)"
		case .CommentToken(let val):
			result = "\(val)"
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

	public func getNumber() -> NSNumber? {
		let result: NSNumber?
		switch self.type {
		case .DoubleToken(let v):
			result = NSNumber(value: v)
		case .UIntToken(let v):
			result = NSNumber(value: v)
		case .IntToken(let v):
			result = NSNumber(value: v)
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

	public func getComment() -> String? {
		let result: String?
		switch self.type {
		case .CommentToken(let s):
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
			result = "\(val)"
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
		case .CommentToken(let val):
			result = val
		}
		return result
	}
}

public enum CNTokenizeResult {
	case ok(Array<CNToken>)
	case error(NSError)
}

public func CNStringToToken(string srcstr: String, config conf: CNParserConfig) -> CNTokenizeResult
{
	let tokenizer = CNTokenizer(config: conf)
	return tokenizer.tokenize(string: srcstr)
}

public func CNStringStreamToToken(stream srcstrm: CNStringStream, config conf: CNParserConfig) -> CNTokenizeResult
{
	let tokenizer = CNTokenizer(config: conf)
	return tokenizer.tokenize(stream: srcstrm)
}

private class CNTokenizer
{
	var mConfig:		CNParserConfig
	var mCurrentLine:	Int

	public init(config conf: CNParserConfig){
		mConfig		= conf
		mCurrentLine	= 1
	}

	public func tokenize(string srcstr: String) -> CNTokenizeResult {
		do {
			let stream  = CNStringStream(string: srcstr)
			let tokens  = try stringToTokens(stream: stream)
			let mtokens = mergeTokens(tokens: tokens)
			return .ok(mtokens)
		} catch {
			return .error(error as NSError)
		}
	}

	public func tokenize(stream srcstrm: CNStringStream) -> CNTokenizeResult {
		do {
			let tokens = try stringToTokens(stream: srcstrm)
			return .ok(tokens)
		} catch {
			return .error(error as NSError)
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
			} else if c1.isNumber {
				return try getDigitTokenFromStream(stream: srcstream)
			} else if c1.isLetter || c1 == "_" {
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
			} else if c1 == "/" {
				if let c2 = srcstream.peek(offset: 1) {
					if c2 == "/" {
						return getCommentFromStream(stream: srcstream)
					}
				}
				let _ = srcstream.getc() // drop 1st character
				return CNToken(type: .SymbolToken(c1), lineNo: mCurrentLine)
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
			if c.isNumber {
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
				throw NSError.parseError(message: "Double value is expected but \"\(resstr)\" is given", location: #function)
			}
		} else {
			if let value = UInt(resstr, radix: 10) {
				return CNToken(type: .UIntToken(value), lineNo: mCurrentLine)
			} else {
				throw NSError.parseError(message: "Integer value is expected but \"\(resstr)\" is given", location: #function)
			}
		}
	}

	private func getHexTokenFromStream(stream srcstream: CNStringStream) throws -> CNToken {
		let _ = srcstream.gets(count: 2) // drop first "0x"
		let resstr = getAnyStringFromStream(stream: srcstream, matchingFunc: {
			(_ c: Character) -> Bool in
			if c.isHexDigit {
				return true
			} else {
				return false
			}
		})
		if let value = UInt(resstr, radix: 16) {
			return CNToken(type: .UIntToken(value), lineNo: mCurrentLine)
		} else {
			throw NSError.parseError(message: "Hex integer value is expected but \"\(resstr)\" is given at \(mCurrentLine)", location: #function)
		}
	}

	private func getIdentifierTokenFromStream(stream srcstream: CNStringStream) throws -> CNToken {
		let resstr = getAnyStringFromStream(stream: srcstream, matchingFunc: {
			(_ c: Character) -> Bool in
			return c.isLetterOrNumber || c == "_" || (mConfig.allowIdentiferHasPeriod && c == ".")
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
		switch CNStringUtil.removeEscapeForQuote(source: srcstream) {
		case .success(let str):
			return CNToken(type: .StringToken(str), lineNo: mCurrentLine)
		case .failure(let err):
			throw err
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
			throw NSError.parseError(message: "Text value is not ended by %} but \"\(resstr)\" is given at \(mCurrentLine)", location: #function)
		}
	}

	private func getCommentFromStream(stream srcstream: CNStringStream) -> CNToken {
		var idx      		= 2	// contains "//"
		var docont   		= true
		while docont {
			if let c = srcstream.peek(offset: idx) {
				if c == "\n" {
					docont   = false // end of comment
				} else {
					idx += 1
				}
			} else {
				docont = false
			}
		}
		/* get skipped characters */
		let comm = srcstream.gets(count: idx)
		return CNToken(type: .CommentToken(comm), lineNo: mCurrentLine)
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
				if !c.isWhitespace {
					let _ = srcstream.ungetc()
					break
				} else if c.isNewline {
					mCurrentLine += 1
				}
			} else {
				break
			}
		}
	}

	private func mergeTokens(tokens srcs: Array<CNToken>) -> Array<CNToken> {
		var result: Array<CNToken> = []
		let num = srcs.count
		var i   = 0 ;
		while(i < num) {
			let src = srcs[i]
			var doappend = true
			if let sym = src.getSymbol() {
				switch sym {
				case "+", "-":
					if i+1 < num {
						if let next = mergeNumberToken(symbol: sym, token: srcs[i+1]) {
							result.append(next)
							i += 2
							doappend = false
						}
					}
				default:
					break
				}
			} else if let _ = src.getComment() {
				/* Ignore comment */
				doappend = false
				i += 1
			}
			if doappend {
				result.append(src)
				i += 1
			}
		}
		return result
	}

	private func mergeNumberToken(symbol sym: Character, token src: CNToken) -> CNToken? {
		let isminus = (sym == "-")
		if let val = src.getInt() {
			if isminus {
				return CNToken(type: .IntToken(-val), lineNo: src.lineNo)
			} else {
				return CNToken(type: .IntToken( val), lineNo: src.lineNo)
			}
		} else if let val = src.getUInt() {
			if isminus {
				return CNToken(type: .IntToken(-Int(val)), lineNo: src.lineNo)
			} else {
				return src
			}
		} else if let val = src.getDouble() {
			if isminus {
				return CNToken(type: .DoubleToken(-val), lineNo: src.lineNo)
			} else {
				return CNToken(type: .DoubleToken( val), lineNo: src.lineNo)
			}
		} else {
			return nil
		}
	}
}

