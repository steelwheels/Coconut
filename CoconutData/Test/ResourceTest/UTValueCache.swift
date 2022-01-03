//
//  UTValueStorage.swift
//  CoconutData
//
//  Created by Tomoo Hamada on 2021/12/25.
//

import CoconutData
import Foundation

public func UTValueStorage() -> Bool {
	NSLog("UTValueStorage")
	if let baseurl = CNFilePath.URLForResourceDirectory(directoryName: "Data", subdirectory: nil, forClass: ViewController.self) {
		var result = true
		NSLog("base-url = \(baseurl.path)")
		NSLog("***** Main storage")
		let storage = CNValueStorage(root: baseurl, parentStorage: nil)
		switch storage.load(relativePath: "root.json") {
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
	let url = CNFilePath.URLforApplicationSupportDirectory()
	NSLog("home: \(url.absoluteString)")

	let storage = CNValueStorage(root: url, parentStorage: parent)
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

	NSLog("***** Storage read test")
	if let vara = storage.value(forPath: ["a"]) {
		NSLog("Property a = \(vara.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property a ... fail")
		result = false
	}

	if let varb = storage.value(forPath: ["b"]) {
		NSLog("Property b = \(varb.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property b ... fail")
		result = false
	}

	if let vard = storage.value(forPath: ["c", "d"]) {
		NSLog("Property c.d = \(vard.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property c.d ... fail")
		result = false
	}

	if let vare = storage.value(forPath: ["c", "e"]) {
		NSLog("Property c.e = \(vare.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property c.e ... fail")
		result = false
	}

	if let varf = storage.value(forPath: ["f"]) {
		NSLog("Property f = \(varf.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property f ... fail")
		result = false
	}

	if let vars1 = storage.value(forPath: ["f", "s1"]) {
		NSLog("Property f.s1 = \(vars1.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property f.s1 ... fail")
		result = false
	}

	if let varf = storage.value(forPath: ["f"]) {
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

	// set "str0" for "A"
	let val0: CNValue = .stringValue("str0")
	if storage.set(value: val0, forPath: ["A"]) {
		if let ret0 = storage.value(forPath: ["A"]) {
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
	if storage.set(value: val1, forPath: ["B"]) {
		if let ret1 = storage.value(forPath: ["B"]) {
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
	if storage.set(value: val2, forPath: ["A"]) {
		if let ret2 = storage.value(forPath: ["A"]) {
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
	if storage.store(relativePath: "new_storage.json") {
		NSLog("storage store: OK")
		return true
	} else {
		NSLog("storage store: NG")
		return false
	}
}

