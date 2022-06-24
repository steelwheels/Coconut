//
//  UTStorage.swift
//  CoconutData
//
//  Created by Tomoo Hamada on 2021/12/25.
//

import CoconutData
import Foundation

public func UTStorageLoader() -> Bool {
	NSLog("*** UStorageLoader")

	guard let storage = loadStorage() else {
		return false
	}
	guard testStorageRead(target: storage) else {
		return false
	}
	guard testStorageWrite(target: storage) else {
		return false
	}

	return true
}

private func loadStorage() -> CNStorage? {
	guard let srcfile = CNFilePath.URLForResourceFile(fileName: "root", fileExtension: "json", subdirectory: "Data", forClass: ViewController.self) else {
		NSLog("Failed to allocate source URL")
		return nil
	}
	let cachefile = CNFilePath.URLForApplicationSupportFile(fileName: "root", fileExtension: "json", subdirectory: nil)

	let srcdir   = srcfile.deletingLastPathComponent()
	let cachedir = cachefile.deletingLastPathComponent()

	var result: CNStorage? = nil
	let storage = CNStorage(sourceDirectory: srcdir, cacheDirectory: cachedir, filePath: "root.json")
	switch storage.load() {
	case .success(let value):
		let txt = value.toText().toStrings().joined(separator: "\n")
		NSLog("Loaded storage: \(txt)")
		result = storage
	case .failure(let err):
		NSLog("Load root ... fail: \(err.description)")
	}
	return result
}

private func testStorageRead(target storage: CNStorage) -> Bool
{
	var result = true

	guard let patha = allocValuePath(expression: "a") else {
		return false
	}
	guard let pathb = allocValuePath(expression: "b") else {
		return false
	}
	guard let pathf = allocValuePath(expression: "f") else {
		return false
	}
	guard let pathcd = allocValuePath(expression: "c.d") else {
		return false
	}
	guard let pathce = allocValuePath(expression: "c.e") else {
		return false
	}
	guard let pathfs1 = allocValuePath(expression: "f.s1") else {
		return false
	}

	NSLog("***** Storage read test")
	let storagetxt = storage.toValue().toText().toStrings().joined(separator: "\n")
	NSLog("storage = \(storagetxt)")
	if let vara = storage.value(forPath: patha) {
		NSLog("Property a = \(vara.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property a ... fail (path: \(patha.expression))")
		result = false
	}

	if let varb = storage.value(forPath: pathb) {
		NSLog("Property b = \(varb.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property b ... fail: (path: \(pathb.expression)")
		result = false
	}

	if let vard = storage.value(forPath: pathcd) {
		NSLog("Property c.d = \(vard.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property c.d ... fail: (path: \(pathcd.expression))")
		result = false
	}

	if let vare = storage.value(forPath: pathce) {
		NSLog("Property c.e = \(vare.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property c.e ... fail: (path: \(pathce.expression))")
		result = false
	}

	if let varf = storage.value(forPath: pathfs1) {
		NSLog("Property f = \(varf.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property f ... fail: (path: \(pathfs1.expression))")
		result = false
	}

	if let vars1 = storage.value(forPath: pathfs1) {
		NSLog("Property f.s1 = \(vars1.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property f.s1 ... fail: (path: \(pathfs1.expression))")
		result = false
	}

	if let varf = storage.value(forPath: pathf) {
		NSLog("(2nd) Property f = \(varf.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("(2nd) Check property f ... fail: (path: \(pathf.expression))")
		result = false
	}

	return result
}

private func testStorageWrite(target storage: CNStorage) -> Bool
{
	var result = true

	NSLog("***** Storage write test")

	guard let pathA = allocValuePath(expression: "A") else {
		return false
	}
	guard let pathB = allocValuePath(expression: "B") else {
		NSLog("Invalid path expression: B")
		return false
	}

	// set "str0" for "A"
	let val0: CNValue = .stringValue("str0")
	if storage.set(value: val0, forPath: pathA) {
		if let ret0 = storage.value(forPath: pathA) {
			let txt0 = ret0.toText().toStrings().joined(separator: "\n")
			NSLog("write->read: \(txt0)")
		} else {
			NSLog("Failed to check val0")
			result = false
		}
	} else {
		NSLog("Failed tp store val0")
		result = false
	}

	// set "str1" for "B"
	let val1: CNValue = .stringValue("str1")
	if storage.set(value: val1, forPath: pathB) {
		if let ret1 = storage.value(forPath: pathB) {
			let txt1 = ret1.toText().toStrings().joined(separator: "\n")
			NSLog("write->read: \(txt1)")
		} else {
			NSLog("Failed to check val1")
			result = false
		}
	} else {
		NSLog("Failed tp store val1")
		result = false
	}

	// set "str2" for "A"
	let val2: CNValue = .stringValue("str2")
	if storage.set(value: val2, forPath: pathA) {
		if let ret2 = storage.value(forPath: pathA) {
			let txt2 = ret2.toText().toStrings().joined(separator: "\n")
			NSLog("write->read: \(txt2)")
		} else {
			NSLog("Failed to check val2")
			result = false
		}
	} else {
		NSLog("Failed tp store val2")
		result = false
	}

	return result
}

private func allocValuePath(expression exp: String) -> CNValuePath?
{
	switch CNValuePath.pathExpression(string: exp) {
	case .success(let path):
		return path
	case .failure(let err):
		NSLog("Invalid path expression: \(exp) \(err.toString())")
		return nil
	}
}


