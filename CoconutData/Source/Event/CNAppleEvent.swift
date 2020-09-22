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
	case	outgoingMessage		= "bcke"	// Mail.app
	case	black			= "blak"	// custom
	case	blue			= "blue"	// custom
	case	bool			= "bool"
	case	application		= "capp"
	case	closeDocument		= "clos"
	case	color			= "cRGB"
	case	content			= "ctnt"
	case	context			= "ctxt"
	case	core			= "core"
	case	make			= "crel"
	case	signatureClass		= "csig"
	case	windowTab		= "cTab"
	case	window			= "cwin"
	case	cyan			= "cyan"	// custom
	case	data			= "data"
	case	document		= "docu"
	case	directObject		= "----"
	case	double			= "doub"
	case	errorCount		= "errn"
	case	errorString		= "errs"
	case	falseValue		= "fals"
	case	format			= "form"
	case	from			= "from"
	case	fileType		= "fltp"
	case	float			= "sing"
	case	getData			= "getd"
	case	green			= "gren"	// custom
	case	index			= "indx"
	case	insertHere		= "insh"
	case	file 			= "kfil"
	case	objectClass		= "kocl"
	case	long			= "long"
	case	magenta			= "mgnt"	// custom
	case	misc			= "misc"
	case	openApplication		= "oapp"
	case	object			= "obj "
	case	openDocument		= "odoc"
	case 	backgroundColor		= "pbcl"
	case	printDocument		= "pdoc"
	case	name			= "pnam"
	case	propertyData		= "prdt"
	case	property		= "prop"
	case 	textColor		= "ptxc"
	case	urlProperty		= "pURL"
	case	visible			= "pvis"
	case	quitApplication		= "quit"
	case	red			= "red "	// custom
	case	saveDocument		= "save"
	case	selectData		= "seld"
	case	setData			= "setd"
	case	short			= "shor"
	case	sender			= "sndr"
	case	subject			= "subj"
	case	tab			= "tab "
	case	terminalHeight		= "thgt"	// custom
	case	trueValue		= "true"
	case	messageSignature	= "trng"
	case	terminalWidth		= "twdt"	// custom
	case	text			= "utxt"
	case	version			= "vers"
	case	classType		= "want"
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
			CNLog(logLevel: .error, message: "Failed to convert to ascrii: \(src)")
		}
		idx = src.index(after: idx)
	}
	return result
}

#endif // os(OSX)

