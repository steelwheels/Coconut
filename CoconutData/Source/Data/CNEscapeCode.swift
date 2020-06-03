/**
 * @file	CNEscapeCode.swift
 * @brief	Define CNEscapeCode type
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

/* Reference:
 *  - https://en.wikipedia.org/wiki/ANSI_escape_code
 *  - https://qiita.com/PruneMazui/items/8a023347772620025ad6
 *  - http://www.termsys.demon.co.uk/vtansi.htm
 */
public enum CNEscapeCode {
	case	string(String)
	case	eot					/* End of transmission (CTRL-D)	*/
	case	newline
	case	tab
	case	backspace				/* = moveLeft(1)		*/
	case	delete					/* Delete left 1 character	*/
	case 	cursorUp(Int)
	case 	cursorDown(Int)
	case	cursorForward(Int)
	case	cursorBackward(Int)
	case	cursorNextLine(Int)			/* Moves cursor to beginning of the line n	*/
	case	cursorPreviousLine(Int)			/* Moves cursor to beginning of the line n	*/
	case	cursorHolizontalAbsolute(Int)		/* (Column) started from 1			*/
	case	cursorPosition(Int, Int)		/* (Row, Column) started from 1		 	*/
	case	eraceFromCursorToEnd			/* Clear from cursor to end of buffer 		*/
	case 	eraceFromCursorToBegin			/* Clear from begining of buffer to cursor	*/
	case	eraceEntireBuffer			/* Clear entire buffer				*/
	case 	eraceFromCursorToRight			/* Clear from cursor to end of line		*/
	case	eraceFromCursorToLeft			/* Clear from cursor to beginning of line	*/
	case	eraceEntireLine				/* Clear entire line				*/
	case	scrollUp
	case	scrollDown
	case	resetAll				/* Clear text, reset cursor postion and tabstop	*/
	case	resetCharacterAttribute			/* Reset all arributes for character		*/
	case	boldCharacter(Bool)			/* Set/reset bold font				*/
	case	underlineCharacter(Bool)		/* Set/reset underline font			*/
	case	blinkCharacter(Bool)			/* Set/reset blink font 			*/
	case	reverseCharacter(Bool)			/* Set/reset reverse character			*/
	case	foregroundColor(CNColor)		/* Set foreground color				*/
	case	defaultForegroundColor			/* Set default foreground color			*/
	case	backgroundColor(CNColor)		/* Set background color				*/
	case	defaultBackgroundColor			/* Reset default background color		*/

	case	requestScreenSize			/* Send request to receive screen size
							 * Ps = 18 -> Report the size of the text area in characters as CSI 8 ; height ; width t
							 */
	case	screenSize(Int, Int)			/* Set screen size (Width, Height)		*/
	case	selectAltScreen(Bool)			/* Do switch alternative screen (Yes/No) 	*/

