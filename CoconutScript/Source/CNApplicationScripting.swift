/**
 * @file	CNApplicationScripting.swift
 * @brief	Extend NSApplication class for Cocoa Scripting
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

extension NSApplication
{
	public func preference() -> CNPreference {
		NSLog("app: preference")
		return CNPreference.shared
	}
}
