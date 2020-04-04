/**
 * @file	CNEnvironment.swift
 * @brief	Define CNEnvironment class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNEnvironment
{
	private var mEnvironmentVariable: Dictionary<String, String>

	public var variables: Dictionary<String, String> {
		get {
			var result: Dictionary<String, String> = mEnvironmentVariable
			if let _ = mEnvironmentVariable["TMPDIR"] {
				result["TMPDIR"] = FileManager.default.temporaryDirectory.path
			}
			if let _ = mEnvironmentVariable["PWD"] {
				result["PWD"] = FileManager.default.currentDirectoryPath
			}
			return result
		}
	}

	public init(){
		mEnvironmentVariable = [:]
	}

	public func set(name nm: String, string str: String) {
		mEnvironmentVariable[nm] = str
	}

	public func get(name nm: String) -> String? {
		return mEnvironmentVariable[nm]
	}

	public var currentDirectory: URL {
		get {
			if let path = get(name: "PWD") {
				return URL(fileURLWithPath: path)
			} else {
				return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
			}
		}
		set(newdir){
			set(name: "PWD", string: newdir.path)
		}
	}

	public var temporaryDirectory: URL {
		get {
			if let path = get(name: "TMPDIR") {
				return URL(fileURLWithPath: path)
			} else {
				return URL(fileURLWithPath: FileManager.default.temporaryDirectory.path)
			}
		}
		set(newdir){
			set(name: "TMPDIR", string: newdir.path)
		}
	}
}

