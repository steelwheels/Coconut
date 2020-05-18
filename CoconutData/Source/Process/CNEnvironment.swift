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

	private var mEnvironmentVariable: Dictionary<String, String>

	public var variables: Dictionary<String, String> {
		get { return mEnvironmentVariable }
	}

	public init(){
		mEnvironmentVariable = [
			"TMPDIR"			: FileManager.default.temporaryDirectory.path,
			"PWD"				: FileManager.default.currentDirectoryPath,
			CNEnvironment.WidthItem		: "80",
			CNEnvironment.HeightItem	: "25"
		]
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
				fatalError("Can not happen (1)")
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
				fatalError("Can not happen (2)")
			}
		}
		set(newdir){
			set(name: "TMPDIR", string: newdir.path)
		}
	}

	public var width: Int {
		get {
			if let str = get(name: CNEnvironment.WidthItem) {
				if let val = Int(str) {
					return val
				}
			}
			fatalError("Can not happen (3)")
		}
		set(newval){
			set(name: CNEnvironment.WidthItem, string: newval.description)
		}
	}

	public var height: Int {
		get {
			if let str = get(name: CNEnvironment.HeightItem) {
				if let val = Int(str) {
					return val
				}
			}
			fatalError("Can not happen (4)")
		}
		set(newval){
			set(name: CNEnvironment.HeightItem, string: newval.description)
		}
	}
}

