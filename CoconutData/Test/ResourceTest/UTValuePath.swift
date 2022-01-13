//
//  UTValuePath.swift
//  ResourceTest
//
//  Created by Tomoo Hamada on 2022/01/12.
//

import CoconutData
import Foundation

public func UTValuePath() -> Bool
{
	NSLog("*** UTValuePath")
	let res0 = testValuePath(string: "a",				expectedCount: 1)
	let res1 = testValuePath(string: "a.b",				expectedCount: 2)
	let res2 = testValuePath(string: "a.b.c",			expectedCount: 3)
	let res3 = testValuePath(string: "a.b.c[0]",			expectedCount: 4)
	let res4 = testValuePath(string: "a.b[10].c[0]",		expectedCount: 5)
	let res5 = testValuePath(string: "a[10].b[20][30].c[0]",	expectedCount: 7)

	let result = res0 && res1 && res2 && res3 && res4 && res5
	if result {
		NSLog("Result: ON")
	} else {
		NSLog("Result: Error")
	}
	return result
}

private func testValuePath(string str: String, expectedCount ecount: Int) -> Bool {
	if let elements = CNValuePath.pathExpression(string: str) {
		if elements.count == ecount {
			NSLog("str:\(str) -> ")
			for elm in elements {
				dumpElement(element: elm)
			}
			return true
		} else {
			NSLog("Invalid element count")
			return false
		}
	} else {
		NSLog("Failed to decode path: \(str)")
		return false
	}
}

private func dumpElement(element elm: CNValuePath.Element){
	switch elm {
	case .member(let str):
		NSLog(" - member(\(str))")
	case .index(let idx):
		NSLog(" - index(\(idx))")
	}
}
