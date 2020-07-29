/**
 * @file	CNScriptApplication.swift
 * @brief	Define CNScriptApplication class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

open class CNScriptableAppicationDelegate: CNApplicationDelegate
{
	open func applicationDidFinishLaunching(_ aNotification: Notification) {
		/* Defailt values */
		let termpref = CNPreference.shared.terminalPreference
		self.setScriptValue(color: termpref.foregroundTextColor, forKey: "foregroundColor")
		self.setScriptValue(color: termpref.backgroundTextColor, forKey: "backgroundColor")

		/* Constant values */
		self.setScriptValue(color: .black, 	forKey: "black")
		self.setScriptValue(color: .blue,  	forKey: "blue")
		self.setScriptValue(color: .red,   	forKey: "red")
		self.setScriptValue(color: .magenta,	forKey: "magenta")
		self.setScriptValue(color: .green,	forKey: "green")
		self.setScriptValue(color: .yellow,	forKey: "yellow")
		self.setScriptValue(color: .white,	forKey: "white")
	}

	open override func setValue(_ value: Any?, forKey key: String) {
		var doset: Bool = false
		switch key {
		case "foregroundColor":
			if let col = value as? CNColor {
				let termpref = CNPreference.shared.terminalPreference
				termpref.foregroundTextColor = col
				doset = true
			}
		case "backgroundColor":
			if let col = value as? CNColor {
				let termpref = CNPreference.shared.terminalPreference
				termpref.backgroundTextColor = col
				doset = true
			}
		default:
			NSLog("Unknown property: \(key)")
			doset = true // Can not check the type
		}
		if(doset){
			super.setValue(value, forKey: key)
		}
	}

	@inline(__always)  private func setScriptValue(value val: CNScriptValue, forKey key: String) {
		super.setValue(val.toObject(), forKey: key)
	}

	@inline(__always)  private func setScriptValue(color col: CNColor, forKey key: String) {
		super.setValue(col, forKey: key)
	}
}
