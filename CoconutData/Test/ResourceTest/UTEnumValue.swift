/*
 * @file	UTEnumTable.swift
 * @brief	Test CNEnumTable class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public func UTEnumTable() -> Bool
{
	NSLog("*** UTEnumTable")

	guard let srcfile = CNFilePath.URLForResourceFile(fileName: "enum", fileExtension: "json", subdirectory: "Data", forClass: ViewController.self) else {
		NSLog("Failed to allocate source url")
		return false
	}
	guard let srcval = srcfile.loadValue() else {
		NSLog("Failed to load source file: \(srcfile.path)")
		return false
	}
	switch CNEnumTable.fromValue(value: srcval) {
	case .success(let tablep):
		NSLog("Read done")
		if let table = tablep {
			let dump = CNValue.dictionaryValue(table.toValue())
			let txt  = dump.toText().toStrings().joined(separator: "\n")
			NSLog("Read result: \(txt)")
		} else {
			NSLog("Read result: <none>")
		}
	case .failure(let err):
		NSLog("Failed to covert: \(err.toString())")
		return false
	}
	return true
}

