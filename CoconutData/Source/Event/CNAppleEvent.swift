/**
 * @file	CNAppleEvent.swift
 * @brief	Define CNAppleEvent class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

#if os(OSX)

public enum CNEventClass: String {
	case	coreEvent		= "core"

	public func code() -> AEEventClass {
		return CNStringToFourCharCode(self.rawValue)
	}
}

public enum CNEventID: String {
	case	getData			= "getd"
	case	make			= "crel"
	case	openApplication		= "oapp"
	case	openDocument		= "odoc"
	case	printDocument		= "pdoc"
	case	quitApplication		= "quit"
	case	setData			= "setd"

	public func code() -> AEEventID {
		return CNStringToFourCharCode(self.rawValue)
	}
}

public enum CNEventDescripton: String {
	case	directObject		= "----"
	case	data			= "data"
	case	format			= "form"
	case	objectClass		= "kocl"
	case	selectData		= "seld"
	public func code() -> DescType {
		return CNStringToFourCharCode(self.rawValue)
	}
}

public enum CNEventFormat: String {
	case property			= "prop"

	public static func encode(string str: String) -> CNEventFormat? {
		let result: CNEventFormat?
		switch str {
		case CNEventFormat.property.rawValue:
			result = .property
		default:
			result = nil
		}
		return result
	}
}

public enum CNEventObject: String {
	case rgbColor			= "cRGB"
	case window			= "cwin"
	public func code() -> OSType {
		return CNStringToFourCharCode(self.rawValue)
	}
}

public enum CNEventProperty: String {
	case textColor			= "ptxc"
	case backgroundColor		= "pbcl"
	public func code() -> OSType {
		return CNStringToFourCharCode(self.rawValue)
	}
}

public enum CNEventResult: String {
	case errorCount			= "errn"
	case errorString		= "errs"
	public func code() -> DescType {
		return CNStringToFourCharCode(self.rawValue)
	}
}

public func CNStringToFourCharCode(_ src: String) -> FourCharCode {
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

#endif // os(OSX)

