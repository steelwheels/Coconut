//
//  UTStorage.swift
//  CoconutData
//
//  Created by Tomoo Hamada on 2021/12/25.
//

import CoconutData
import Foundation

public func UTStorageData() -> Bool {
	NSLog("*** UTStorageData")

	let storage: CNStorage
	switch loadStorage() {
	case .success(let strg):
		storage = strg
	case .failure(let err):
		CNLog(logLevel: .error, message: "Failed to load: \(err.toString())", atFunction: #function, inFile: #file)
		return false
	}

	let res0 = testStorageDictionary(storage: storage)

	return res0
}

private func loadStorage() -> Result<CNStorage, NSError> {
	guard let srcfile = CNFilePath.URLForResourceFile(fileName: "data", fileExtension: "json", subdirectory: "Data", forClass: ViewController.self) else {
		return .failure(NSError.fileError(message: "Failed to allocate source url"))
	}
	let cachefile = CNFilePath.URLForApplicationSupportFile(fileName: "data", fileExtension: "json", subdirectory: "Data")

	let srcdir   = srcfile.deletingLastPathComponent()
	let cachedir = cachefile.deletingLastPathComponent()
	let storage  = CNStorage(sourceDirectory: srcdir, cacheDirectory: cachedir, filePath: "data.json")
	switch storage.load() {
	case .success(_):
		return .success(storage)
	case .failure(let err):
		return .failure(NSError.fileError(message: "Failed to load storage: \(err.toString())"))
	}
}

private func testStorageDictionary(storage strg: CNStorage) -> Bool {
	var result = true

	NSLog("* testStorageDictionary")
	let vpath = CNValuePath(identifier: nil, elements: [.member("dict0")])
	let dict0 = CNStorageDictionary(path: vpath, storage: strg)

	var res0 = false
	if let val = dict0.value(forKey: "a") {
		if let num = val.toNumber() {
			if num.intValue == 10 {
				res0 = true
			}
		}
	}
	if res0 {
		NSLog("value(a) ... OK")
	} else {
		NSLog("value(a) ... Error")
		result = false
	}

	if dict0.set(value: .stringValue("Good morning"), forKey: "c") {
		NSLog("set(c) ... OK")
	} else {
		NSLog("set(c) ... Error")
		result = false
	}

	if strg.save() {
		NSLog("save ... OK")
	} else {
		NSLog("save ... Error")
		result = false
	}

	return result
}
