/*
 * @file	CNValueCoder.swift
 * @brief	Define code functions for CNValue class
 * @par Copyright
 *   Copyright (C) 2017-2021 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

extension CNValue
{
	public var script: String { get {
		return self.toScript().toStrings().joined(separator: "\n")
	}}

	public func toScript() -> CNText {
		let result: CNText
		switch self {
		case .boolValue(let val):
			result = CNTextLine(string: "\(val)")
		case .numberValue(let num):
			result = CNTextLine(string: num.stringValue) 
		case .objectValue(let obj):
			let classname = String(describing: type(of: obj))
			result = CNTextLine(string: classname)
		case .stringValue(let val):
			let txt = CNStringUtil.insertEscapeForQuote(source: val)
			result = CNTextLine(string: "\"" + txt + "\"")
		case .enumValue(let val):
			let txt = "\(val.typeName).\(val.memberName)"
			result = CNTextLine(string: txt)
		case .dictionaryValue(let val):
			result = dictionaryToScript(dictionary: val)
		case .structValue(_):
			let dict = self.toPrimitiveValue()
			result = dict.toScript()
		case .arrayValue(let val):
			result = arrayToScript(array: val)
		case .setValue(let val):
			result = setToScript(set: val)
		}
		return result
	}

	public var string: String { get {
		return self.toText().toStrings().joined(separator: "\n")
	}}

	public func toText() -> CNText {
		let result: CNText
		switch self {
		case .stringValue(let str):
			result = CNTextLine(string: str)
		default:
			result = self.toScript()
		}
		return result
	}

	private func arrayToScript(array arr: Array<CNValue>) -> CNTextSection {
		let sect = CNTextSection()
		sect.header = "[" ; sect.footer = "]" ; sect.separator = ","
		for elm in arr {
			sect.add(text: elm.toScript())
		}
		return sect
	}

	private func setToScript(set vals: Array<CNValue>) -> CNTextSection {
		let dict: Dictionary<String, CNValue> = [
			"class":	.stringValue(CNValue.SetClassName),
			"values":	.arrayValue(vals)
		]
		return dictionaryToScript(dictionary: dict)
	}

	private func dictionaryToScript(dictionary dict: Dictionary<String, CNValue>) -> CNTextSection {
		let sect = CNTextSection()
		sect.header = "{" ; sect.footer = "}" ; sect.separator = ","
		let keys = dict.keys.sorted()
		for key in keys {
			if let val = dict[key] {
				let newtxt = val.toScript()
				let labtxt = CNLabeledText(label: "\(key): ", text: newtxt)
				sect.add(text: labtxt)
			}
		}
		return sect
	}
}

