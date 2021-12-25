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
		let cache = CNValueCache(root: baseurl, parentCache: nil)
		switch cache.load(relativePath: "root.json") {
		case .ok(let value):
			let txt = value.toText().toStrings().joined(separator: "\n")
			NSLog("Load root ... done: \(txt)")

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
		case .error(let err):
			NSLog("Load root ... fail: \(err.description)")
		}
		return result
	} else {
		NSLog("Failed to get base url")
		return false
	}
}

