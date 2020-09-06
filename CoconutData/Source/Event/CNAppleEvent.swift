/**
 * @file	CNAppleEvent.swift
 * @brief	Define CNAppleEvent class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

#if os(OSX)

private var mEventCodeTable: Dictionary<CNEventCode, AEEventClass> = [:]

public enum CNEventCode: String {
	case	absolute		= "abso"
	case	activate		= "actv"
	case	all			= "all "
	case	appleEvent		= "aevt"
	case 	backgroundColor		= "pbcl"
	case	black			= "blak"	// custom
	case	blue			= "blue"	// custom
	case	bool			= "bool"
	case	classType		= "want"
	case	closeDocument		= "clos"
	case	color			= "cRGB"
	case	context			= "ctxt"
	case	core			= "core"
	case	cyan			= "cyan"	// custom
	case	data			= "data"
	case	document		= "docu"
	case	directObject		= "----"
	case	double			= "doub"
	case	errorCount		= "errn"
	case	errorString		= "errs"
	case	falseValue		= "fals"
	case	float			= "sing"
	case	format			= "form"
	case	from			= "from"
	case	getData			= "getd"
	case	green			= "gren"	// custom
	case	index			= "indx"
	case	long			= "long"
	case	magenta			= "mgnt"	// custom
	case	make			= "crel"
	case	misc			= "misc"
	case	object			= "obj "
	case	objectClass		= "kocl"
	case	openApplication		= "oapp"
	case	openDocument		= "odoc"
	case	printDocument		= "pdoc"
	case	property		= "prop"
	case	red			= "red "	// custom
	case	short			= "shor"
	case	signatureClass		= "csig"
	case	subject			= "subj"
	case	terminalHeight		= "thgt"	// custom
	case	terminalWidth		= "twdt"	// custom
	case	text			= "utxt"
	case	trueValue		= "true"
	case	window			= "cwin"
	case	quitApplication		= "quit"
	case	selectData		= "seld"
	case	setData			= "setd"
	case 	textColor		= "ptxc"
	case	white			= "whte"	// custom
	case	yellow			= "yell"

	public func code() -> AEEventClass {
		if let val = mEventCodeTable[self] {
			return val
		} else {
			let newval = CNStringToFourCharCode(self.rawValue)
			mEventCodeTable[self] = newval
			return newval
		}
	}

	public static func descriptionTypeToString(code cd: DescType) -> String {
		var result: String = ""
		for i in 0..<4 {
			let val = (cd >> ((3 - i) * 8)) & 0xff
			if let scalar = UnicodeScalar(val) {
				result.append(Character(scalar))
			} else {
				result.append("?")
			}
		}
		return result
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