	public func description() -> String {
		var result: String
		switch self {
		case .string(let str):				result = "string(\"\(str)\")"
		case .eot:					result = "endOfTrans"
		case .newline:					result = "newline"
		case .tab:					result = "tab"
		case .backspace:				result = "backspace"
		case .delete:					result = "delete"
		case .cursorUp(let n):				result = "cursorUp(\(n))"
		case .cursorDown(let n):			result = "cursorDown(\(n))"
		case .cursorForward(let n):			result = "cursorForward(\(n))"
		case .cursorBackward(let n):			result = "cursorBack(\(n))"
		case .cursorNextLine(let n):			result = "cursorNextLine(\(n))"
		case .cursorPreviousLine(let n):		result = "cursorPreviousLine(\(n))"
		case .cursorHolizontalAbsolute(let pos):	result = "cursorHolizontalAbsolute(\(pos))"
		case .cursorPosition(let row, let col):	result = "cursorPoisition(\(row),\(col))"
		case .eraceFromCursorToEnd:			result = "eraceFromCursorToEnd"
		case .eraceFromCursorToBegin:			result = "eraceFromCursorToBegin"
		case .eraceEntireBuffer:			result = "eraceEntireBuffer"
		case .eraceFromCursorToRight:			result = "eraceFromCursorToRight"
		case .eraceFromCursorToLeft:			result = "eraceFromCursorToLeft"
		case .eraceEntireLine:				result = "eraceEntireLine"
		case .scrollUp:					result = "scrollUp"
		case .scrollDown:				result = "scrollDown"
		case .resetAll:					result = "resetAll"
		case .resetCharacterAttribute:			result = "resetCharacterAttribute"
		case .boldCharacter(let flag):			result = "boldCharacter(\(flag))"
		case .underlineCharacter(let flag):		result = "underlineCharacter(\(flag))"
		case .blinkCharacter(let flag):			result = "blinkCharacter(\(flag))"
		case .reverseCharacter(let flag):		result = "reverseCharacter(\(flag))"
		case .foregroundColor(let col):			result = "foregroundColor(\(col.rgbName))"
		case .defaultForegroundColor:			result = "defaultForegroundColor"
		case .backgroundColor(let col):			result = "backgroundColor(\(col.rgbName))"
		case .defaultBackgroundColor:			result = "defaultBackgroundColor"
		case .requestScreenSize:			result = "requestScreenSize"
		case .screenSize(let width, let height):	result = "screenSize(\(width), \(height))"
		case .selectAltScreen(let selalt):		result = "selectAltScreen(\(selalt))"
		}
		return result
	}

	public func encode() -> String {
		let ESC = Character.ESC
		var result: String
		switch self {
		case .string(let str):				result = str
		case .eot:					result = String(Character.EOT)
		case .newline:					result = String(Character.CR)
		case .tab:					result = String(Character.TAB)
		case .backspace:				result = String(Character.BS)
		case .delete:					result = String(Character.DEL)
		case .cursorUp(let n):				result = "\(ESC)[\(n)A"
		case .cursorDown(let n):			result = "\(ESC)[\(n)B"
		case .cursorForward(let n):			result = "\(ESC)[\(n)C"
		case .cursorBackward(let n):			result = "\(ESC)[\(n)D"
		case .cursorNextLine(let n):			result = "\(ESC)[\(n)E"
		case .cursorPreviousLine(let n):		result = "\(ESC)[\(n)F"
		case .cursorHolizontalAbsolute(let n):		result = "\(ESC)[\(n)G"
		case .cursorPosition(let row, let col):		result = "\(ESC)[\(row);\(col)H"
		case .eraceFromCursorToEnd:			result = "\(ESC)[0J"
		case .eraceFromCursorToBegin:			result = "\(ESC)[1J"
		case .eraceEntireBuffer:			result = "\(ESC)[2J"
		case .eraceFromCursorToRight:			result = "\(ESC)[0K"
		case .eraceFromCursorToLeft:			result = "\(ESC)[1K"
		case .eraceEntireLine:				result = "\(ESC)[2K"
		case .scrollUp:					result = "\(ESC)M"
		case .scrollDown:				result = "\(ESC)D"
		case .resetAll:					result = "\(ESC)c"
		case .resetCharacterAttribute:			result = "\(ESC)[0m"
		case .boldCharacter(let flag):			result = "\(ESC)[\(flag ? 1: 22)m"
		case .underlineCharacter(let flag):		result = "\(ESC)[\(flag ? 4: 24)m"
		case .blinkCharacter(let flag):			result = "\(ESC)[\(flag ? 5: 25)m"
		case .reverseCharacter(let flag):		result = "\(ESC)[\(flag ? 7: 27)m"
		case .foregroundColor(let col):			result = "\(ESC)[\(colorToCode(isForeground: true, color: col))m"
		case .defaultForegroundColor:			result = "\(ESC)[39m"
		case .backgroundColor(let col):			result = "\(ESC)[\(colorToCode(isForeground: false, color: col))m"
		case .defaultBackgroundColor:			result = "\(ESC)[49m"
		case .requestScreenSize:			result = "\(ESC)[18;0;0t"
		case .screenSize(let width, let height):	result = "\(ESC)[8;\(height);\(width)t"
		case .selectAltScreen(let selalt):		result = selalt ? "\(ESC)[?47h" : "\(ESC)[?47l"
		}
		return result
	}

