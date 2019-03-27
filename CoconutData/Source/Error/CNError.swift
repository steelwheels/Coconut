/**
 * @file	CNErrorExtension.swift
 * @brief	Extend NSError class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

import Foundation

public enum CNErrorCode: Int {
	case Information	= 0
	case InternalError	= 1
	case ParseError		= 2
	case FileError		= 3
	case SerializeError	= 4
	case UnknownError	= 5
}

public extension NSError
{
	class func domain() -> String {
		return "github.com.steelwheels.Coconut"
	}
	
	class func errorLocationKey() -> String {
		return "errorLocation"
	}

	class func informationNotice(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		let error = NSError(domain: self.domain(), code: CNErrorCode.Information.rawValue, userInfo: userinfo)
		return error
	}

	class func internalError(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		let error = NSError(domain: self.domain(), code: CNErrorCode.InternalError.rawValue, userInfo: userinfo)
		return error
	}

	class func internalError(message m: String, location l: NSString) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: NSString(string: m), self.errorLocationKey(): l]
		let error = NSError(domain: self.domain(), code: CNErrorCode.InternalError.rawValue, userInfo: userinfo)
		return error
	}

	class func parseError(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		let error = NSError(domain: self.domain(), code: CNErrorCode.ParseError.rawValue, userInfo: userinfo)
		return error
	}
	
	class func parseError(message m: String, location l: NSString) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: NSString(string: m), self.errorLocationKey(): l]
		let error = NSError(domain: self.domain(), code: CNErrorCode.ParseError.rawValue, userInfo: userinfo)
		return error
	}
	
	class func fileError(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		let error = NSError(domain: self.domain(), code: CNErrorCode.FileError.rawValue, userInfo: userinfo)
		return error
	}
	
	class func fileError(message m: String, location l: NSString) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: NSString(string: m), self.errorLocationKey(): l]
		let error = NSError(domain: self.domain(), code: CNErrorCode.FileError.rawValue, userInfo: userinfo)
		return error
	}
	
	class func serializeError(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		let error = NSError(domain: self.domain(), code: CNErrorCode.SerializeError.rawValue, userInfo: userinfo)
		return error
	}
	
	class func serializeError(message m: String, location l: NSString) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: NSString(string: m), self.errorLocationKey(): l]
		let error = NSError(domain: self.domain(), code: CNErrorCode.SerializeError.rawValue, userInfo: userinfo)
		return error
	}

	var errorCode: CNErrorCode {
		get {
			if let ecode = CNErrorCode(rawValue: self.code) {
				return ecode
			} else {
				return .UnknownError
			}
		}
	}

	func toString() -> String {
		let dict : Dictionary = userInfo
		var message = self.localizedDescription
		let lockey : String = NSError.errorLocationKey()
		if let location = dict[lockey] as? String {
			message = message + "in " + location
		}
		return message
	}
}


