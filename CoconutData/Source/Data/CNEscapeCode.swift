/**
 * @file	CNEscapeCode.swift
 * @brief	Define CNEscapeCode type
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

/* Reference
 *  - https://seiai.ed.jp/sys/text/java/utf8table.html (Japanese)
 *  - https://ttssh2.osdn.jp/manual/ja/about/ctrlseq.html (Japanese)
 *  - http://man7.org/linux/man-pages/man4/console_codes.4.html
 */
private let BS:		Character		= "\u{08}"	// BS
private let TAB:	Character		= "\u{09}"	// HT
private let NEWLINE1:	Character		= "\u{0a}"	// LF
private let NEWLINE2:	Character		= "\u{0d}"	// CR
private let ESC:	Character		= "\u{1b}"	// ESC
private let DEL:	Character		= "\u{7f}"	// DEL


/* Reference:
 *  - https://en.wikipedia.org/wiki/ANSI_escape_code
 *  - https://qiita.com/PruneMazui/items/8a023347772620025ad6
 */
public enum CNEscapeCode {
	case	string(String)
	case	newline
	case	tab
	case	backspace
	case 	cursorUp(Int)
	case 	cursorDown(Int)
	case	cursorForward(Int)
	case	cursorBack(Int)
	case	cursorNextLine(Int)
	case	cursorPreviousLine(Int)
	case	cursorHolizontalAbsolute(Int)		/* (Column)		*/
	case	cursorPoisition(Int, Int)		/* (Row, Column)	*/
	case	eraceFromCursorToEnd
	case 	eraceFromCursorToBegin
	case	eraceFromBeginToEnd
	case	eraceEntireBuffer

	public func description() -> String {
		var result: String
		switch self {
		case .string(let str):				result = "string(\"\(str)\")"
		case .newline:					result = "newline"
		case .tab:					result = "tab"
		case .backspace:				result = "backspace"
		case .cursorUp(let n):				result = "cursorUp(\(n))"
		case .cursorDown(let n):			result = "cursorDown(\(n))"
		case .cursorForward(let n):			result = "cursorForward(\(n))"
		case .cursorBack(let n):			result = "cursorBack(\(n))"
		case .cursorNextLine(let n):			result = "cursorNextLine(\(n))"
		case .cursorPreviousLine(let n):		result = "cursorPreviousLine(\(n))"
		case .cursorHolizontalAbsolute(let pos):	result = "cursorHolizontalAbsolute(\(pos))"
		case .cursorPoisition(let row, let col):	result = "cursorPoisition(\(row),\(col))"
		case .eraceFromCursorToEnd:			result = "eraceFromCursorToEnd"
		case .eraceFromCursorToBegin:			result = "eraceFromCursorToBegin"
		case .eraceFromBeginToEnd:			result = "eraceFromBeginToEnd"
		case .eraceEntireBuffer:			result = "eraceEntireBuffer"
		}
		return result
	}

	public func encode() -> String {
		var result: String
		switch self {
		case .string(let str):				result = str
		case .newline:					result = String(NEWLINE2)
		case .tab:					result = String(TAB)
		case .backspace:				result = String(BS)
		case .cursorUp(let n):				result = "\(ESC)[\(n)A"
		case .cursorDown(let n):			result = "\(ESC)[\(n)B"
		case .cursorForward(let n):			result = "\(ESC)[\(n)C"
		case .cursorBack(let n):			result = "\(ESC)[\(n)D"
		case .cursorNextLine(let n):			result = "\(ESC)[\(n)E"
		case .cursorPreviousLine(let n):		result = "\(ESC)[\(n)F"
		case .cursorHolizontalAbsolute(let n):		result = "\(ESC)[\(n)G"
		case .cursorPoisition(let row, let col):	result = "\(ESC)[\(row),\(col)H"
		case .eraceFromCursorToEnd:			result = "\(ESC)[0J"
		case .eraceFromCursorToBegin:			result = "\(ESC)[1J"
		case .eraceFromBeginToEnd:			result = "\(ESC)[2J"
		case .eraceEntireBuffer:			result = "\(ESC)[3J"
		}
		return result
	}

