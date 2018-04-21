/**
 * @file	CNErrorExtension.swift
 * @brief	Extend NSError class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

import Foundation

public enum CNErrorCode {
	case ParseError
	case FileError
	case SerializeError
}

public extension NSError
{
	public class func domain() -> String {
		return "github.com.steelwheels.Canary"
	}
	
	public class func codeToValue(code c: CNErrorCode) -> Int {
		var value : Int = 0
		switch(c){
		case .ParseError:
			value = 1
		case .FileError:
			value = 2
		case .SerializeError:
			value = 3
		}
		return value
	}
	
	public class func errorLocationKey() -> String {
		return "errorLocation"
	}
	
	public class func parseError(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		let error = NSError(domain: self.domain(), code: codeToValue(code: CNErrorCode.ParseError), userInfo: userinfo)
		return error
	}
	
	public class func parseError(message m: String, location l: NSString) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: NSString(string: m), self.errorLocationKey(): l]
		let error = NSError(domain: self.domain(), code: codeToValue(code: CNErrorCode.ParseError), userInfo: userinfo)
		return error
	}
	
	public class func fileError(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		let error = NSError(domain: self.domain(), code: codeToValue(code: CNErrorCode.FileError), userInfo: userinfo)
		return error
	}
	
	public class func fileError(message m: String, location l: NSString) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: NSString(string: m), self.errorLocationKey(): l]
		let error = NSError(domain: self.domain(), code: codeToValue(code: CNErrorCode.FileError), userInfo: userinfo)
		return error
	}
	
	public class func serializeError(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		let error = NSError(domain: self.domain(), code: codeToValue(code: CNErrorCode.SerializeError), userInfo: userinfo)
		return error
	}
	
	public class func serializeError(message m: String, location l: NSString) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: NSString(string: m), self.errorLocationKey(): l]
		let error = NSError(domain: self.domain(), code: codeToValue(code: CNErrorCode.SerializeError), userInfo: userinfo)
		return error
	}
	
	public func toString() -> String {
		let dict : Dictionary = userInfo
		var message = self.localizedDescription
		let lockey : String = NSError.errorLocationKey()
		if let location = dict[lockey] as? String {
			message = message + "in " + location
		}
		return message
	}
}


