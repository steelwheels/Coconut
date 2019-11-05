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

cons.print(string: "* testPreference\n")
let result8 = testPreference(console: cons)

cons.print(string: "* testStringStream\n")
let result12 = testStringStream(console: cons)

cons.print(string: "* testStringUtil\n")
let result15 = testStringUtil(console: cons)

cons.print(string: "* testReadline\n")
let result16 = testReadline(console: cons)

cons.print(string: "* testURL\n")
let result9 = testURL(console: cons)

cons.print(string: "* testValue\n")
let result0 = testValue(console: cons)

cons.print(string: "* testQueue\n")
let result17 = testQueue(console: cons)

cons.print(string: "* testConsole\n")
let result1 = testConsole(console: cons)

cons.print(string: "* testFilePath\n")
let result2 = testFilePath(console: cons)

cons.print(string: "* testObserver\n")
let result3 = testObserver(console: cons)

cons.print(string: "* testOperation\n")
let result4 = testOperation(console: cons)

cons.print(string: "* testOperationQueue\n")
let result5 = testOperationQueue(console: cons)

cons.print(string: "* testProcess\n")
let result13 = testProcess(console: cons)

cons.print(string: "* testThread\n")
let result14 = testThread(console: cons)

cons.print(string: "* testGraphics\n")
let result10 = testGraphics(console: cons)

cons.print(string: "* testEscapeSequence\n")
let result11 = testEscapeSequence(console: cons)

cons.print(string: "* testDatabse\n")
let result6 = testDatabase(console: cons)

cons.print(string: "* testResource\n")
let result7 = testResource(console: cons)

let result = result0 && result1 && result2 && result3 && result4  && result5 &&
	     result6 && result7 && result8 && result9 && result10 && result11 &&
	     result12 && result13 && result14 && result15 && result16
if result {
	cons.print(string: "[Result] OK\n")
	Darwin.exit(0)
} else {
	cons.print(string: "[Result] NG\n")
	Darwin.exit(1)
}