	public func compare(code src: CNEscapeCode) -> Bool {
		var result = false
		switch self {
		case .string(let s0):
			switch src {
			case .string(let s1):			result = (s0 == s1)
			default:				break
			}
		case .newline:
			switch src {
			case .newline:				result = true
			default:				break
			}
		case .tab:
			switch src {
			case .tab:				result = true
			default:				break
			}
		case .backspace:
			switch src {
			case .backspace:			result = true
			default:				break
			}
		case .cursorUp(let n0):
			switch src {
			case .cursorUp(let n1):			result = (n0 == n1)
			default:				break
			}
		case .cursorDown(let n0):
			switch src {
			case .cursorDown(let n1):		result = (n0 == n1)
			default:				break
			}
		case .cursorForward(let n0):
			switch src {
			case .cursorForward(let n1):		result = (n0 == n1)
			default:				break
			}
		case .cursorBack(let n0):
			switch src {
			case .cursorBack(let n1):		result = (n0 == n1)
			default:				break
			}
		case .cursorNextLine(let n0):
			switch src {
			case .cursorNextLine(let n1):		result = (n0 == n1)
			default:				break
			}
		case .cursorPreviousLine(let n0):
			switch src {
			case .cursorPreviousLine(let n1):	result = (n0 == n1)
			default:				break
			}
		case .cursorHolizontalAbsolute(let n0):
			switch src {
			case .cursorHolizontalAbsolute(let n1):	result = (n0 == n1)
			default:				break
			}
		case .cursorPoisition(let n0, let m0):
			switch src {
			case .cursorPoisition(let n1, let m1):	result = (n0 == n1) && (m0 == m1)
			default:				break
			}
		case .eraceFromCursorToEnd:
			switch src {
			case .eraceFromCursorToEnd:		result = true
			default:				break
			}
		case .eraceFromCursorToBegin:
			switch src {
			case .eraceFromCursorToBegin:		result = true
			default:				break
			}
		case .eraceFromBeginToEnd:
			switch src {
			case .eraceFromBeginToEnd:		result = true
			default:				break
			}
		case .eraceEntireBuffer:
			switch src {
			case .eraceEntireBuffer:		result = true
			default:				break
			}
		}
		return result
	}

	public enum DecodeError: Error {
		case unknownError
		case incompletedSequence
		case unexpectedCharacter(Character)
		case unknownCommand(Character)		// command
		case invalidParameter(Character, Int)	// command, parameter

		public func description() -> String {
			let result: String
			switch self {
			case .unknownError:			result = "Unknown error"
			case .incompletedSequence:		result = "Incomplete sequence"
			case .unexpectedCharacter(let c):	result = "Unexpected character: \(c)"
			case .unknownCommand(let c):		result = "Unknown command: \(c)"
			case .invalidParameter(let c, let p):	result = "Invalid code: \(c), parameter: \(p)"
			}
			return result
		}
	}

	public enum DecodeResult {
		case	ok(Array<CNEscapeCode>)
		case	error(DecodeError)
	}

	public static func decode(string src: String) -> DecodeResult {
		do {
			let result = try decodeString(string: src)
			return .ok(result)
		} catch let err as DecodeError {
			return .error(err)
		} catch {
			return .error(.unknownError)
		}
	}

	private static func decodeString(string src: String) throws -> Array<CNEscapeCode> {
		var result: Array<CNEscapeCode> = []
		var idx    = src.startIndex
		let end    = src.endIndex
		var substr = ""
		while  idx < end {
			let (c0, idx0) = try nextChar(string: src, index: idx)
			switch c0 {
			case ESC:
				let (c1, idx1) = try nextChar(string: src, index: idx0)
				switch c1 {
				case "[":
					/* Save current sub string */
					if substr.count > 0 {
						result.append(CNEscapeCode.string(substr))
						substr = ""
					}
					/* Decode escape sequence */
					let (idx2, command2) = try decodeEscapeSequence(string: src, index: idx1)
					result.append(command2)
					idx = idx2
				default:
					substr.append(c0)
					substr.append(c1)
					idx = idx1
				}
			case NEWLINE1, NEWLINE2:
				result.append(.newline)
				idx = idx0
			case TAB:
				result.append(.tab)
				idx = idx0
			case BS, DEL:
				result.append(.backspace)
				idx = idx0
			default:
				substr.append(c0)
				idx = idx0
			}
		}
		/* Unsaved string */
		if substr.count > 0 {
			result.append(CNEscapeCode.string(substr))
			substr = ""
		}
		return result
	}

