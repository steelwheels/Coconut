/**
 * @file	CNValuePath.swift
 * @brief	Define CNValuePath class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNValuePath
{
	public enum Element {
		case member(String)			// member name
		case index(Int)				// array index to select array element
		case keyAndValue(String, CNValue)	// key and it's value to select array element

		static func isSame(source0 src0: Element, source1 src1: Element) -> Bool {
			let result: Bool
			switch src0 {
			case .member(let memb0):
				switch src1 {
				case .member(let memb1):
					result = memb0 == memb1
				case .index(_), .keyAndValue(_, _):
					result = false
				}
			case .index(let idx0):
				switch src1 {
				case .member(_), .keyAndValue(_, _):
					result = false
				case .index(let idx1):
					result = idx0 == idx1
				}
			case .keyAndValue(let key0, let val0):
				switch src1 {
				case .member(_), .index(_):
					result = false
				case .keyAndValue(let key1, let val1):
					if key0 == key1 {
						switch CNCompareValue(value0: val0, value1: val1){
						case .orderedAscending, .orderedDescending:
							result = false
						case .orderedSame:
							result = true
						}
					} else {
						result = false
					}
				}
			}
			return result
		}
	}

	private struct Elements {
		var 	firstIdent:	String?
		var 	elements:	Array<Element>

		public init(firstIdentifier fidt: String?, elements elms: Array<Element>){
			firstIdent	= fidt
			elements	= elms
		}
	}

	private var mIdentifier:	String?
	private var mElements:   	Array<Element>
	private var mExpression: 	String

	public var identifier: String? { get {
		return mIdentifier
	}}

	public var elements: Array<Element> { get {
		return mElements
	}}

	public var expression: String { get {
		return mExpression
	}}

	public init(identifier ident: String?, elements elms: Array<Element>){
		mIdentifier = ident
		mElements   = elms
		mExpression = CNValuePath.toExpression(identifier: ident, elements: elms)
	}

	public init(identifier ident: String?, member memb: String){
		mIdentifier = ident
		mElements   = [ .member(memb) ]
		mExpression = CNValuePath.toExpression(identifier: ident, elements: mElements)
	}

	public init(path pth: CNValuePath, subPath subs: Array<Element>){
		mIdentifier = pth.identifier
		mElements   = []
		for src in pth.elements {
			mElements.append(src)
		}
		for subs in subs {
			mElements.append(subs)
		}
		mExpression = CNValuePath.toExpression(identifier: pth.identifier, elements: mElements)
	}

	public func isIncluded(in targ: CNValuePath) -> Bool {
		let selms = self.mElements
		let telms = targ.mElements
		if selms.count <= telms.count {
			for i in 0..<selms.count {
				if !Element.isSame(source0: selms[i], source1: telms[i]) {
					return false
				}
			}
			return true
		} else {
			return false
		}
	}

	public var script: String { get {
		var result = ""
		var is1st  = true
		for elm in mElements {
			switch elm {
			case .member(let str):
				if is1st {
					is1st = false
				} else {
					result += "."
				}
				result += "\(str)"
			case .index(let idx):
				result += "[\(idx)]"
			case .keyAndValue(let key, let val):
				result += "[\(key):\(val.script)]"
			}
		}
		return result
	}}

	public static func toExpression(identifier ident: String?, elements elms: Array<Element>) -> String {
		var result: String = ""
		var is1st:  Bool   = true
		if let str = ident {
			result = "@" + str
			is1st  = false
		}
		for elm in elms {
			switch elm {
			case .member(let str):
				if is1st {
					is1st  = false
				} else {
					result += "."
				}
				result    += str
			case .index(let idx):
				result    += "[\(idx)]"
			case .keyAndValue(let key, let val):
				let path: String
				let quote = "\""
				switch val {
				case .stringValue(let str):
					path = quote + str + quote
				default:
					path = quote + val.script + quote
				}
				result 	  += "[\(key):\(path)]"
			}
		}
		return result
	}

	public static func pathExpression(string str: String) -> Result<CNValuePath, NSError> {
		let conf = CNParserConfig(allowIdentiferHasPeriod: false)
		switch CNStringToToken(string: str, config: conf) {
		case .ok(let tokens):
			let stream = CNTokenStream(source: tokens)
			switch pathExpression(stream: stream) {
			case .success(let elms):
				let path = CNValuePath(identifier: elms.firstIdent, elements: elms.elements)
				return .success(path)
			case .failure(let err):
				return .failure(err)
			}
		case .error(let err):
			return .failure(err)
		}
	}

	private static func pathExpression(stream strm: CNTokenStream) -> Result<Elements, NSError> {
		switch pathExpressionIdentifier(stream: strm) {
		case .success(let identp):
			switch pathExpressionMembers(stream: strm, hasIdentifier: identp != nil) {
			case .success(let elms):
				return .success(Elements(firstIdentifier: identp, elements: elms))
			case .failure(let err):
				return .failure(err)
			}
		case .failure(let err):
			return .failure(err)
		}
	}

	private static func pathExpressionIdentifier(stream strm: CNTokenStream) -> Result<String?, NSError> {
		if strm.requireSymbol(symbol: "@") {
			if let ident = strm.getIdentifier() {
				return .success(ident)
			} else {
				let _ = strm.unget() // unget symbol
				CNLog(logLevel: .error, message: "Identifier is required for label", atFunction: #function, inFile: #file)
			}
		}
		return .success(nil)
	}

	private static func pathExpressionMembers(stream strm: CNTokenStream, hasIdentifier hasident: Bool) ->  Result<Array<Element>, NSError> {
		var is1st:  Bool = !hasident
		var result: Array<Element> = []
		while !strm.isEmpty() {
			/* Parse comma */
			if is1st {
				is1st = false
			} else if !strm.requireSymbol(symbol: ".") {
				return .failure(NSError.parseError(message: "Period is expected between members \(near(stream: strm))"))
			}
			/* Parse member */
			guard let member = strm.getIdentifier() else {
				return .failure(NSError.parseError(message: "Member for path expression is required \(near(stream: strm))"))
			}
			result.append(.member(member))
			/* Check "[" symbol */
			while strm.requireSymbol(symbol: "[") {
				switch pathExpressionIndex(stream: strm) {
				case .success(let elm):
					result.append(elm)
				case .failure(let err):
					return .failure(err)
				}
				if !strm.requireSymbol(symbol: "]") {
					return .failure(NSError.parseError(message: "']' is expected"))
				}
			}
		}
		return .success(result)
	}

	private static func pathExpressionIndex(stream strm: CNTokenStream) ->  Result<Element, NSError> {
		if let index = strm.requireUInt() {
			return .success(.index(Int(index)))
		} else if let ident = strm.requireIdentifier() {
			if strm.requireSymbol(symbol: ":") {
				switch requireAnyValue(stream: strm) {
				case .success(let val):
					return .success(.keyAndValue(ident, val))
				case .failure(let err):
					return .failure(err)
				}
			} else {
				return .failure(NSError.parseError(message: "':' is required between dictionary key and value \(near(stream: strm))"))
			}
		} else {
			return .failure(NSError.parseError(message: "Invalid index \(near(stream: strm))"))
		}
	}

	private static func requireAnyValue(stream strm: CNTokenStream) -> Result<CNValue, NSError> {
		if let ival = strm.requireUInt() {
			return .success(.numberValue(NSNumber(integerLiteral: Int(ival))))
		} else if let sval = strm.requireIdentifier() {
			return .success(.stringValue(sval))
		} else if let sval = strm.requireString() {
			return .success(.stringValue(sval))
		} else {
			return .failure(NSError.parseError(message: "immediate value is required for value in key-value index"))
		}
	}

	public static func description(of val: Dictionary<String, Array<CNValuePath.Element>>) -> CNText {
		let sect = CNTextSection()
		sect.header = "{" ; sect.footer = "}"
		for (key, elm) in val {
			let subsect = CNTextSection()
			subsect.header = "\(key): {" ; subsect.footer = "}"

			let desc = toExpression(identifier: nil, elements: elm)
			let line = CNTextLine(string: desc)
			subsect.add(text: line)

			sect.add(text: subsect)
		}
		return sect
	}

	private static func near(stream strm: CNTokenStream) -> String {
		if let token = strm.peek(offset: 0) {
			return "near " + token.toString()
		} else {
			return ""
		}
	}

	public func compare(_ val: CNValuePath) -> ComparisonResult {
		let selfstr = self.mExpression
		let srcstr  = val.mExpression
		if selfstr == srcstr {
			return .orderedSame
		} else if selfstr > srcstr {
			return .orderedDescending
		} else {
			return .orderedAscending
		}
	}
}
