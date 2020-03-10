/**
 * @file	CNUserDefaults.swift
 * @brief	Define CNUserDefaults class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

extension UserDefaults
{
	public func font(forKey key: String) -> CNFont? {
		if let dict = self.dictionary(forKey: key) {
			if let name = dict["name"] as? String,
			   let size = dict["size"] as? CGFloat {
				return CNFont(name: name, size: size)
			}
		}
		return nil
	}

	public func set(_ font: CNFont, forKey key: String) {
		let name = font.fontName
		let size = font.pointSize
		let dict: [String: Any] = ["name":name, "size":size]
		self.set(dict, forKey: key)
	}
}
