/**
 * @file	CNScriptDefinition.swift
 * @brief	Define CNScriptDefinition class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import ScriptingBridge
import Foundation

public class CNScriptDefinition
{
	public enum ReadResult {
		case ok(CNScriptDefinition)
		case error(NSError)
	}

	public var title:	String?
	public var contents:	Array<CNSuiteDefinition>

	public init() {
		title		= nil
		contents	= []
	}

	public func toText() -> CNTextSection {
		let text = CNTextSection()
		text.header = "{" ; text.footer = "}"
		for suite in contents {
			text.add(text: suite.toText())
		}
		return text
	}

	public static func normalize(string str: String) -> String {
		var result   = ""
		var idx      = str.startIndex
		let end      = str.endIndex
		var hasspace = false
		while idx < end {
			let c = str[idx]
			if !c.isWhitespace {
				if hasspace {
					result.append(contentsOf: c.uppercased())
				} else {
					result.append(c)
				}
				hasspace = false
			} else {
				hasspace = true
			}
			idx = str.index(after: idx)
		}
		return result
	}
}

open class CNBaseDefinition
{
	public enum DataType {
		case	any
		case	text
		case	integer
		case	real
		case	number
		case	boolean
		case	specifier
		case	locationSpecifier
		case	record
		case	date
		case	file
		case	rectangle
		case	other(String)

		public func toString() -> String {
			let result: String
			switch self {
			case .any:			result = "any"
			case .text:			result = "text"
			case .integer:			result = "integer"
			case .real:			result = "real"
			case .number:			result = "number"
			case .boolean:			result = "boolean"
			case .specifier:		result = "specifier"
			case .locationSpecifier:	result = "locationSpecifier"
			case .record:			result = "record"
			case .date:			result = "date"
			case .file:			result = "file"
			case .rectangle:		result = "rectangle"
			case .other(let str):		result = str
			}
			return result
		}

		public func toSwiftType() -> String {
			let result: String
			switch self {
			case .any:			result = "Any"
			case .text:			result = "String"
			case .integer:			result = "Int"
			case .real:			result = "Double"
			case .number:			result = "NSNumber"
			case .boolean:			result = "Bool"
			case .specifier:		result = "specifier"
			case .locationSpecifier:	result = "locationSpecifier"
			case .record:			result = "record"
			case .date:			result = "Date"
			case .file:			result = "file"
			case .rectangle:		result = "NSRect"
			case .other(let str):		result = str
			}
			return result
		}

		public static func decode(string str: String) -> DataType {
			var result: DataType
			switch str {
			case "any":			result = .any
			case "text":			result = .text
			case "integer":			result = .integer
			case "real":			result = .real
			case "number":			result = .number
			case "boolean":			result = .boolean
			case "specifier":		result = .specifier
			case "locationSpecifier":	result = .locationSpecifier
			case "record":			result = .record
			case "date":			result = .date
			case "file":			result = .file
			case "rectangle":		result = .rectangle
			default:			result = .other(CNScriptDefinition.normalize(string: str))
			}
			return result
		}

		public static func encode(type tp: DataType?) -> String {
			if let t = tp {
				return t.toString()
			} else {
				return DataType.any.toString()
			}
		}

	}

	public enum AccessType {
		case read
		case write
		case read_write

		public func toString() -> String {
			let result: String
			switch self {
			case .read:		result = "read"
			case .write:		result = "write"
			case .read_write:	result = "read_write"
			}
			return result
		}

		public static func decode(string str: String) -> AccessType? {
			let result: AccessType?
			switch str {
			case "r":	result = .read
			case "w":	result = .write
			case "rw":	result = .read_write
			default:	result = nil
			}
			return result
		}
	}

	public var name: 		String?
	public var idString:		String?
	public var code: 		String?
	public var type:		DataType
	public var description:		String?
	public var hidden:		Bool

	public init(){
		name		= nil
		idString	= nil
		code		= nil
		type		= .any
		description	= nil
		hidden		= false
	}

	public func toText() -> CNTextSection {
		fatalError("Override this method")
	}

	public func toTextSection(name nm: String) -> CNTextSection {
		let text = CNTextSection()
		text.header = "\(nm): {" ; text.footer = "}"
		addAttributeToText(name: "name",	value: self.name, to: text)
		addAttributeToText(name: "code",	value: self.code, to: text)
		addAttributeToText(name: "description",	value: self.description, to: text)
		return text
	}

	public func addAttributeToText(name nm: String, value val: String?, to text: CNTextSection) {
		if let v = val {
			let line = CNTextLine(string: "\(nm): \(v)")
			text.add(text: line)
		}
	}

	public func addAttributeToText(name nm: String, accessType access: AccessType?, to text: CNTextSection) {
		let accstr: String
		if let acc = access {
			accstr = acc.toString()
		} else {
			accstr = "rw"
		}
		self.addAttributeToText(name: nm, value: accstr, to: text)
	}
}

open class CNContainerDefinition: CNBaseDefinition
{
	public var contents: Array<CNBaseDefinition>

	public override init() {
		contents = []
		super.init()
	}

	public override func toTextSection(name nm: String) -> CNTextSection {
		let text = super.toTextSection(name: nm)
		for elm in contents {
			let line = elm.toText()
			text.add(text: line)
		}
		return text
	}
}

public class CNSuiteDefinition: CNContainerDefinition
{
	public override init() {
		super.init()
	}

	public override func toText() -> CNTextSection {
		return super.toTextSection(name: "suite")
	}
}

public class CNClassDefinition: CNContainerDefinition
{
	public var isExtension:	Bool
	public var className:	String?
	private var mPlural:	String?

	public init(isExtension isext: Bool){
		isExtension	= isext
		className	= nil
		mPlural		= nil
		super.init()
	}

	public var plural: String? {
		set(newval){
			mPlural = newval
		}
		get {
			if let p = mPlural {
				return p
			} else if let n = self.name {
				return n + "s"
			} else {
				return nil
			}
		}
	}

	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "class")
		super.addAttributeToText(name: "className", value: className, to: text)
		return text
	}
}

public class CNPropertyDefinition: CNBaseDefinition
{
	public var access:	AccessType?

	public override init() {
		access		= nil
		super.init()
	}

	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "property")
		addAttributeToText(name: "access", accessType: self.access, to: text)
		return text
	}
}

public class CNContentsDefinition: CNBaseDefinition {
	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "contents")
		return text
	}
}

public class CNSynonymDefinition: CNBaseDefinition {
	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "synonym")
		return text
	}
}

public class CNRecordTypeDefinition: CNContainerDefinition {
	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "record-type")
		return text
	}
}

public class CNValueTypeDefinition: CNContainerDefinition {

	public var className: String? { get {
		for elm in self.contents {
			if let cocoadef = elm as? CNCocoaDefinition {
				return cocoadef.className
			}
		}
		return nil
	}}

	public var keyName: String? { get {
		for elm in self.contents {
			if let cocoadef = elm as? CNCocoaDefinition {
				return cocoadef.keyName
			}
		}
		return nil
	}}

	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "value-type")
		return text
	}
}

public class CNTypeDefinition: CNBaseDefinition {
	public var isList:	Bool

	public override init() {
		isList = false
		super.init()
	}

	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "type")
		return text
	}
}

public class CNCommandDefinition: CNContainerDefinition
{
	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "command")
		return text
	}
}

public class CNElementDefinition: CNContainerDefinition {
	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "element")
		return text
	}
}

public class CNRespondsToDefinition: CNContainerDefinition {
	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "responds-to")
		return text
	}
}

public class CNCocoaDefinition: CNBaseDefinition
{
	public var className:		String?
	public var keyName:		String?
	public var methodName:		String?

	public override init(){
		className	= nil
		keyName		= nil
		methodName	= nil
		super.init()
	}

	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "cocoa")
		super.addAttributeToText(name: "class",  value: className,  to: text)
		super.addAttributeToText(name: "key",    value: keyName,    to: text)
		super.addAttributeToText(name: "method", value: methodName, to: text)
		return text
	}
}

public class CNAccessGroupDefinition: CNBaseDefinition
{
	public var identifier:		String?
	public var access:		AccessType?

	public override init(){
		identifier	= nil
		access		= nil
		super.init()
	}

	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "access-group")
		super.addAttributeToText(name: "identifier", value: identifier,  to: text)
		super.addAttributeToText(name: "access",     accessType: access, to: text)
		return text
	}
}

public class CNParameterDefinition: CNBaseDefinition
{
	public override func toText() -> CNTextSection {
		return super.toTextSection(name: "parameter")
	}
}

public class CNDirectParameterDefinition: CNBaseDefinition
{
	public override func toText() -> CNTextSection {
		return super.toTextSection(name: "direct-parameter")
	}
}

public class CNResultDefinition: CNBaseDefinition
{
	public override func toText() -> CNTextSection {
		return super.toTextSection(name: "result")
	}
}

public class CNEnumerationDefinition: CNBaseDefinition
{
	public var contents: Array<CNEnumeratorDefinition>

	public override init() {
		contents = []
	}

	public override func toText() -> CNTextSection {
		let text = CNTextSection()
		text.header = "enum: {" ; text.footer = "}"
		for elm in contents {
			let line = elm.toText()
			text.add(text: line)
		}
		return text
	}
}

public class CNEnumeratorDefinition: CNBaseDefinition
{
	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "enumerator")
		return text
	}
}

