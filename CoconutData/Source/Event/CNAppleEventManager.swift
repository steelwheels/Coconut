/**
 * @file	CNAppleEventManager.swift
 * @brief	Define CNAppleEventManager class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)

import AppKit
import Foundation

public class CNAppleEventManager
{
	private static var mSharedManager: CNAppleEventManager? = nil
	public static func shared() -> CNAppleEventManager {
		if let mgr = mSharedManager {
			return mgr
		} else {
			let mgr = CNAppleEventManager()
			mSharedManager = mgr
			return mgr
		}
	}

	private var mAppleEventManager: NSAppleEventManager
	private var mColorTable:	Dictionary<String, CNColor>

	public init() {
		mAppleEventManager = NSAppleEventManager.shared()
		mColorTable	   = [:]

		/* Register color names */
		mColorTable["black"]            = CNColor.black
		mColorTable["red"]              = CNColor.red
		mColorTable["green"]            = CNColor.green
		mColorTable["yellow"]           = CNColor.yellow
		mColorTable["blue"]             = CNColor.blue
		mColorTable["magenta"]          = CNColor.magenta
		mColorTable["cyan"]             = CNColor.cyan
		mColorTable["white"]            = CNColor.white
	}

	public func hasProperty(named name: String) -> Bool {
		if property(forKey: name) != nil {
			return true
		} else {
			CNLog(logLevel: .detail, message: "Inquiry about property: \(name)")
			return false
		}
	}

	public func property(forKey key: String) -> Any? {
		/* Search default color */
		if let col = mColorTable[key] {
			return col
		}
		switch key {
		case "foregroundColor":
			let termpref = CNPreference.shared.terminalPreference
			return termpref.foregroundTextColor
		case "backgroundColor":
			let termpref = CNPreference.shared.terminalPreference
			return termpref.backgroundTextColor
		case "terminalHeight":
			let termpref = CNPreference.shared.terminalPreference
			return NSNumber(integerLiteral: termpref.rowNumber)
		case "terminalWidth":
			let termpref = CNPreference.shared.terminalPreference
			return NSNumber(integerLiteral: termpref.columnNumber)
		default:
			CNLog(logLevel: .error, message: "[Error] Can not get property named: \(key)")
		}
		return nil
	}

	open func setProperty(_ value: Any?, forKey key: String) {
		var hasset: Bool = false
		switch key {
		case "foregroundColor":
			if let col = value as? CNColor {
				let termpref = CNPreference.shared.terminalPreference
				termpref.foregroundTextColor = col
				hasset = true
			}
		case "backgroundColor":
			if let col = value as? CNColor {
				let termpref = CNPreference.shared.terminalPreference
				termpref.backgroundTextColor = col
				hasset = true
			}
		case "terminalHeight":
			if let num = value as? NSNumber {
				let termpref = CNPreference.shared.terminalPreference
				termpref.rowNumber = num.intValue
				hasset = true
			}
		case "terminalWidth":
			if let num = value as? NSNumber {
				let termpref = CNPreference.shared.terminalPreference
				termpref.columnNumber = num.intValue
				hasset = true
			}
		default:
			break
		}
		if !hasset {
			CNLog(logLevel: .error, message: "[Error] Can not set the property named: \(key)")
		}
	}

	public func dump() {
		CNLog(logLevel: .debug, message: "Message from AppleEventManager")
	}
}

#endif // os(OSX)