	private static func decodeEscapeSequence(string src: String, index idx: String.Index) throws -> (String.Index, CNEscapeCode) {
		let (idx1, tokens) = try decodeStringToTokens(string: src, index: idx)
		let tokennum       = tokens.count
		if tokennum == 0 {
			throw DecodeError.incompletedSequence
		}

		let result : CNEscapeCode
		let lasttoken	= tokens[tokennum - 1]
		if let c = lasttoken.getSymbol() {
			switch c {
			case "A": result = CNEscapeCode.cursorUp(try get1Parameter(from: tokens, forCommand: c))
			case "B": result = CNEscapeCode.cursorDown(try get1Parameter(from: tokens, forCommand: c))
			case "C": result = CNEscapeCode.cursorForward(try get1Parameter(from: tokens, forCommand: c))
			case "D": result = CNEscapeCode.cursorBack(try get1Parameter(from: tokens, forCommand: c))
			case "E": result = CNEscapeCode.cursorNextLine(try get1Parameter(from: tokens, forCommand: c))
			case "F": result = CNEscapeCode.cursorPreviousLine(try get1Parameter(from: tokens, forCommand: c))
			case "G": result = CNEscapeCode.cursorHolizontalAbsolute(try get1Parameter(from: tokens, forCommand: c))
			case "H": let (row, col) = try get2Parameter(from: tokens, forCommand: c)
				  result = CNEscapeCode.cursorPoisition(row, col)
			case "J":
				let param = try get1Parameter(from: tokens, forCommand: c)
				switch param {
				case 0: result = CNEscapeCode.eraceFromCursorToEnd
				case 1: result = CNEscapeCode.eraceFromCursorToBegin
				case 2: result = CNEscapeCode.eraceFromBeginToEnd
				case 3: result = CNEscapeCode.eraceEntireBuffer
				default:
					throw DecodeError.invalidParameter(c, param)
				}
			default:
				throw DecodeError.unknownCommand(c)
			}
		} else {
			throw DecodeError.incompletedSequence
		}
		return (idx1, result)
	}

	private static func get1Parameter(from tokens: Array<CNToken>, forCommand c: Character) throws -> Int {
		if tokens.count == 1 {
			return 1 // default value
		} else if tokens.count == 2 {
			if let param = tokens[0].getInt() {
				return param
			}
		}
		throw DecodeError.invalidParameter(c, -1)
	}

	private static func get2Parameter(from tokens: Array<CNToken>, forCommand c: Character) throws -> (Int, Int) {
		if tokens.count == 4 {
			if let p0 = tokens[0].getInt(), let p1 = tokens[2].getInt() {
				return (p0, p1)
			}
		}
		throw DecodeError.invalidParameter(c, -1)
	}

	private static func decodeStringToTokens(string src: String, index idx: String.Index) throws -> (String.Index, Array<CNToken>) {
		var result: Array<CNToken> = []
		var idx0 = idx
		let end  = src.endIndex
		while idx0 < end {
			let (i1, idx1) = try nextInt(string: src, index: idx0)
			if let ival = i1 {
				let newtoken = CNToken(type: .IntToken(ival), lineNo: 0)
				result.append(newtoken)
				idx0 = idx1
			} else {
				let (c2, idx2) = try nextChar(string: src, index: idx0)
				let newtoken = CNToken(type: .SymbolToken(c2), lineNo: 0)
				result.append(newtoken)
				idx0 = idx2

				/* Finish at the alphabet */
				if c2.isAlpha() {
					return (idx0, result)
				}
			}

		}
		return (idx0, result)
	}

	private static func nextInt(string src: String, index idx: String.Index) throws -> (Int?, String.Index) {
		let (c0, idx0) = try nextChar(string: src, index: idx)
		if let digit = c0.toInt() {
			var result              	= digit
			var idx1 	: String.Index	= idx0
			var docont = true
			while docont {
				let (c2, idx2) = try nextChar(string: src, index: idx1)
				if let digit = c2.toInt() {
					result = result * 10 + digit
					idx1   = idx2
				} else {
					docont = false
				}
			}
			return (Int(result), idx1)
		} else {
			return (nil, idx)
		}
	}

	private static func nextChar(string src: String, index idx: String.Index) throws -> (Character, String.Index) {
		if idx < src.endIndex {
			return (src[idx], src.index(after: idx))
		} else {
			throw DecodeError.incompletedSequence
		}
	}

	private func hex(_ v: Int) -> String {
		return String(v, radix: 16)
	}
}

