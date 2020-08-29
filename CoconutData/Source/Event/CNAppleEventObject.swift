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

	public var description: String {
		get {
			var name: String
			switch self {
			case .foregroundColor:	name = "foregroundColor"
			case .backgroundColor:	name = "backgroundColor"
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
	case color(CNColor)

	public func toDescriptor() -> NSAppleEventDescriptor? {
		let result: NSAppleEventDescriptor?
		switch self {
		case .preference(_):	result = nil
		case .window(_):	result = nil
		case .color(let col):	result = col.toEventDescriptor()
		}
		return result
	}

	public var description: String {
		get {
			let result: String
			switch self {
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

public enum CNEventMakeTarget {
	case window
}

#endif // os(OSX)

