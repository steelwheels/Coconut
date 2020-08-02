/**
 * @file	CNScriptDefinition.swift
 * @brief	Define CNScriptDefinition class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNScriptDefinition
{
	public enum ReadResult {
		case ok(CNScriptDefinition)
		case error(NSError)
	}

	public var suiteDefinitions: Array<CNSuiteDefinition>

	public init() {
		suiteDefinitions = []
	}

	public func toText() -> CNTextSection {
		let text = CNTextSection()
		text.header = "{" ; text.footer = "}"
		for suite in suiteDefinitions {
			text.add(text: suite.toText())
		}
		return text
	}
}

open class CNElementDefinition
{
	public var name: 		String?
	public var code: 		String?
	public var description:		String?

	public init(){
		name		= nil
		code		= nil
		description	= nil
	}

	public func toText() -> CNTextSection {
		fatalError("Override this method")
	}

	public func toTextSection(name nm: String) -> CNTextSection {
		let text = CNTextSection()
		text.header = "\(nm): {" ; text.footer = "}"
		if let nm = name {
			let line = CNTextLine(string: "name: \(nm)")
			text.add(text: line)
		}
		if let cd = code {
			let line = CNTextLine(string: "code: \(cd)")
			text.add(text: line)
		}
		if let desc = description {
			let line = CNTextLine(string: "description: \(desc)")
			text.add(text: line)
		}
		return text
	}
}

public class CNSuiteDefinition: CNElementDefinition
{
	public var elementDefinitions: Array<CNElementDefinition>

	public override init() {
		elementDefinitions	= []
		super.init()
	}

	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "suite")
		for cmd in elementDefinitions {
			let cmdtxt = cmd.toText()
			text.add(text: cmdtxt)
		}
		return text
	}
}

public class CNClassDefinition: CNElementDefinition
{
	public var className:	String?
	public var properties:	Array<CNPropertyDefinition>

	public override init(){
		className  = nil
		properties = []
		super.init()
	}

	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "class")
		if let val = className {
			let line = CNTextLine(string: "className: \(val)")
			text.add(text: line)
		}
		return text
	}
}

public class CNPropertyDefinition: CNElementDefinition
{
	public var type: 	String?
	public var cocoaKey:	String?

	public override init() {
		type 		= nil
		cocoaKey	= nil
		super.init()
	}

	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "class")
		if let val = type {
			let line = CNTextLine(string: "type: \(val)")
			text.add(text: line)
		}
		if let val = cocoaKey {
			let line = CNTextLine(string: "cocoaKey: \(val)")
			text.add(text: line)
		}
		return text
	}
}

public class CNCommandDefinition: CNElementDefinition
{
	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "command")
		return text
	}
}

public class CNEnumerationDefinition: CNElementDefinition
{
	public var elements: Array<CNEnumeratorDefinition>

	public override init() {
		elements = []
	}

	public override func toText() -> CNTextSection {
		let text = CNTextSection()
		text.header = "enum: {" ; text.footer = "}"
		for elm in elements {
			let line = elm.toText()
			text.add(text: line)
		}
		return text
	}
}

public class CNEnumeratorDefinition: CNElementDefinition
{
	public override func toText() -> CNTextSection {
		let text = super.toTextSection(name: "enumerator")
		return text
	}
}

