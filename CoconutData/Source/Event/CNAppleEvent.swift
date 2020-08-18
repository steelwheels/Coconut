/**
 * @file	CNAppleEvent.swift
 * @brief	Define CNAppleEvent class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public enum CNEventClass: String {
	case	coreEvent		= "core"

	public func code() -> AEEventClass {
		return stringToCode(source: self.rawValue)
	}
}

public enum CNEventID: String {
	case	openApplication		= "oapp"
	case	make			= "crel"
	case	openDocument		= "odoc"
	case	printDocument		= "pdoc"
	case	quitApplication		= "quit"

	public func code() -> AEEventID {
		return stringToCode(source: self.rawValue)
	}
}

private func stringToCode(source src: String) -> FourCharCode {
	var result: UInt32 = 0
	var idx     = src.startIndex
	let end     = src.endIndex
	while idx < end {
		if let ascii = src[idx].asciiValue {
			result = (result << 8) | (UInt32(ascii) & 0xff)
		} else {
			NSLog("Failed to convert to ascrii: \(src)")
		}
		idx = src.index(after: idx)
	}
	return result
}

