//
//  UTValueStorage.swift
//  CoconutData
//
//  Created by Tomoo Hamada on 2021/12/25.
//

import CoconutData
import Foundation

public func UTValueStorage() -> Bool {
	NSLog("*** UTValueStorage")
	if let srcfile = CNFilePath.URLForResourceFile(fileName: "root", fileExtension: "json", subdirectory: nil, forClass: ViewController.self) {
		var result = true

		NSLog("***** Main storage")
		let cachefile = CNFilePath.URLForApplicationSupportFile(fileName: "root", fileExtension: "json", subdirectory: nil)
		NSLog("srcfile=\(srcfile.path), cachefile=\(cachefile)")

		let srcdir   = srcfile.deletingLastPathComponent()
		let cachedir = cachefile.deletingLastPathComponent()

		let storage = CNValueStorage(sourceDirectory: srcdir, cacheDirectory: cachedir, filePath: "root.json")
		switch storage.load() {
		case .ok(let value):
			let txt = value.toText().toStrings().joined(separator: "\n")
			NSLog("Load root ... done: \(txt)")
			if !testStorageRead(target: storage) {
				result = false
			}
			if !testChildStorage(parentStorage: storage) {
				result = false
			}
		case .error(let err):
			NSLog("Load root ... fail: \(err.description)")
		}
		return result
	} else {
		NSLog("Failed to get base url")
		return false
	}
}

private func testChildStorage(parentStorage parent: CNValueStorage) -> Bool {
	var result = true
	
	NSLog("***** Child storage")
	guard let srcfile = CNFilePath.URLForResourceFile(fileName: "root", fileExtension: "json", subdirectory: "Data", forClass: ViewController.self) else {
		NSLog("Faild to allocate source file")
		return false
	}
	let cachefile = CNFilePath.URLForApplicationSupportFile(fileName: "root", fileExtension: "json", subdirectory: "Data")
	NSLog("Copy from \(srcfile.path) to \(cachefile.path)")
	guard FileManager.default.copyFileIfItIsNotExist(sourceFile: srcfile, destinationFile: cachefile) else {
		NSLog("Failed to copy root.json")
		return false
	}

	let storage = CNValueStorage(sourceDirectory: srcfile, cacheDirectory: cachefile, filePath: "root.json")
	if !testStorageRead(target: storage) {
		result = false
	}
	if !testStorageWrite(target: storage) {
		result = false
	}
	if !testStorageStore(target: storage) {
		result = false
	}
	return result
}

private func testStorageRead(target storage: CNValueStorage) -> Bool
{
	var result = true

	guard let patha = CNValuePath.pathExpression(string: "a") else {
		NSLog("Invalid path expression: a")
		return false
	}
	guard let pathb = CNValuePath.pathExpression(string: "b") else {
		NSLog("Invalid path expression: b")
		return false
	}
	guard let pathf = CNValuePath.pathExpression(string: "f") else {
		NSLog("Invalid path expression: f")
		return false
	}
	guard let pathcd = CNValuePath.pathExpression(string: "c.d") else {
		NSLog("Invalid path expression: c.d")
		return false
	}
	guard let pathce = CNValuePath.pathExpression(string: "c.e") else {
		NSLog("Invalid path expression: c.e")
		return false
	}
	guard let pathfs1 = CNValuePath.pathExpression(string: "f.s1") else {
		NSLog("Invalid path expression: f.s1")
		return false
	}


	NSLog("***** Storage read test")
	if let vara = storage.value(forPath: CNValuePath(elements: patha)) {
		NSLog("Property a = \(vara.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property a ... fail")
		result = false
	}

	if let varb = storage.value(forPath: CNValuePath(elements: pathb)) {
		NSLog("Property b = \(varb.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property b ... fail")
		result = false
	}

	if let vard = storage.value(forPath: CNValuePath(elements: pathcd)) {
		NSLog("Property c.d = \(vard.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property c.d ... fail")
		result = false
	}

	if let vare = storage.value(forPath: CNValuePath(elements: pathce)) {
		NSLog("Property c.e = \(vare.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property c.e ... fail")
		result = false
	}

	if let varf = storage.value(forPath: CNValuePath(elements: pathf)) {
		NSLog("Property f = \(varf.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property f ... fail")
		result = false
	}

	if let vars1 = storage.value(forPath: CNValuePath(elements: pathfs1)) {
		NSLog("Property f.s1 = \(vars1.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property f.s1 ... fail")
		result = false
	}

	if let varf = storage.value(forPath: CNValuePath(elements: pathf)) {
		NSLog("(2nd) Property f = \(varf.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("(2nd) Check property f ... fail")
		result = false
	}

	return result
}

private func testStorageWrite(target storage: CNValueStorage) -> Bool
{
	var result = true

	NSLog("***** Storage write test")

	guard let pathA = CNValuePath.pathExpression(string: "A") else {
		NSLog("Invalid path expression: A")
		return false
	}
	guard let pathB = CNValuePath.pathExpression(string: "B") else {
		NSLog("Invalid path expression: B")
		return false
	}

	// set "str0" for "A"
	let val0: CNValue = .stringValue("str0")
	if storage.set(value: val0, forPath: CNValuePath(elements: pathA)) {
		if let ret0 = storage.value(forPath: CNValuePath(elements: pathA)) {
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
	if storage.set(value: val1, forPath: CNValuePath(elements: pathB)) {
		if let ret1 = storage.value(forPath: CNValuePath(elements: pathB)) {
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
	if storage.set(value: val2, forPath: CNValuePath(elements: pathA)) {
		if let ret2 = storage.value(forPath: CNValuePath(elements: pathA)) {
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

private func testStorageStore(target storage: CNValueStorage) -> Bool
{
	NSLog("***** Storage store test")
	if storage.store() {
		NSLog("storage store: OK")
		return true
	} else {
		NSLog("storage store: NG")
		return false
	}
}

