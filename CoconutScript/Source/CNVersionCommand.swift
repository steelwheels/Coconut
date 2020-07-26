/**
 * @file	CNVersionCommand.swift
 * @brief	Define CNVersionCommand class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNVersionCommand: NSScriptCommand {
	public override func performDefaultImplementation() -> Any? {
		NSLog("Exec CNVersionCommand")
		let ver = "UT" + CNPreference.shared.systemPreference.version
		return ver as NSString
	}
}

