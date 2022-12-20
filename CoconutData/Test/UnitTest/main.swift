/**
 * @file	main.swift
 * @brief	Main function for unit tests
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation
import Darwin

let cons = CNFileConsole()
cons.print(string: "Hello, World!\n")

struct UTResult {
	public var	name:	String
	public var	result:	Bool
	public init(name nm: String, result res: Bool){
		name	= nm
		result	= res
	}
}

var results: Array<UTResult> = []

cons.print(string: "* testType\n")
results.append(UTResult(name: "type", result: testType(console: cons)))

cons.print(string: "* testPreference\n")
results.append(UTResult(name: "preference", result: testPreference(console: cons)))

cons.print(string: "* fontManager\n")
results.append(UTResult(name: "fontManager", result: testFontManager(console: cons)))

cons.print(string: "* testStringStream\n")
results.append(UTResult(name: "stringStream", result: testStringStream(console: cons)))

cons.print(string: "* testAttributedString\n")
results.append(UTResult(name: "attributedString", result: testAttributedString(console: cons)))

cons.print(string: "* testStringUtil\n")
results.append(UTResult(name: "stringUtil", result: testStringUtil(console: cons)))

cons.print(string: "* testCharacter\n")
results.append(UTResult(name: "testCharacter", result: testCharacter(console: cons)))

cons.print(string: "* testEnum\n")
results.append(UTResult(name: "enum", result: testEnum(console: cons)))


cons.print(string: "* testToken\n")
results.append(UTResult(name: "Token", result: testToken(console: cons)))

cons.print(string: "* testURL\n")
results.append(UTResult(name: "URL", result: testURL(console: cons)))

cons.print(string: "* testValueSets\n")
results.append(UTResult(name: "valueSet", result: testValueSet(console: cons)))

cons.print(string: "* testQueue\n")
results.append(UTResult(name: "queue", result: testQueue(console: cons)))

cons.print(string: "* testConsole\n")
results.append(UTResult(name: "console", result: testConsole(console: cons)))

cons.print(string: "* testFile\n")
results.append(UTResult(name: "file", result: testFile(console: cons)))

cons.print(string: "* testFilePath\n")
results.append(UTResult(name: "filePath", result: testFilePath(console: cons)))

cons.print(string: "* testFileManager\n")
results.append(UTResult(name: "fileManager", result: testFileManager(console: cons)))

cons.print(string: "* testObserver\n")
results.append(UTResult(name: "observer", result: testObserver(console: cons)))

cons.print(string: "* testOperation\n")
results.append(UTResult(name: "operation", result: testOperation(console: cons)))

cons.print(string: "* testOperationQueue\n")
results.append(UTResult(name: "operationQueue", result: testOperationQueue(console: cons)))

cons.print(string: "* testProcess\n")
results.append(UTResult(name: "processs", result: testProcess(console: cons)))

cons.print(string: "* testCommandTable\n")
results.append(UTResult(name: "commandTable", result: testCommandTable(console: cons)))

cons.print(string: "* testEnvironment\n")
results.append(UTResult(name: "environment", result: testEnvironment(console: cons)))

cons.print(string: "* testThread\n")
results.append(UTResult(name: "thread", result: testThread(console: cons)))

cons.print(string: "* testEscapeSequence\n")
results.append(UTResult(name: "escapeSequence", result: testEscapeSequence(console: cons)))

cons.print(string: "* testColor\n")
results.append(UTResult(name: "color", result: testColor(console: cons)))

cons.print(string: "* testTextStorage\n")
results.append(UTResult(name: "textStorage", result: testTextStorage(console: cons)))

cons.print(string: "* testKeyBinding\n")
results.append(UTResult(name: "keyBinding", result: testKeyBinding(console: cons)))

cons.print(string: "* testResource\n")
results.append(UTResult(name: "resource", result: testResource(console: cons)))

cons.print(string: "* testMatrix\n")
results.append(UTResult(name: "matrix", result: testMatrix(console: cons)))

cons.print(string: "* testGraphicsContext\n")
results.append(UTResult(name: "graphicsContext", result: testGraphicsContext(console: cons)))

cons.print(string: "* testBitmapContext\n")
results.append(UTResult(name: "bitmap", result: testBitmap(console: cons)))

cons.print(string: "* testNativeValue\n")
results.append(UTResult(name: "nativeValue", result: testNativeValue(console: cons)))

cons.print(string: "* testText\n")
results.append(UTResult(name: "text", result: testText(console: cons)))

cons.print(string: "* vectorGraphics\n")
results.append(UTResult(name: "vectorGraphics", result: testVectorGraphics(console: cons)))

cons.print(string: "* testValueType\n")
results.append(UTResult(name: "valueType", result: testValueType(console: cons)))

cons.print(string: "* testValueConverter\n")
results.append(UTResult(name: "valueConverter", result: testValueConverter(console: cons)))

cons.print(string: "* testStorageTable\n")
results.append(UTResult(name: "storageTable", result: testStorageTable(console: cons)))

var summary = true
for res in results {
	if res.result {
		cons.print(string: "\(res.name) ... OK\n")
	} else {
		cons.print(string: "\(res.name) ... Error\n")
		summary = false
	}
}

if summary {
	cons.print(string: "[SUMMARY] OK\n")
	Darwin.exit(0)
} else {
	cons.print(string: "[SUMMARY] Error\n")
	Darwin.exit(1)
}

