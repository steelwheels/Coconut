/**
 * @file	CNUserDefaults.swift
 * @brief	Define CNUserDefaults class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

extension UserDefaults
{
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
}
