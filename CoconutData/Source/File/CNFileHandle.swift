/*
 * @file	CNFileHandle.swift
 * @brief	Define CNFileHandle class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation
import Darwin.POSIX.termios
import Darwin

extension FileHandle
{
	public func write(string str: String) {
		if let data = str.data(using: .utf8) {
			self.write(data)
		} else {
			CNLog(logLevel: .error, message: "Failed to convert", atFunction: #function, inFile: #file)
		}
	}

	public var availableString: String {
		get {
			let data = self.availableData
			if let str = String.stringFromData(data: data) {
				return str
			} else {
				CNLog(logLevel: .error, message: "Failed to convert", atFunction: #function, inFile: #file)
				return ""
			}
		}
	}
}

