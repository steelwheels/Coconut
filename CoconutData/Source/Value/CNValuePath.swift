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
						switch CNCompareValue(nativeValue0: val0, nativeValue1: val1){
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

	public init(identifier ident: String?, path pth: CNValuePath, subPath subs: Array<Element>){
		mIdentifier = ident
		mElements   = []
		for src in pth.elements {
			mElements.append(src)
		}
		for subs in subs {
			mElements.append(subs)
		}
		mExpression = CNValuePath.toExpression(identifier: ident, elements: mElements)
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

	public var description: String { get {
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
				let txt = val.toText().toStrings().joined(separator: "\n")
				result += "[\(key), \(txt)]"
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
				let txt = val.toText().toStrings().joined(separator: "\n")
				result 	  += "[\(key):\(txt)]"
			}
		}
		return result
	}

	public static func pathExpression(string str: String) -> (String?, Array<Element>)? {
		let result: (String?, Array<Element>)?
		let conf = CNParserConfig(allowIdentiferHasPeriod: false)
		switch CNStringToToken(string: str, config: conf) {
		case .ok(let tokens):
			let stream = CNTokenStream(source: tokens)
			result = pathExpression(stream: stream)
		case .error(let err):
			CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
			result = nil
		}
		return result
	}

	public static func pathExpression(stream strm: CNTokenStream) -> (String?, Array<Element>)? {
		guard let ident = pathExpressionIdentifier(stream: strm) else {
			return nil
		}
		guard let members = pathExpressionMembers(stream: strm, hasIdentifier: !ident.isEmpty) else {
			return nil
		}
		return (ident.isEmpty ? nil : ident, members)
	}

	private static func pathExpressionIdentifier(stream strm: CNTokenStream) -> String? {
		if strm.requireSymbol(symbol: "@") {
			if let ident = strm.getIdentifier() {
				return ident
			} else {
				let _ = strm.unget() // unget symbol
				CNLog(logLevel: .error, message: "Identifier is required for label", atFunction: #function, inFile: #file)
			}
		}
		return ""
	}

	private static func pathExpressionMembers(stream strm: CNTokenStream, hasIdentifier hasident: Bool) ->  Array<Element>? {
		var is1st:  Bool = !hasident
		var result: Array<Element> = []
		while !strm.isEmpty() {
			/* Parse comma */
			if is1st {
				is1st = false
			} else if !strm.requireSymbol(symbol: ".") {
				CNLog(logLevel: .error, message: "Period is expected between members", atFunction: #function, inFile: #file)
				return nil
			}
			/* Parse member */
			guard let member = strm.getIdentifier() else {
				CNLog(logLevel: .error, message: "Member for path expression is required", atFunction: #function, inFile: #file)
				return nil
			}
			result.append(.member(member))
			/* Check "[" symbol */
			while strm.requireSymbol(symbol: "[") {
				if let memb = pathExpressionIndex(stream: strm) {
					result.append(memb)
				} else {
					return nil
				}
				if !strm.requireSymbol(symbol: "]") {
					CNLog(logLevel: .error, message: "']' is expected", atFunction: #function, inFile: #file)
					return nil
				}
			}
		}
		return result
	}

	private static func pathExpressionIndex(stream strm: CNTokenStream) ->  Element? {
		if let index = strm.requireUInt() {
			return .index(Int(index))
		} else if let ident = strm.requireIdentifier() {
			if strm.requireSymbol(symbol: ":") {
				if let val = requireAnyValue(stream: strm) {
					return .keyAndValue(ident, val)
				} else {
					CNLog(logLevel: .error, message: "Invalid dictionary index \(near(stream: strm))")
					return nil
				}
			} else {
				CNLog(logLevel: .error, message: "':' is required for dictionary index \(near(stream: strm))")
				return nil
			}
		} else {
			CNLog(logLevel: .error, message: "Invalid index \(near(stream: strm))")
			return nil
		}
	}

	private static func requireAnyValue(stream strm: CNTokenStream) -> CNValue? {
		if let ival = strm.requireUInt() {
			return .numberValue(NSNumber(integerLiteral: Int(ival)))
		} else if let sval = strm.requireIdentifier() {
			return .stringValue(sval)
		} else {
			return nil
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
