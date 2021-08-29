/**
 * @file	CNJSONFile.swift
 * @brief	Extend CNJSONFile class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

import Foundation

public class CNValueFile {
	public enum Result {
		case ok(CNValue)
		case error(NSError)
	}

	public class func read(URL url: URL) -> Result {
		do {
			let data = try Data(contentsOf: url)
			if let str = String.stringFromData(data: data) {
				return read(string: str)
			} else {
				return .error(NSError.parseError(message: "Failed to convert data to string"))
			}
		} catch let err {
			return .error(err as NSError)
		}
	}

	public class func read(file infile: CNFile) -> Result {
		/* Read entire text */
		var text:   String = ""
		var docont: Bool = true
		NSLog("r0")
		while docont {
			switch infile.gets() {
			case .null:
				NSLog("r1")
				break
			case .str(let str):
				NSLog("r2")
				text += str
			case .endOfFile:
				NSLog("r3")
				docont = false
			}
		}
		NSLog("r4")
		/* Parse the text */
		return read(string: text)
	}

	private class func read(string str: String) -> Result {
		let result: Result
		let parser = CNValueParser()
		let err    = parser.parse(source: str)
		switch err {
		case .ok(let value):
			NSLog("r5")
			result = .ok(value)
		case .error(let err):
			NSLog("r6")
			result = .error(NSError.parseError(message: err.description))
		}
		NSLog("r7")
		return result
	}

	public class func write(file outfile: CNFile, nativeValue val: CNValue) -> NSError? {
		let lines = val.toText().toStrings()
		for line in lines {
			outfile.put(string: line + "\n")
		}
		return nil
	}
}