	private func colorToCode(isForeground isfg: Bool, color col: CNColor) -> Int32 {
		let result: Int32
		if isfg {
			result = col.escapeCode() + 30
		} else {
			result = col.escapeCode() + 40
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
		case .eot:
			switch src {
			case .eot:				result = true
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
		case .delete:
			switch src {
			case .delete:				result = true
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
		case .cursorBackward(let n0):
			switch src {
			case .cursorBackward(let n1):		result = (n0 == n1)
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
		case .cursorPosition(let row0, let col0):
			switch src {
			case .cursorPosition(let row1, let col1):	result = (row0 == row1) && (col0 == col1)
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
		case .eraceEntireBuffer:
			switch src {
			case .eraceEntireBuffer:		result = true
			default:				break
			}
		case .eraceFromCursorToRight:
			switch src {
			case .eraceFromCursorToRight:		result = true
			default:				break
			}
		case .eraceFromCursorToLeft:
			switch src {
			case .eraceFromCursorToLeft:		result = true
			default:				break
			}
		case .eraceEntireLine:
			switch src {
			case .eraceEntireLine:			result = true
			default:				break
			}
		case .scrollUp:
			switch src {
			case .scrollUp:				result = true
			default:				break
			}
		case .scrollDown:
			switch src {
			case .scrollDown:			result = true
			default:				break
			}
		case .resetAll:
			switch src {
			case .resetAll:				result = true
			default:				break
			}
		case .resetCharacterAttribute:
			switch src {
			case .resetCharacterAttribute:		result = true
			default:				break
			}
		case .boldCharacter(let flag0):
			switch src {
			case .boldCharacter(let flag1):		result = flag0 == flag1
			default:				break
			}
		case .underlineCharacter(let flag0):
			switch src {
			case .underlineCharacter(let flag1):	result = flag0 == flag1
			default:				break
			}
		case .blinkCharacter(let flag0):
			switch src {
			case .blinkCharacter(let flag1):	result = flag0 == flag1
			default:				break
			}
		case .reverseCharacter(let flag0):
			switch src {
			case .reverseCharacter(let flag1):	result = flag0 == flag1
			default:				break
			}
		case .foregroundColor(let col0):
			switch src {
			case .foregroundColor(let col1):	result = col0 == col1
			default:				break
			}
		case .defaultForegroundColor:
			switch src {
			case .defaultForegroundColor:		result = true
			default:				break
			}
		case .backgroundColor(let col0):
			switch src {
			case .backgroundColor(let col1):	result = col0 == col1
			default:				break
			}
		case .defaultBackgroundColor:
			switch src {
			case .defaultBackgroundColor:		result = true
			default:				break
			}
		case .requestScreenSize:
			switch src {
			case .requestScreenSize:		result = true
			default:				break
			}
		case .screenSize(let width0, let height0):
			switch src {
			case .screenSize(let width1, let height1):
				result = (width0 == width1) && (height0 == height1)
			default:				break
			}
		case .selectAltScreen(let s0):
			switch src {
			case .selectAltScreen(let s1):		result = (s0 == s1)
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
			case Character.ESC:
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* get next char */
				let (c1, idx1) = try nextChar(string: src, index: idx0)
				switch c1 {
				case "[":
					/* Decode escape sequence */
					let (idx2, command2) = try decodeEscapeSequence(string: src, index: idx1)
					result.append(contentsOf: command2)
					idx = idx2
				case "D":
					result.append(.scrollDown)
					idx = idx1
				case "U":
					result.append(.scrollUp)
					idx = idx1
				default:
					result.append(.string("\(c0)\(c1)"))
					idx = idx1
				}
			case Character.LF, Character.CR:
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* add newline */
				result.append(.newline)
				idx = idx0
			case Character.TAB:
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* add tab */
				result.append(.tab)
				idx = idx0
			case Character.BS:
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* add backspace */
				result.append(.backspace)
				idx = idx0
			case Character.DEL:
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* add delete */
				result.append(.delete)
				idx = idx0
			case Character.EOT:
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* add delete */
				result.append(.eot)
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

	private static func decodeEscapeSequence(string src: String, index idx: String.Index) throws -> (String.Index, Array<CNEscapeCode>) {
		let (idx1, tokens) = try decodeStringToTokens(string: src, index: idx)
		let tokennum       = tokens.count
		if tokennum == 0 {
			throw DecodeError.incompletedSequence
		}

		var results : Array<CNEscapeCode> = []
		let lasttoken	= tokens[tokennum - 1]
		if let c = lasttoken.getSymbol() {
			switch c {
			case "A": results.append(CNEscapeCode.cursorUp(try get1Parameter(from: tokens, forCommand: c)))
			case "B": results.append(CNEscapeCode.cursorDown(try get1Parameter(from: tokens, forCommand: c)))
			case "C": results.append(CNEscapeCode.cursorForward(try get1Parameter(from: tokens, forCommand: c)))
			case "D": results.append(CNEscapeCode.cursorBackward(try get1Parameter(from: tokens, forCommand: c)))
			case "E": results.append(CNEscapeCode.cursorNextLine(try get1Parameter(from: tokens, forCommand: c)))
			case "F": results.append(CNEscapeCode.cursorPreviousLine(try get1Parameter(from: tokens, forCommand: c)))
			case "G": results.append(CNEscapeCode.cursorHolizontalAbsolute(try get1Parameter(from: tokens, forCommand: c)))
			case "H": let (row, col) = try get0Or2Parameter(from: tokens, forCommand: c)
				  results.append(CNEscapeCode.cursorPosition(row, col))
			case "J":
				let param = try get1Parameter(from: tokens, forCommand: c)
				switch param {
				case 0: results.append(CNEscapeCode.eraceFromCursorToEnd)
				case 1: results.append(CNEscapeCode.eraceFromCursorToBegin)
				case 2: results.append(CNEscapeCode.eraceEntireBuffer)
				default:
					throw DecodeError.invalidParameter(c, param)
				}
			case "K":
				let param = try get1Parameter(from: tokens, forCommand: c)
				switch param {
				case 0: results.append(CNEscapeCode.eraceFromCursorToRight)
				case 1: results.append(CNEscapeCode.eraceFromCursorToLeft)
				case 2: results.append(CNEscapeCode.eraceEntireLine)
				default:
					throw DecodeError.invalidParameter(c, param)
				}
			case "h":
				let param = try getDec1Parameter(from: tokens, forCommand: c)
				switch param {
				case 47: results.append(CNEscapeCode.selectAltScreen(true))	// XT_ALTSCRN
				default:
					throw DecodeError.invalidParameter(c, param)
				}
			case "l":
				let param = try getDec1Parameter(from: tokens, forCommand: c)
				switch param {
				case 47: results.append(CNEscapeCode.selectAltScreen(false))	// XT_ALTSCRN
				default:
					throw DecodeError.invalidParameter(c, param)
				}
			case "m":
				let params = try getParameters(from: tokens, count: tokennum - 1, forCommand: c)
				results.append(contentsOf: try CNEscapeCode.decodeCharacterAttributes(parameters: params))
			case "t":
				let (param0, param1, param2) = try get3Parameter(from: tokens, forCommand: c)
				switch param0 {
				case 8:
					results.append(.screenSize(param2, param1))
				case 18:
					results.append(.requestScreenSize)
				default:
					throw DecodeError.invalidParameter(c, 0)
				}
			default:
				throw DecodeError.unknownCommand(c)
			}
		} else {
			throw DecodeError.incompletedSequence
		}
		return (idx1, results)
	}

	private static func decodeCharacterAttributes(parameters params: Array<Int>) throws -> Array<CNEscapeCode> {
		var results: Array<CNEscapeCode> = []

		var index: Int = 0
		let paramnum = params.count
		while index < paramnum {
			let param = params[index]
			if param == 0 {
				/* Reset status */
				results.append(.resetCharacterAttribute)
				/* Next index */
				index += 1
			} else if param == 1 {
				/* Reset status */
				results.append(.boldCharacter(true))
				/* Next index */
				index += 1
			} else if param == 4 {
				/* Reset status */
				results.append(.underlineCharacter(true))
				/* Next index */
				index += 1
			} else if param == 5 {
				/* Reset status */
				results.append(.blinkCharacter(true))
				/* Next index */
				index += 1
			} else if param == 7 {
				/* Reset status */
				results.append(.reverseCharacter(true))
				/* Next index */
				index += 1
			} else if param == 22 {
				/* Reset status */
				results.append(.boldCharacter(false))
				/* Next index */
				index += 1
			} else if param == 24 {
				/* Reset status */
				results.append(.underlineCharacter(false))
				/* Next index */
				index += 1
			} else if param == 25 {
				/* Reset status */
				results.append(.blinkCharacter(false))
				/* Next index */
				index += 1
			} else if param == 27 {
				/* Reset status */
				results.append(.reverseCharacter(false))
				/* Next index */
				index += 1
			} else if 30<=param && param<=37 {
				if let col = CNColor.color(withEscapeCode: Int32(param - 30)) {
					results.append(.foregroundColor(col))
				} else {
					throw DecodeError.invalidParameter("m", param)
				}
				/* Next index */
				index += 1
			} else if param == 39 {
				results.append(.defaultForegroundColor)
				/* Next index */
				index += 1
			} else if 40<=param && param<=47 {
				if let col = CNColor.color(withEscapeCode: Int32(param - 40)) {
					results.append(.backgroundColor(col))
				} else {
					throw DecodeError.invalidParameter("m", param)
				}
				/* Next index */
				index += 1
			} else if param == 49 {
				results.append(.defaultBackgroundColor)
				/* Next index */
				index += 1
			} else {
				throw DecodeError.invalidParameter("m", param)
			}
		}
		return results
	}

	private static func getParameters(from tokens: Array<CNToken>, count tokennum: Int, forCommand c: Character) throws -> Array<Int> {
		if tokennum > 0 {
			var result: Array<Int> = []
			for token in tokens[0..<tokennum] {
				switch token.type {
				case .IntToken(let val):
					result.append(val)
				case .SymbolToken(let c):
					if c != ";" {
						throw DecodeError.unexpectedCharacter(c)
					}
				default:
					throw DecodeError.incompletedSequence
				}
			}
			return result
		} else {
			return [0]
		}
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

	private static func get0Or2Parameter(from tokens: Array<CNToken>, forCommand c: Character) throws -> (Int, Int) {
		if tokens.count == 4 {
			if let p0 = tokens[0].getInt(), let p1 = tokens[2].getInt() {
				return (p0, p1)
			}
		} else if tokens.count == 1 {
			return (1, 1)	// give default values
		}
		throw DecodeError.invalidParameter(c, -1)
	}

	private static func get3Parameter(from tokens: Array<CNToken>, forCommand c: Character) throws -> (Int, Int, Int) {
		if tokens.count == 6 {
			if let p0 = tokens[0].getInt(), let p1 = tokens[2].getInt(), let p2 = tokens[4].getInt() {
				return (p0, p1, p2)
			}
		}
		throw DecodeError.invalidParameter(c, -1)
	}

	private static func getDec1Parameter(from tokens: Array<CNToken>, forCommand c: Character) throws -> Int {
		if tokens.count == 3 {
			if tokens[0].getSymbol() == "?" {
				if let pm = tokens[1].getInt() {
					return pm
				}
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
				if c2.isLetter {
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

