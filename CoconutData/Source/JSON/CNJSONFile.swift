/**
 * @file	CNJSONFile.swift
 * @brief	Extend CNJSONFile class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

import Foundation

public class CNJSONFile {
	public class func readFile(URL url : URL) -> (CNJSONObject?, NSError?) {
		do {
			var result : CNJSONObject?  = nil
			var error  : NSError?       = nil
			let datap  : NSData?        = NSData(contentsOf: url)
			if let data = datap as Data? {
				let json = try JSONSerialization.jsonObject(with: data, options: [])
				if let dict = json as? NSDictionary {
					result = CNJSONObject(dictionary: dict)
				} else if let arr = json as? NSArray {
					result = CNJSONObject(array: arr)
				} else {
					error = NSError.parseError(message: "The data type is NOT dictionary in URL:\(url.absoluteString)")
				}
			} else {
				error = NSError.parseError(message: "Failed to read data from  URL:\(url.absoluteString)")
			}
			return (result, error)
		}
		catch {
			let error = NSError.parseError(message: "Can not serialize the objet in URL:\(url.absoluteString)")
			return (nil, error)
		}
	}

	public class func writeFile(URL url: URL, JSONObject srcobj: CNJSONObject) -> NSError? {
		do {
			let data = try JSONSerialization.data(withJSONObject: srcobj.toObject(), options: JSONSerialization.WritingOptions.prettyPrinted)
			try data.write(to: url, options: .atomic)
			return nil
		}
		catch {
			let error = NSError.parseError(message: "Can not write data into \(url.absoluteString)")
			return error
		}
	}

	public class func serialize(JSONObject srcobj: CNJSONObject) -> (String?, NSError?) {
		do {
			let data = try JSONSerialization.data(withJSONObject: srcobj.toObject(), options: .prettyPrinted)
			let strp  = String(data: data, encoding: String.Encoding.utf8)
			if let str = strp {
				return (str, nil)
			} else {
				let error = NSError.parseError(message: "Can not translate into string")
				return (nil, error)
			}
		}
		catch {
			let error = NSError.parseError(message: "Can not serialize")
			return (nil, error)
		}
	}

	public class func unserialize(string src : String) -> (CNJSONObject?, NSError?) {
		do {
			var result : CNJSONObject? = nil
			var error  : NSError?      = nil
			let datap = src.data(using: String.Encoding.utf8, allowLossyConversion: false)
			if let data = datap {
				let json = try JSONSerialization.jsonObject(with: data, options: [])
				if let dict = json as? NSDictionary {
					result = CNJSONObject(dictionary: dict)
				} else if let arr = json as? NSArray {
					result = CNJSONObject(array: arr)
				} else {
					error = NSError.parseError(message: "The data type is NOT dictionary in URL:\(src)")
				}
			}
			return (result, error)
		}
		catch {
			let error = NSError.parseError(message: "Can not serialize the objet in URL:\(src)")
			return (nil, error)
		}
	}
}
