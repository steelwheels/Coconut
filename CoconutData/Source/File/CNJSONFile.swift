/**
 * @file	CNJSONFile.swift
 * @brief	Extend CNJSONFile class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

import Foundation

public class CNJSONFile {
	public class func readFile(URL url : URL) -> (CNNativeValue?, NSError?) {
		do {
			let data = try Data(contentsOf: url)
			return try read(data: data)
		}
		catch let err  {
			return (nil, err as NSError)
		}
	}

	public class func readFile(file fle : CNFile) -> (CNNativeValue?, NSError?) {
		do {
			return try read(data: fle.getData())
		}
		catch {
			let error = NSError.parseError(message: "Failed to read data from file")
			return (nil, error)
		}
	}

	private class func read(data dat : Data) throws -> (CNNativeValue?, NSError?) {
		let json    = try JSONSerialization.jsonObject(with: dat, options: [])
		let decoder = CNJSONDecoder()
		return decoder.convert(object: json)
	}

	public class func writeFile(URL url: URL, JSONObject srcval: CNNativeValue) -> NSError? {
		do {
			let encoder = CNJSONEncoder()
			let object  = encoder.convert(value: srcval)
			let data = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
			try data.write(to: url)
			return nil
		}
		catch {
			let error = NSError.parseError(message: "Can not write data")
			return error
		}
	}

	public class func writeFile(file fle: CNFile, JSONObject srcval: CNNativeValue) -> NSError? {
		do {
			let encoder = CNJSONEncoder()
			let object  = encoder.convert(value: srcval)
			let data = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
			fle.put(data: data)
			if let newline = String("\n").data(using: .utf8){
				fle.put(data: newline) // Put the last newline
			}
			return nil
		}
		catch {
			let error = NSError.parseError(message: "Can not write data")
			return error
		}
	}
}

