/**
 * @file	UTJSON.swift
 * @brief	Test function for CNJSONFile and CNNativeValue
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testJSON(console cons: CNConsole) -> Bool
{
	var result = true

	let data0 = makeData()
	let (str, err) = CNJSONFile.serialize(JSONObject: data0)
	if let s = str {
		cons.print(string: "--- Serialized string\n")
		cons.print(string: s)

		let (serdata, sererr) = CNJSONFile.unserialize(string: s)
		if let ser = serdata {
			/* Re-serialize */
			let (revstr, reverr) = CNJSONFile.serialize(JSONObject: ser)
			if let r = revstr {
				cons.print(string: "--- Serialized -> Unserialized -> Serialized string\n")
				cons.print(string: r)
			} else {
				cons.error(string: "[Error] \(reverr!.description)\n")
				result = false
			}
		} else {
			cons.error(string: "[Error] \(sererr!.description)\n")
			result = false
		}
	} else {
		cons.error(string: "[Error] \(err!.description)\n")
		result = false
	}

	return result
}

private func makeData() -> CNNativeValue {
	let a0 = CNNativeValue.dictionaryValue([
		"address":	CNNativeValue.stringValue("Japan"),
		"tel":		CNNativeValue.stringValue("123-456")
	])
	let a1 = CNNativeValue.dictionaryValue([
		"address":	CNNativeValue.stringValue("Osaka"),
		"tel":		CNNativeValue.stringValue("234-567")
	])
	return CNNativeValue.arrayValue([a0, a1])
}
