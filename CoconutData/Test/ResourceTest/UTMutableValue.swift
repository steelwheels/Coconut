/*
 * @file	UTMutableValue.swift
 * @brief	Test CNMutableValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public func UTMutableValue() -> Bool
{
	NSLog("*** UTMutableValue")
	let res0 = unitTest()
	let res1 = accessTest()
	let result = res0 && res1
	if result {
		NSLog("Result: ON")
	} else {
		NSLog("Result: Error")
	}
	return result
}

private func unitTest() -> Bool
{
	NSLog("- MutableScalarValue")
	let scalar1 = allocateScalar(intValue: 1)
	let scalar2 = allocateScalar(intValue: 2)
	let scr1txt = scalar1.toText().toStrings().joined(separator: "\n")
	NSLog("scalar1 -> \(scr1txt)")

	NSLog("- MutableArrayValue")
	let array0 = CNMutableArrayValue()
	array0.append(value: scalar1)
	array0.append(value: scalar2)
	let arrtxt0 = array0.toText().toStrings().joined(separator: "\n")
	NSLog("array0 -> \(arrtxt0)")

	NSLog("- MutableDictionaryValue")
	let dict = CNMutableDictionaryValue()
	dict.set(value: scalar1, forKey: "a")
	dict.set(value: scalar2, forKey: "b")
	let dicttxt = dict.toText().toStrings().joined(separator: "\n")
	NSLog("dict -> \(dicttxt)")

	return true
}

private func accessTest() -> Bool
{
	guard let baseurl = CNFilePath.URLForResourceDirectory(directoryName: "Data", subdirectory: nil, forClass: ViewController.self) else {
		NSLog("Failed to get resource URL")
		return false
	}

	let file = baseurl.appendingPathComponent("root.json")
	NSLog("- file-url = \(file.path)")

	guard let initval = file.loadValue() else {
		NSLog("Failed to load resource")
		return false
	}

	let mval: CNMutableValue = CNValueToMutableValue(from: initval)
	let rval: CNValue        = mval.toValue()
	NSLog("mutable-value: ")
	dumpValue(value: rval)

	NSLog("get value \"a\"")
	let patha = CNValuePath(elements: [.member("a")])
	if getValue(path: patha, in: mval, fromPackageDirectory: baseurl) == nil{
		NSLog("Failed to get a")
		return false
	}

	NSLog("get value \"c.d\"")
	let pathcd = CNValuePath(elements: [.member("c"), .member("d")])
	if getValue(path: pathcd, in: mval, fromPackageDirectory: baseurl) == nil{
		NSLog("Failed to get c.d")
		return false
	}

	NSLog("get value \"f.s1\"")
	let pathfs1 = CNValuePath(elements: [.member("f"), .member("s1")])
	if getValue(path: pathfs1, in: mval, fromPackageDirectory: baseurl) == nil{
		NSLog("Failed to get f.s1")
		return false
	}

	NSLog("get value \"g[1]\"")
	let pathg1 = CNValuePath(elements: [.member("g"), .index(1)])
	if getValue(path: pathg1, in: mval, fromPackageDirectory: baseurl) == nil{
		NSLog("Failed to get g[1]")
		return false
	}

	NSLog("override value \"a\"")
	if !setValue(destination: mval, source: CNMutableScalarValue(scalarValue: .boolValue(true)), forPath: patha, fromPackageDirectory: baseurl){
		return false
	}

	NSLog("override value \"g[1]\"")
	if !setValue(destination: mval, source: CNMutableScalarValue(scalarValue: .numberValue(NSNumber(floatLiteral: -1.0))), forPath: pathg1, fromPackageDirectory: baseurl){
		return false
	}

	NSLog("append value \"g[5]\"")
	let pathg5 = CNValuePath(elements: [.member("g"), .index(5)])
	if !setValue(destination: mval, source: CNMutableScalarValue(scalarValue: .numberValue(NSNumber(floatLiteral: 0.5))), forPath: pathg5, fromPackageDirectory: baseurl){
		return false
	}

	NSLog("append value \"h\"")
	let m0   = CNMutableScalarValue(scalarValue: .stringValue("m0"))
	let m1   = CNMutableScalarValue(scalarValue: .stringValue("m1"))
	let dict = CNMutableDictionaryValue()
	dict.set(value: m0, forKey: "m0")
	dict.set(value: m1, forKey: "m1")
	let pathh = CNValuePath(elements: [.member("h") ])
	if !setValue(destination: mval, source: dict, forPath: pathh, fromPackageDirectory: baseurl){
		return false
	}

	NSLog("override value \"h.m0\"")
	let pathhm0 = CNValuePath(elements: [.member("h"), .member("m0") ])
	if !setValue(destination: mval, source: dict, forPath: pathhm0, fromPackageDirectory: baseurl){
		return false
	}

	let cval: CNValue        = mval.toValue()
	NSLog("current-value: ")
	dumpValue(value: cval)

	NSLog("delete value \"g[3]\"")
	let pathg3 = CNValuePath(elements: [.member("g"), .index(3)])
	if !deleteValue(destination: mval, forPath: pathg3, fromPackageDirectory: baseurl){
		return false
	}

	NSLog("delete value \"h.m0.m1\"")
	let pathhm0m1 = CNValuePath(elements: [.member("h"), .member("m0"), .member("m1") ])
	if !deleteValue(destination: mval, forPath: pathhm0m1, fromPackageDirectory: baseurl){
		return false
	}

	let fval: CNValue        = mval.toValue()
	NSLog("final-value: ")
	dumpValue(value: fval)

	return true
}

private func setValue(destination dst: CNMutableValue, source src: CNMutableValue, forPath path: CNValuePath, fromPackageDirectory baseurl: URL) -> Bool {
	if dst.set(value: src, forPath: path.elements, fromPackageDirectory: baseurl) {
		if let _ = getValue(path: path, in: dst, fromPackageDirectory: baseurl) {
			return true
		} else {
			NSLog("Failed to re-get")
			return false
		}
	} else {
		NSLog("Failed to set")
		return false
	}
}

private func getValue(path pth: CNValuePath, in owner: CNMutableValue,fromPackageDirectory baseurl:URL) -> CNMutableValue? {
	if let val = owner.value(forPath: pth.elements, fromPackageDirectory: baseurl) {
		dumpValue(value: val.toValue())
		return val
	} else {
		NSLog("Failed to get")
		return nil
	}
}

private func deleteValue(destination dst: CNMutableValue, forPath path: CNValuePath, fromPackageDirectory baseurl: URL) -> Bool {
	if dst.delete(forPath: path.elements, fromPackageDirectory: baseurl) {
		dumpValue(value: dst.toValue())
		return true
	} else {
		NSLog("Failed to delete")
		return false
	}
}

private func allocateScalar(intValue val: Int) -> CNMutableScalarValue {
	let val    = CNValue.numberValue(NSNumber(integerLiteral: val))
	let scalar = CNMutableScalarValue(scalarValue: val)
	let txt    = scalar.toValue().toText().toStrings().joined(separator: "\n")
	NSLog("scalar(\(val)) -> \(txt)")
	return scalar
}

private func dumpValue(value val: CNValue) {
	let txt = val.toText().toStrings().joined(separator: "\n")
	NSLog("value = \(txt)")
}

/*
public func UTMutableValue() -> Bool {
	NSLog("*** UTMutableValue")
	var result = false

		let file = baseurl.appendingPathComponent("root.json")
		NSLog("- file-url = \(file.path)")
		if let initval = file.loadValue() {
			result = true

			let mval: CNMutableValue = CNMutableValue.toMutableValue(from: initval)
			let rval: CNValue        = mval.toValue()
			NSLog("mutable-value: ")
			dumpValue(value: rval)


		}
		/*
		if let rootval = file.loadValue() {


			//NSLog("- convert")
			//let oval = CNConvertFromMutableValue(value: mval)
			//dumpValue(value: oval)
			result = true
		} else {
			NSLog("Failed to convert to value")
		}*/
	} else {
		NSLog("Failed to load resource")
	}
	return result
}

public func dumpMutableValue(value val: CNMutableValue) {

}
*/
