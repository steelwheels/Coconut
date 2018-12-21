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
			var error  : NSError? = nil
			let datap  : NSData?  = NSData(contentsOf: url)
			if let data = datap as Data? {
				let json    = try JSONSerialization.jsonObject(with: data, options: [])
				let decoder = CNJSONDecoder()
				return decoder.convert(object: json)
			} else {
				error = NSError.parseError(message: "Failed to read data from  URL:\(url.absoluteString)")
				return (nil, error)
			}
		}
		catch {
			let error = NSError.parseError(message: "Can not serialize the objet in URL:\(url.absoluteString)")
			return (nil, error)
		}
	}

	public class func writeFile(URL url: URL, JSONObject srcval: CNNativeValue) -> NSError? {
		do {
			if let srcobj = srcval.toAny() as? NSObject {
				let data = try JSONSerialization.data(withJSONObject: srcobj, options: JSONSerialization.WritingOptions.prettyPrinted)
				try data.write(to: url, options: .atomic)
				return nil
			} else {
				return NSError.parseError(message: "Can not confert value")
			}
		}
		catch {
			let error = NSError.parseError(message: "Can not write data into \(url.absoluteString)")
			return error
		}
	}

	public class func serialize(JSONObject srcobj: CNNativeValue) -> (String?, NSError?) {
		do {
			let encoder = CNJSONEncoder()
			let obj     = encoder.convert(value: srcobj)
			let data    = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
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

	public class func unserialize(string src : String) -> (CNNativeValue?, NSError?) {
		do {
			let datap = src.data(using: String.Encoding.utf8, allowLossyConversion: false)
			if let data = datap {
				let json = try JSONSerialization.jsonObject(with: data, options: [])
				let decoder = CNJSONDecoder()
				return decoder.convert(object: json)
			} else {
				let error = NSError.parseError(message: "Can not serialize the objet in URL:\(src)")
				return (nil, error)
			}
		}
		catch {
			let error = NSError.parseError(message: "Can not serialize the objet in URL:\(src)")
			return (nil, error)
		}
	}
}

