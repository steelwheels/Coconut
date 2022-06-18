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
	let res1 = testPath()
	return res1
}

private func testPath() -> Bool
{
	NSLog("**** testPath")
	let res0 = testValuePath(string: "a",				expectedCount: 1)
	let res1 = testValuePath(string: "a.b",				expectedCount: 2)
	let res2 = testValuePath(string: "a.b.c",			expectedCount: 3)
	let res3 = testValuePath(string: "a.b.c[0]",			expectedCount: 4)
	let res4 = testValuePath(string: "a.b[10].c[0]",		expectedCount: 5)
	let res5 = testValuePath(string: "a[10].b[20][30].c[0]",	expectedCount: 7)
	let res6 = testValuePath(string: "a[b:c]",			expectedCount: 2)
	let res7 = testValuePath(string: "a[id:123]",			expectedCount: 2)
	let res8 = testValuePath(string: "@a123.b",			expectedCount: 1)

	let result = res0 && res1 && res2 && res3 && res4 && res5 && res6 && res7 && res8
	if result {
		NSLog("Result: OK")
	} else {
		NSLog("Result: Error")
	}
	return result
}

private func testValuePath(string str: String, expectedCount ecount: Int) -> Bool {
	NSLog("str: \(str) -> ")
	if let path = allocValuePath(expression: str) {
		NSLog(" * identifier: \(String(describing: path.identifier))")
		for elm in path.elements {
			dumpElement(element: elm)
		}
		if path.elements.count == ecount {
			return true
		} else {
			NSLog("Invalid element count \(path.elements.count) <-> \(ecount)")
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
	case .keyAndValue(let str, let val):
		let txt = val.toText().toStrings().joined(separator: "\n")
		NSLog(" - key(\(str)) & value(\(txt))")
	}
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
