/**
 * @file	CNEnvironment.swift
 * @brief	Define CNEnvironment class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNEnvironment
{
	private static var	HomeItem	= "HOME"
	private static var	PwdItem		= "PWD"
	private static var	WidthItem	= "WIDTH"
	private static var	HeightItem	= "HEIGHT"
	private static var 	PathItem	= "PATH"

	private var mEnvironmentVariable: Dictionary<String, CNValue>

	public var variableNames: Dictionary<String, CNValue>.Keys {
		get { return mEnvironmentVariable.keys }
	}

	public init(){
		let tpref   = CNPreference.shared.terminalPreference
		mEnvironmentVariable = [
			"TMPDIR"			: CNValue.stringValue(FileManager.default.temporaryDirectory.path),
			"PWD"				: CNValue.stringValue(FileManager.default.currentDirectoryPath),
			CNEnvironment.WidthItem		: CNValue.numberValue(NSNumber(integerLiteral: tpref.width)),
			CNEnvironment.HeightItem	: CNValue.numberValue(NSNumber(integerLiteral: tpref.height))
		]
		setupPath()
	}

	private func setupPath() {
		if let pathstr = ProcessInfo.processInfo.environment[CNEnvironment.PathItem] {
			var patharr: Array<CNValue> = []
			let paths = pathstr.components(separatedBy: ":")
			for path in paths {
				if !path.isEmpty {
					patharr.append(.stringValue(path))
				}
			}
			mEnvironmentVariable[CNEnvironment.PathItem] = .arrayValue(patharr)
		}
	}

	public func set(name nm: String, value val: CNValue) {
		mEnvironmentVariable[nm] = val
	}

	public func get(name nm: String) -> CNValue? {
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
		set(name: nm, value: .URLValue(val))
	}

	public func getURL(name nm: String) -> URL? {
		if let val = get(name: nm) {
			if let url = val.toURL() {
				return url
			} else if let str = val.toString() {
				return URL(fileURLWithPath: str)
			}
		}
		return nil
	}

	public func setArray(name nm: String, value val: Array<CNValue>) {
		set(name: nm, value: .arrayValue(val))
	}

	public func getArray(name nm: String) -> Array<CNValue>? {
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
					let desc = val.toText().toStrings()
					CNLog(logLevel: .error, message: "Failed to convert value to string: \(desc)", atFunction: #function, inFile: #file)
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
				fatalError("Can not happen at function \(#function) in file \(#file)")
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
				fatalError("Can not happen at function \(#function) in file \(#file)")
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
				fatalError("Can not happen at function \(#function) in file \(#file)")
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
				fatalError("Can not happen at function \(#function) in file \(#file)")
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
						CNLog(logLevel: .error, message: "Invalid array element", atFunction: #function, inFile: #file)
					}
				}
				return result
			}
			return []
		}
		set(paths) {
			var newarr: Array<CNValue> = []
			for path in paths {
				newarr.append(.stringValue(path))
			}
			self.setArray(name:  CNEnvironment.PathItem, value: newarr)
		}
	}

	private func valueToString(value val: CNValue) -> String? {
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
					CNLog(logLevel: .error, message: "Failed to convert to string: \(elm.toText().toStrings())", atFunction: #function, inFile: #file)
				}
			}
			result = arrstr
		default:
			result = nil
		}
		return result
	}

	private func valueToDirectory(value val: CNValue) -> URL? {
		var result: URL? = nil
		let fmgr = FileManager.default
		if let url = val.toURL() {
			if fmgr.fileExists(atURL: url) {
				if fmgr.isAccessible(pathString: url.path, accessType: .ReadAccess) {
					result = url
				}
			}
		} else if let path = val.toString() {
			if fmgr.fileExists(atPath: path) {
				if fmgr.isAccessible(pathString: path, accessType: .ReadAccess) {
					result = URL(fileURLWithPath: path, isDirectory: true)
				}
			}
		}
		return result
	}
}

