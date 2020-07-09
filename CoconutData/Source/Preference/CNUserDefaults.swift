/**
 * @file	CNUserDefaults.swift
 * @brief	Define CNUserDefaults class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

extension UserDefaults
{
	/* Apply default setting. This method will be called from
	 * "applicationWillFinishLaunching" method on AppDelegate object
	 */
	public func applyDefaultSetting() {
		self.set(true, forKey: "NSDisabledDictationMenuItem")
		self.set(true, forKey: "NSDisabledCharacterPaletteMenuItem")
	}

	public func number(forKey key: String) -> NSNumber? {
		if let num = self.object(forKey: key) as? NSNumber {
			return num
		} else {
			return nil
		}
	}

	public func set(number num: NSNumber, forKey key: String) {
		self.set(num, forKey: key)
	}

	public func font(forKey key: String) -> CNFont? {
		if let dict = self.dictionary(forKey: key) {
			if let name = dict["name"] as? String,
			   let size = dict["size"] as? CGFloat {
				return CNFont(name: name, size: size)
			}
		}
		return nil
	}

	public func set(font fnt: CNFont, forKey key: String) {
		let name = fnt.fontName
		let size = fnt.pointSize
		let dict: [String: Any] = ["name":name, "size":size]
		self.set(dict, forKey: key)
	}

	public func dataDictionary(forKey key: String) -> Dictionary<String, Data>? {
		return self.dictionary(forKey: key) as? Dictionary<String, Data>
	}

	public func set(dataDictionary dict: Dictionary<String, Data>, forKey key: String) {
		self.set(dict, forKey: key)
	}

	public func color(forKey key: String) -> CNColor? {
		if let data = self.data(forKey: key) {
			return CNColor.decode(fromData: data)
		} else {
			return nil
		}
	}

	public func set(color col: CNColor, forKey key: String) {
		if let data = col.toData() {
			set(data, forKey: key)
		} else {
			NSLog("\(#file): Failed to encode color")
		}
	}
}
