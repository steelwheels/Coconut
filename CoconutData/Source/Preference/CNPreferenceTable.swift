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

	/*
	 * Int
	 */
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

	/*
	 * String
	 */
	public func set(stringValue val: String, forKey key: String) {
		set(anyValue: val, forKey: key)
	}

	public func stringValue(forKey key: String) -> String? {
		if let val = anyValue(forKey: key) as? String {
			return val
		} else {
			return nil
		}
	}

	public func storeStringValue(stringValue val: String, forKey key: String) {
		let pathstr = path(keyString: key)
		UserDefaults.standard.set(val, forKey: pathstr)
	}

	public func loadStringValue(forKey key: String) -> String? {
		let pathstr = path(keyString: key)
		if let path = UserDefaults.standard.string(forKey: pathstr) {
			return path
		} else {
			return nil
		}
	}

	/*
	 * Color
	 */
	public func set(colorValue val: CNColor, forKey key: String) {
		set(anyValue: val, forKey: key)
	}

	public func colorValue(forKey key: String) -> CNColor? {
		if let val = anyValue(forKey: key) as? CNColor {
			return val
		} else {
			return nil
		}
	}

	public func storeColorValue(colorValue val: CNColor, forKey key: String) {
		let pathstr = path(keyString: key)
		UserDefaults.standard.set(color: val, forKey: pathstr)
	}

	public func loadColorValue(forKey key: String) -> CNColor? {
		let pathstr = path(keyString: key)
		if let color = UserDefaults.standard.color(forKey: pathstr) {
			return color
		} else {
			return nil
		}
	}

	/*
	 * Font
	 */
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

	/*
	 * DataDictionary
	 */
	public func set(dataDictionaryValue val: Dictionary<String, Data>, forKey key: String) {
		set(anyValue: val, forKey: key)
	}

	public func dataDictionaryValue(forKey key: String) -> Dictionary<String, Data>? {
		if let val = anyValue(forKey: key) as? Dictionary<String, Data> {
			return val
		} else {
			return nil
		}
	}

	public func storeDataDictionaryValue(dataDictionaryValue val: Dictionary<String, Data>, forKey key: String) {
		let pathstr = path(keyString: key)
		UserDefaults.standard.set(dataDictionary: val, forKey: pathstr)
	}

	public func loadDataDictionaryValue(forKey key: String) -> Dictionary<String, Data>? {
		let pathstr = path(keyString: key)
		if let dict = UserDefaults.standard.dataDictionary(forKey: pathstr) {
			return dict
		} else {
			return nil
		}
	}

	/*
	 * Color Dictionary
	 */
	public func set(colorDictionaryValue val: Dictionary<CNInterfaceStyle, CNColor>, forKey key: String) {
		set(anyValue: val, forKey: key)
	}

	public func colorDictionaryValue(forKey key: String) -> Dictionary<CNInterfaceStyle, CNColor>? {
		if let val = anyValue(forKey: key) as? Dictionary<CNInterfaceStyle, CNColor> {
			return val
		} else {
			return nil
		}
	}

	public func storeColorDictionaryValue(dataDictionaryValue val: Dictionary<CNInterfaceStyle, CNColor>, forKey key: String) {
		let pathstr = path(keyString: key)

		var stddict: Dictionary<String, Data> = [:]
		for (key, value) in val {
			if let data = value.toData() {
				stddict[key.description] = data
			}
		}
		UserDefaults.standard.set(stddict, forKey: pathstr)
	}

	public func loadColorDictionaryValue(forKey key: String) -> Dictionary<CNInterfaceStyle, CNColor>? {
		let pathstr = path(keyString: key)
		if let dict = UserDefaults.standard.dictionary(forKey: pathstr) as? Dictionary<String, Data> {
			var result: Dictionary<CNInterfaceStyle, CNColor> = [:]
			for (key, value) in dict {
				if let style = CNInterfaceStyle.decode(name: key), let col = CNColor.decode(fromData: value) {
					result[style] = col
				} else {
					CNLog(logLevel: .error, message: "Unknown interface: \(key)", atFunction: #function, inFile: #file)
				}
			}
			return result
		} else {
			return nil
		}
	}

	/*
	 * Observer
	 */
	public func addObserver(observer obs: NSObject, forKey key: String) {
		mParameterTable.addObserver(obs, forKeyPath: key, options: [.new], context: nil)
	}

	public func removeObserver(observer obs: NSObject, forKey key: String) {
		mParameterTable.removeObserver(obs, forKeyPath: key)
	}
}

