/**
 * @file	CNJSONFile.swift
 * @brief	Extend CNJSONFile class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

import Foundation

public class CNNativeValueFile {
	public enum Result {
		case ok(CNNativeValue)
		case error(NSError)
	}

	public class func readFile(URL url : URL) -> Result {
		do {
			let result: Result
			let data = try Data(contentsOf: url)
			if let str = String.stringFromData(data: data) {
				let parser = CNNativeValueParser()
				let err    = parser.parse(source: str)
				switch err {
				case .ok(let value):
					result = .ok(value)
				case .error(let err):
					result = .error(NSError.parseError(message: err.description))
				}
			} else {
				result = .error(NSError.parseError(message: "Not UF8 Format file"))
			}
			return result
		}
		catch let err {
			return .error(err as NSError)
		}
	}

	public class func writeFile(URL url: URL, nativeValue val: CNNativeValue) -> NSError? {
		do {
			let lines = val.toText().toStrings()
			let line  = lines.joined(separator: "\n")
			if let data  = line.data(using: .utf8) {
				try data.write(to: url)
				return nil
			} else {
				return NSError.fileError(message: "Can not convert to data")
			}
		} catch let err {
			return err as NSError
		}
	}
}

