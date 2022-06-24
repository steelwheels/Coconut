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

	let res0 = testStorageArray(storage: storage)
	let res1 = testStorageDictionary(storage: storage)
	let res2 = testStorageSet(storage: storage)

	let summary = res0 && res1 && res2
	if summary {
		NSLog("UTStorageData: OK")
	} else {
		NSLog("UTStorageData: Error")
	}
	return summary
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

private func testStorageArray(storage strg: CNStorage) -> Bool {
	var result = true

	NSLog("* testStorageArray")
	let vpath = CNValuePath(identifier: nil, elements: [.member("array0")])
	let arr0 = CNStorageArray(path: vpath, storage: strg)

	dump(storageArray: arr0)

	if !arr0.append(value: .numberValue(NSNumber(integerLiteral: 3))) {
		NSLog("Failed to append")
		result = false
	}
	if !arr0.set(value: .numberValue(NSNumber(integerLiteral: 4)), at: 0) {
		NSLog("Failed to set")
		result = false
	}
	dump(storageArray: arr0)

	return result
}

private func testStorageSet(storage strg: CNStorage) -> Bool {
	var result = true

	NSLog("* testStorageSet")
	let vpath = CNValuePath(identifier: nil, elements: [.member("set0")])
	let set0 = CNStorageSet(path: vpath, storage: strg)

	dump(storageSet: set0)

	NSLog("insert 4")
	if !set0.insert(value: .numberValue(NSNumber(integerLiteral: 4))){
		NSLog("Error: Failed to insert (0)")
		result = false
	}
	dump(storageSet: set0)

	NSLog("insert 2")
	if !set0.insert(value: .numberValue(NSNumber(integerLiteral: 2))) {
		NSLog("Error: Failed to insert (1)")
		result = false
	}
	dump(storageSet: set0)

	if set0.values.count != 4 {
		NSLog("Error: Unexpected element count")
		result = false
	}

	return result
}

private func dump(storageArray arr: CNStorageArray) {
	NSLog("values = ")
	let count = arr.values.count
	var line: String = "["
	for i in 0..<count {
		if let val = arr.value(at: i) {
			line += val.toText().toStrings().joined(separator: "\n") + " "
		} else {
			NSLog("Failed to access array")
		}
	}
	line += "]"
	NSLog("values in array = \(line)")
}

private func dump(storageSet sset: CNStorageSet) {
	NSLog("values in set = ")
	for val in sset.values {
		let txt = val.toText().toStrings().joined(separator: "\n")
		NSLog(" * \(txt)")
	}
}


