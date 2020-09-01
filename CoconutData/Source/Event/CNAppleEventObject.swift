/**
 * @file	CNAppleEventObject.swift
 * @brief	Define CNAppleEventObject class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

#if os(OSX)

public enum CNEventObjectType {
	case	property
	case	window

	public var description: String {
		get {
			let result: String
			switch self {
			case .property:	result = "property"
			case .window:	result = "window"
			}
			return result
		}
	}
}

public enum CNEventSelector {
	case	osType(OSType)
	case	value(CNValue)
	
	public var description: String {
		get {
			let result: String
			switch self {
			case .osType(let type):
				let typestr = CNEventCode.descriptionTypeToString(code: type)
				result = "osType(\(typestr))"
			case .value(let val):
				result = "value(\(val.description))"
			}
			return result
		}
	}
}

public class CNEventObject
{
	public var	type:			CNEventObjectType
	public var	selector:		CNEventSelector
	public var	referenceObject:	CNEventObject?

	public init(type typ: CNEventObjectType, selector sel: CNEventSelector, reference ref: CNEventObject?) {
		type		= typ
		selector	= sel
		referenceObject	= ref
	}

	public var description: String {
		get {
			let typestr = type.description
			let selstr  = selector.description
			let refstr: String
			if let ref = referenceObject {
				refstr = ref.description
			} else {
				refstr = "nil"
			}
			return "object: {type=\(typestr), selector=\(selstr), reference=\(refstr)}"
		}
	}
}

public enum CNEventPreference
{
	case	foregroundColor
	case	backgroundColor
	case	terminalHeight
	case	terminalWidth

	public var description: String {
		get {
			var name: String
			switch self {
			case .foregroundColor:	name = "foregroundColor"
			case .backgroundColor:	name = "backgroundColor"
			case .terminalHeight:	name = "terminalHeight"
			case .terminalWidth:	name = "terminalWidth"
			}
			return "pointer:{ \(name) }"
		}
	}
}

public enum CNEventIndex
{
	case	none
	case	id(Int)
	case	name(String)

	public var description: String {
		get {
			let result: String
			switch self {
			case .none:		result = ""
			case .id(let val):	result = "id(\(val))"
			case .name(let val):	result = "name(\(val))"
			}
			return result
		}
	}
}

public enum CNEventParameter {
	case preference(CNEventPreference)
	case window(CNEventIndex)
	case value(CNValue)
	case color(CNColor)

	public func toDescriptor() -> NSAppleEventDescriptor? {
		let result: NSAppleEventDescriptor?
		switch self {
		case .preference(_):	result = nil
		case .window(_):	result = nil
		case .value(let val):	result = val.toEventDescriptor()
		case .color(let col):	result = col.toEventDescriptor()
		}
		return result
	}

	public var description: String {
		get {
			let result: String
			switch self {
			case .value(let val):
				result = "value:{ \(val.description) }"
			case .color(let color):
				result = "color:{ \(color.description) }"
			case .window(let index):
				result = "window:{ \(index.description)}"
			case .preference(let pref):
				result = pref.description
			}
			return result
		}
	}
}

public enum CNEventImmediate {
	case	value(CNValue)
	case	color(CNColor)

	public func toInt() -> Int? {
		let result: Int?
		switch self {
		case .color(_):
			result = nil
		case .value(let val):
			switch val.type {
			case .IntType:	result = val.intValue
			default:	result = nil
			}
		}
		return result
	}

	public func toColor() -> CNColor? {
		switch self {
		case .color(let col):	return col
		case .value(_):		return nil
		}
	}
}

public enum CNEventMakeTarget {
	case window
}

extension CNValue
{
	public func toEventDescriptor() -> NSAppleEventDescriptor? {
		var result: NSAppleEventDescriptor? = nil
		switch self.type {
		case .VoidType:
			result = nil
		case .BooleanType:
			if let val = self.booleanValue {
				result = NSAppleEventDescriptor(boolean: val)
			}
		case .CharacterType:
			if let val = self.characterValue {
				result = NSAppleEventDescriptor(string: String(val))
			}
		case .IntType:
			if let val = self.intValue {
				result = NSAppleEventDescriptor(int32: Int32(val))
			}
		case .UIntType:
			if let val = self.uIntValue {
				result = NSAppleEventDescriptor(int32: Int32(val))
			}
		case .FloatType:
			if let val = self.floatValue {
				result = NSAppleEventDescriptor(double: Double(val))
			}
		case .DoubleType:
			if let val = self.doubleValue {
				result = NSAppleEventDescriptor(double: val)
			}
		case .StringType:
			if let val = self.stringValue {
				result = NSAppleEventDescriptor(string: val)
			}
		case .URLType:
			if let val = self.URLValue {
				result = NSAppleEventDescriptor(fileURL: val)
			}
		case .DateType:
			if let val = self.dateValue {
				result = NSAppleEventDescriptor(date: val)
			}
		case .ArrayType:
			if let srcarr = self.arrayValue {
				let newarr = NSAppleEventDescriptor.list()
				var idx    = 1
				for srcelm in srcarr {
					if let srcdesc = srcelm.toEventDescriptor() {
						newarr.insert(srcdesc, at: idx)
						idx += 1
					}
				}
				result = newarr
			}
		case .DictionaryType:
			if let srcdict = self.dictionaryValue {
				let newdict = NSAppleEventDescriptor.record()
				for (srcname, srcelm) in srcdict {
					if let srcdesc = srcelm.toEventDescriptor() {
						let keyword: AEKeyword = CNStringToFourCharCode(srcname)
						newdict.setParam(srcdesc, forKeyword: keyword)
					}
				}
				result = newdict
			}
		}
		return result
	}
}

#endif // os(OSX)

