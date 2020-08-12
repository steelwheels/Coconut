/**
 * @file	CNScriptCoder.swift
 * @brief	Define CNScriptCoder class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNScriptCoder
{
	private var mConsole:	CNConsole

	public init(console cons: CNConsole) {
		mConsole = cons
	}

	public func encode(className clsname: String, scriptDefinition scrdef: CNScriptDefinition) -> CNTextSection {
		let text = CNTextSection()

		let lines = encodeHeader(className: clsname)
		text.add(multiText: lines)

		let clstext = CNTextSection()
		clstext.header = "public class \(clsname) {"
		clstext.footer = "}"
		text.add(text: clstext)

		for suite in scrdef.contents {
			let subtxt = encode(suiteDefinition: suite)
			clstext.add(text: subtxt)
		}

		return text
	}

	private func encodeHeader(className name: String) -> Array<CNTextLine> {
		let lines : Array<String> =  ["/*",
					      " * @file \(name).swift",
					      " * @par Copyright",
					      " *   Copyright (C) 2020 Steel Wheels Project",
					      " */"]
		var result: Array<CNTextLine> = []
		for line in lines {
			let txt = CNTextLine(string: line)
			result.append(txt)
		}
		return result
	}

	private func encode(suiteDefinition suite: CNSuiteDefinition) -> CNText {
		let newsect = CNTextSection()
		let header : Array<String> = ["/* suite: \(String(describing: suite.name))",
					      " * code:  \(String(describing: suite.code))",
					      " */"]
		for line in header {
			newsect.add(string: line)
		}

		for elm in suite.contents {
			let elmtxt: CNText?
			if let elmdef = elm as? CNAccessGroupDefinition {
				elmtxt = encode(accessGroupDefinition: elmdef)
			} else if let clsdef = elm as? CNClassDefinition {
				elmtxt = encode(classDefinition: clsdef)
			} else if let cmddef = elm as? CNCommandDefinition {
				elmtxt = encode(commandDefinition: cmddef)
			} else if let enmdef = elm as? CNEnumerationDefinition {
				elmtxt = encode(enumDefinition: enmdef)
			} else if let recdef = elm as? CNRecordTypeDefinition {
				elmtxt = encode(recordTypeDefinition: recdef)
			} else if let valdef = elm as? CNValueTypeDefinition {
				elmtxt = encode(valueTypeDefinition: valdef)
			} else {
				NSLog("Unknown element: \(elm)")
				elmtxt = nil
			}
			if let elm = elmtxt {
				newsect.add(text: elm)
			}
		}
		return newsect
	}

	private func encode(accessGroupDefinition classdef: CNAccessGroupDefinition) -> CNText? {
		return nil
	}

	private func encode(classDefinition classdef: CNClassDefinition) -> CNText? {
		return nil
	}

	private func encode(commandDefinition cmddef: CNCommandDefinition) -> CNText? {
		return nil
	}

	private func encode(enumDefinition enumdef: CNEnumerationDefinition) -> CNText? {
		guard let name = enumdef.name else {
			NSLog("No enum name")
			return nil
		}

		let newsect = CNTextSection()
		let ename   = CNScriptDefinition.normalize(string: name)
		newsect.header = "@objc public enum \(ename) : AEKeyword {"
		newsect.footer = "}"
		for elm in enumdef.contents {
			if let txt = encode(enumElementDefinition: elm) {
				newsect.add(text: txt)
			}
		}
		return newsect
	}

	private func encode(enumElementDefinition enumdef: CNEnumeratorDefinition) -> CNText? {
		guard let name = enumdef.name, let code = enumdef.code else {
			NSLog("No enumeration name")
			return nil
		}
		let ename = CNScriptDefinition.normalize(string: name)
		let value = NSAppleEventDescriptor.codeValue(code: code)
		let decl  = "case \(ename)\t= 0x\(String(value, radix: 16))\t// name:\"\(name)\", code:\"\(code)\""
		return CNTextLine(string: decl)
	}

	private func encode(propertyDefinition propdef: CNPropertyDefinition, asMember asmemb: Bool) -> CNText? {
		guard let name = propdef.name else {
			NSLog("No property name")
			return nil
		}
		let pname = CNScriptDefinition.normalize(string: name)
		let ptype = propdef.type.toSwiftType()
		let result: CNText
		if asmemb {
			result = CNTextLine(string: "var \(pname)\t: \(ptype)")
		} else {
			let sect = CNTextSection()
			sect.add(string: "var \(pname)\t: \(ptype) {")
			sect.add(string: " set get")
			sect.add(string: "}")
			result = sect
		}
		return result
	}

	private func encode(recordTypeDefinition recdef: CNRecordTypeDefinition) -> CNText? {
		guard let name = recdef.name else {
			NSLog("No record type name")
			return nil
		}
		let sname  = CNScriptDefinition.normalize(string: name)
		let newrec = CNTextSection()
		newrec.header = "public struct \(sname) {"
		newrec.footer = "}"
		for elm in recdef.contents {
			if let propelm = elm as? CNPropertyDefinition {
				if let proptxt = encode(propertyDefinition: propelm, asMember: true) {
					newrec.add(text: proptxt)
				}
			} else {
				NSLog("Unknown element in record-type: \(elm)")
			}
		}
		return newrec
	}

	private func encode(valueTypeDefinition valdef: CNValueTypeDefinition) -> CNText? {
		guard let typename = valdef.name, let classname = valdef.className else {
			NSLog("No class name in valud-type definition")
			return nil
		}
		return CNTextLine(string: "public typealias \(typename) = \(classname)")
	}
}

