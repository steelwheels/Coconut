//
//  UTValueCache.swift
//  CoconutData
//
//  Created by Tomoo Hamada on 2021/12/25.
//

import CoconutData
import Foundation

public func UTValueCache() -> Bool {
	NSLog("UTValueCache")
	if let baseurl = CNFilePath.URLForResourceDirectory(directoryName: "Data", subdirectory: nil, forClass: ViewController.self) {
		var result = true
		NSLog("base-url = \(baseurl.path)")
		NSLog("***** Main cache")
		let cache = CNValueCache(root: baseurl, parentCache: nil)
		switch cache.load(relativePath: "root.json") {
		case .ok(let value):
			let txt = value.toText().toStrings().joined(separator: "\n")
			NSLog("Load root ... done: \(txt)")
			if !testCacheRead(target: cache) {
				result = false
			}

			if !testChildCache(parentCache: cache) {
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

private func testChildCache(parentCache parent: CNValueCache) -> Bool {
	var result = true
	
	NSLog("***** Child cache")
	let url = CNFilePath.URLforUserLibraryDirectory()
	NSLog("home: \(url.absoluteString)")

	let cache = CNValueCache(root: url, parentCache: parent)
	if !testCacheRead(target: cache) {
		result = false
	}
	if !testCacheWrite(target: cache) {
		result = false
	}
	if !testCacheStore(target: cache) {
		result = false
	}
	return result
}

private func testCacheRead(target cache: CNValueCache) -> Bool
{
	var result = true

	NSLog("***** Cache read test")
	if let vara = cache.value(forPath: ["a"]) {
		NSLog("Property a = \(vara.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property a ... fail")
		result = false
	}

	if let varb = cache.value(forPath: ["b"]) {
		NSLog("Property b = \(varb.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property b ... fail")
		result = false
	}

	if let vard = cache.value(forPath: ["c", "d"]) {
		NSLog("Property c.d = \(vard.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property c.d ... fail")
		result = false
	}

	if let vare = cache.value(forPath: ["c", "e"]) {
		NSLog("Property c.e = \(vare.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property c.e ... fail")
		result = false
	}

	if let varf = cache.value(forPath: ["f"]) {
		NSLog("Property f = \(varf.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property f ... fail")
		result = false
	}

	if let vars1 = cache.value(forPath: ["f", "s1"]) {
		NSLog("Property f.s1 = \(vars1.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("Check property f.s1 ... fail")
		result = false
	}

	if let varf = cache.value(forPath: ["f"]) {
		NSLog("(2nd) Property f = \(varf.toText().toStrings().joined(separator: "\n"))")
	} else {
		NSLog("(2nd) Check property f ... fail")
		result = false
	}

	return result
}

private func testCacheWrite(target cache: CNValueCache) -> Bool
{
	var result = true

	NSLog("***** Cache write test")

	// set "str0" for "A"
	let val0: CNValue = .stringValue("str0")
	if cache.set(value: val0, forPath: ["A"]) {
		if let ret0 = cache.value(forPath: ["A"]) {
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
	if cache.set(value: val1, forPath: ["B"]) {
		if let ret1 = cache.value(forPath: ["B"]) {
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
	if cache.set(value: val2, forPath: ["A"]) {
		if let ret2 = cache.value(forPath: ["A"]) {
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

private func testCacheStore(target cache: CNValueCache) -> Bool
{
	NSLog("***** Cache store test")
	if cache.store(relativePath: "new_cache.json") {
		NSLog("cache store: OK")
		return true
	} else {
		NSLog("cache store: NG")
		return false
	}
}

