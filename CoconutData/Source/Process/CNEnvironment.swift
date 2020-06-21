/**
 * @file	CNEnvironment.swift
 * @brief	Define CNEnvironment class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNEnvironment
{
	private static var	WidthItem	= "WIDTH"
	private static var	HeightItem	= "HEIGHT"
	private static var 	PathItem	= "PATH"

	private var mEnvironmentVariable: Dictionary<String, CNNativeValue>

	public init(){
		mEnvironmentVariable = [
			"TMPDIR"			: CNNativeValue.stringValue(FileManager.default.temporaryDirectory.path),
			"PWD"				: CNNativeValue.stringValue(FileManager.default.currentDirectoryPath),
			CNEnvironment.WidthItem		: CNNativeValue.numberValue(NSNumber(integerLiteral: 80)),
			CNEnvironment.HeightItem	: CNNativeValue.numberValue(NSNumber(integerLiteral: 25))
		]
		setupPath()
	}

	private func setupPath() {
		if let pathstr = ProcessInfo.processInfo.environment[CNEnvironment.PathItem] {
			var patharr: Array<CNNativeValue> = []
			let paths = pathstr.components(separatedBy: ":")
			for path in paths {
				if path.lengthOfBytes(using: .utf8) > 0 {
					patharr.append(.stringValue(path))
				}
			}
			mEnvironmentVariable[CNEnvironment.PathItem] = .arrayValue(patharr)
		}
	}

	public func set(name nm: String, value val: CNNativeValue) {
		mEnvironmentVariable[nm] = val
	}

	public func get(name nm: String) -> CNNativeValue? {
		return mEnvironmentVariable[nm]
	}

	public func setString(name nm: String, value val: String) {
		set(name: nm, value: .stringValue(val))
	}

	public func getString(name nm: String) -> String? {
		if let val = get(name: nm) {
			if let str = val.toString() {
				return str
			}
		}
		return nil
	}

	public func setInt(name nm: String, value val: Int) {
		set(name: nm, value: .numberValue(NSNumber(integerLiteral: val)))
	}

	public func getInt(name nm: String) -> Int? {
		if let val = get(name: nm) {
			if let num = val.toNumber() {
				return num.intValue
			}
		}
		return nil
	}

	public func setURL(name nm: String, value val: URL) {
		set(name: nm, value: .stringValue(val.path))
	}

	public func getURL(name nm: String) -> URL? {
		if let val = get(name: nm) {
			if let str = val.toString() {
				return URL(fileURLWithPath: str)
			}
		}
		return nil
	}

	public func setArray(name nm: String, value val: Array<CNNativeValue>) {
		set(name: nm, value: .arrayValue(val))
	}

	public func getArray(name nm: String) -> Array<CNNativeValue>? {
		if let val = get(name: nm) {
			if let arr = val.toArray() {
				return arr
			}
		}
		return nil
	}

	public var stringVariables: Dictionary<String, String> {
		get {
			var result: Dictionary<String, String> = [:]
			for (key, val) in mEnvironmentVariable {
				if let str = valueToString(value: val) {
					result[key] = str
				} else {
					let desc = val.toText().toStrings(terminal: ",")
					NSLog("Failed to convert value to string: \(desc)")
				}
			}
			return result
		}
	}

	public var currentDirectory: URL {
		get {
			if let url = getURL(name: "PWD") {
				return url
			} else {
				fatalError("Can not happen (1)")
			}
		}
		set(url){
			setURL(name: "PWD", value: url)
		}
	}

	public var temporaryDirectory: URL {
		get {
			if let url = getURL(name: "TMPDIR") {
				return url
			} else {
				fatalError("Can not happen (2)")
			}
		}
		set(url){
			setURL(name: "TMPDIR", value: url)
		}
	}

	public var width: Int {
		get {
			if let val = getInt(name: CNEnvironment.WidthItem) {
				return val
			} else {
				fatalError("Can not happen (3)")
			}
		}
		set(newval){
			setInt(name: CNEnvironment.WidthItem, value: newval)
		}
	}

	public var height: Int {
		get {
			if let val = getInt(name: CNEnvironment.HeightItem) {
				return val
			} else {
				fatalError("Can not happen (4)")
			}
		}
		set(newval){
			setInt(name: CNEnvironment.HeightItem, value: newval)
		}
	}

	public var paths: Array<String> {
		get {
			if let arr = getArray(name: CNEnvironment.PathItem) {
				var result: Array<String> = []
				for elm in arr {
					if let str = elm.toString() {
						result.append(str)
					} else {
						NSLog("Invalid array element")
					}
				}
				return result
			}
			return []
		}
		set(paths) {
			var newarr: Array<CNNativeValue> = []
			for path in paths {
				newarr.append(.stringValue(path))
			}
			self.setArray(name:  CNEnvironment.PathItem, value: newarr)
		}
	}

	private func valueToString(value val: CNNativeValue) -> String? {
		let result: String?
		switch val {
		case .numberValue(let num):	result = num.stringValue
		case .stringValue(let str):	result = str
		case .URLValue(let url):	result = url.path
		case .arrayValue(let arr):
			var arrstr: String = ""
			var is1st:  Bool   = true
			for elm in arr {
				if let str = valueToString(value: elm) {
					if is1st {
						is1st  =  false
					} else {
						arrstr += ":"
					}
					arrstr += str
				} else {
					NSLog("Failed to convert to string: \(elm.toText().toStrings(terminal: ","))")
				}
			}
			result = arrstr
		default:
			result = nil
		}
		return result
	}
}

