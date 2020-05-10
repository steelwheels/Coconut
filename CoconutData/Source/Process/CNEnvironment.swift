/**
 * @file	CNEnvironment.swift
 * @brief	Define CNEnvironment class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNEnvironment
{
	private static var	ColmunsItem	= "COLUMNS"
	private static var	LinesItem	= "LINES"


	private var mEnvironmentVariable: Dictionary<String, String>

	public var variables: Dictionary<String, String> {
		get { return mEnvironmentVariable }
	}

	public init(){
		mEnvironmentVariable = [
			"TMPDIR"			: FileManager.default.temporaryDirectory.path,
			"PWD"				: FileManager.default.currentDirectoryPath,
			CNEnvironment.ColmunsItem	: "0",
			CNEnvironment.LinesItem		: "0"
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

	public var columns: Int {
		get {
			if let str = get(name: CNEnvironment.ColmunsItem) {
				if let val = Int(str) {
					return val
				}
			}
			fatalError("Can not happen (3)")
		}
		set(newval){
			set(name: CNEnvironment.ColmunsItem, string: newval.description)
		}
	}

	public var lines: Int {
		get {
			if let str = get(name: CNEnvironment.LinesItem) {
				if let val = Int(str) {
					return val
				}
			}
			fatalError("Can not happen (4)")
		}
		set(newval){
			set(name: CNEnvironment.LinesItem, string: newval.description)
		}
	}
}

