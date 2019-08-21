/*
 * @file	CNPipe.swift
 * @brief	Define CNPipe class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public extension Pipe
{
	/* This method is blocked until the valid data is given.
	 * The return value will be nil when the all data has been read.
	 */
	func read() -> String? {
		let data = self.fileHandleForReading.availableData
		if data.count > 0 {
			return String(data: data, encoding: .utf8)
		} else {
			return nil
		}
	}

	func write(string str: String){
		if let data = str.data(using: .utf8) {
			self.fileHandleForWriting.write(data)
		} else {
			NSLog("Failed to convert data")
		}
	}

	func setReader(handler reader: @escaping (_ str: String) -> Void) {
		self.fileHandleForReading.readabilityHandler = {
			(_ handle: FileHandle) -> Void in
			if let str = String(data: handle.availableData, encoding: String.Encoding.utf8) {
				reader(str)
			} else {
				NSLog("Error decoding data: \(handle.availableData)")
			}
		}
	}

	func setWriter(handler reader: @escaping () -> String?) {
		self.fileHandleForWriting.writeabilityHandler = {
			(_ handle: FileHandle) -> Void in
			if let str = reader() {
				if let data = str.data(using: .utf8) {
					handle.write(data)
				} else {
					NSLog("Error encoding data: \(str)")
				}
			}
		}
	}
}


