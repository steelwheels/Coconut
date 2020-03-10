/**
 * @file	CNPrefereceParameter.swift
 * @brief	Define CNPreferenceParameterTable class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

open class CNPreferenceTable
{
	@objc private dynamic var mParameterTable:	NSMutableDictionary

	public init(){
		mParameterTable = NSMutableDictionary(capacity: 32)
	}

	public func _set(anyValue val: Any, forKey key: String) {
		mParameterTable.setValue(val, forKey: key)
	}

	public func _anyValue(forKey key: String) -> Any? {
		return mParameterTable.value(forKey: key)
	}

	public func set(intValue val: Int, forKey key: String) {
		let num = NSNumber(integerLiteral: val)
		_set(anyValue: num, forKey: key)
	}

	public func intValue(forKey key: String) -> Int? {
		if let val = _anyValue(forKey: key) as? NSNumber {
			return val.intValue
		} else {
			return nil
		}
	}

	public func set(fontValue val: CNFont, forKey key: String) {
		_set(anyValue: val, forKey: key)
	}

	public func fontValue(forKey key: String) -> CNFont? {
		if let val = _anyValue(forKey: key) as? CNFont {
			return val
		} else {
			return nil
		}
	}

	public func addObserver(observer obs: NSObject, forKey key: String) {
		mParameterTable.addObserver(obs, forKeyPath: key, options: [.new], context: nil)
	}

	public func removeObserver(observer obs: NSObject, forKey key: String) {
		mParameterTable.removeObserver(obs, forKeyPath: key)
	}
}

