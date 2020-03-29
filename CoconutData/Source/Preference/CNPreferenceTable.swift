/**
 * @file	CNPrefereceParameter.swift
 * @brief	Define CNPreferenceParameterTable class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

open class CNPreferenceTable
{
	private var mSectionName:	String

	@objc private dynamic var mParameterTable:	NSMutableDictionary

	public init(sectionName name: String){
		mSectionName 	= name
		mParameterTable = NSMutableDictionary(capacity: 32)
	}

	public func path(keyString key: String) -> String {
		return mSectionName + "." + key
	}

	public func set(anyValue val: Any, forKey key: String) {
		mParameterTable.setValue(val, forKey: key)
	}

	public func anyValue(forKey key: String) -> Any? {
		return mParameterTable.value(forKey: key)
	}

	public func set(intValue val: Int, forKey key: String) {
		let num = NSNumber(integerLiteral: val)
		set(anyValue: num, forKey: key)
	}

	public func intValue(forKey key: String) -> Int? {
		if let val = anyValue(forKey: key) as? NSNumber {
			return val.intValue
		} else {
			return nil
		}
	}

	public func storeIntValue(intValue val: Int, forKey key: String) {
		let pathstr = path(keyString: key)
		let num     = NSNumber(integerLiteral: val)
		UserDefaults.standard.set(number: num, forKey: pathstr)
	}

	public func loadIntValue(forKey key: String) -> Int? {
		let pathstr = path(keyString: key)
		if let numobj = UserDefaults.standard.number(forKey: pathstr) {
			return numobj.intValue
		} else {
			return nil
		}
	}

	public func set(urlValue val: URL, forKey key: String) {
		set(anyValue: val, forKey: key)
	}

	public func urlValue(forKey key: String) -> URL? {
		if let val = anyValue(forKey: key) as? URL {
			return val
		} else {
			return nil
		}
	}

	public func storeURLValue(urlValue val: URL, forKey key: String) {
		let pathstr = path(keyString: key)
		UserDefaults.standard.set(val, forKey: pathstr)
	}

	public func loadURLValue(forKey key: String) -> URL? {
		let pathstr = path(keyString: key)
		if let url = UserDefaults.standard.url(forKey: pathstr) {
			return url
		} else {
			return nil
		}
	}

	public func set(fontValue val: CNFont, forKey key: String) {
		set(anyValue: val, forKey: key)
	}

	public func fontValue(forKey key: String) -> CNFont? {
		if let val = anyValue(forKey: key) as? CNFont {
			return val
		} else {
			return nil
		}
	}

	public func storeFontValue(fontValue val: CNFont, forKey key: String) {
		let pathstr = path(keyString: key)
		UserDefaults.standard.set(font: val, forKey: pathstr)
	}

	public func loadFontValue(forKey key: String) -> CNFont? {
		let pathstr = path(keyString: key)
		if let font = UserDefaults.standard.font(forKey: pathstr) {
			return font
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

