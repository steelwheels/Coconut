/*
 * @file	CNFileHandle.swift
 * @brief	Define CNFileHandle class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

extension FileHandle {
	public func write(string str: String) {
		if let data = str.data(using: .utf8) {
			self.write(data)
		} else {
			NSLog("Failed convert at \(#file):\(#line)")
		}
	}

	public var availableString: String {
		get {
			let data = self.availableData
			if let str = String(data: data, encoding: .utf8) {
				return str
			} else {
				NSLog("Failed convert at \(#file):\(#line)")
				return ""
			}
		}
	}
}
