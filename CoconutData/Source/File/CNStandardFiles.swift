/*
 * @file	CNStandardFiles.swift
 * @brief	Define CNStandardFiles class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNStandardFiles
{
	private static var mStandardFiles: CNStandardFiles? = nil

	public static var shared: CNStandardFiles {
		get {
			if let files = mStandardFiles {
				return files
			} else {
				let newfiles   = CNStandardFiles()
				mStandardFiles = newfiles
				return newfiles
			}
		}
	}

	public var input:   CNFile
	public var output:  CNFile
	public var error:   CNFile

	private init() {
		input  = CNFile(access: .reader, fileHandle: FileHandle.standardInput)
		output = CNFile(access: .writer, fileHandle: FileHandle.standardOutput)
		error  = CNFile(access: .writer, fileHandle: FileHandle.standardError)
	}
}

