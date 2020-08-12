/**
 * @file	CNDefinitionParser.swift
 * @brief	Define CNDefinitionParser class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNDefinitionParser
{
	public enum ReadResult {
		case ok(CNScriptDefinition)
		case error(Array<NSError>)
	}

	private var mErrors: Array<NSError>

	public init() {
		mErrors = []
	}

	public func parse(fileURL url: URL) -> ReadResult {
		do {
			let xmldoc = try XMLDocument(contentsOf: url, options: [.documentXInclude])
			let newdef = parseXmlDoc(xmlDocument: xmldoc)
			if mErrors.count == 0 {
				return .ok(newdef)
			} else {
				return .error(mErrors)
			}
		}
		catch let err as NSError {
			return .error([err])
		}
		catch {
			let err = NSError.fileError(message: "Failed to read \(url.path)")
			return .error([err])
		}
	}

	private func parseXmlDoc(xmlDocument doc: XMLDocument) -> CNScriptDefinition {
		let newdef = CNScriptDefinition()
		if let root = doc.rootElement() {
			if let title = attributeValue(name: "title", in: root) {
				newdef.title = title
			}
			let suites = root.elements(forName: "suite")
			for suite in suites {
				let newsuite = parseSuiteNode(elementNode: suite)
				newdef.contents.append(newsuite)
			}
		}
		return newdef
	}

	private func parseSuiteNode(elementNode suitenode: XMLElement) -> CNSuiteDefinition {
		let newdef = CNSuiteDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: suitenode)
		for elm in childElements(of: suitenode) {
			if let name = elm.name {
				switch name {
				case "access-group":
					let newelm = parseAccessGroupNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "class":
					let newelm = parseClassNode(isExtension: false, elementNode: elm)
					newdef.contents.append(newelm)
				case "class-extension":
					let newelm = parseClassNode(isExtension: true, elementNode: elm)
					newdef.contents.append(newelm)
				case "command":
					let newelm = parseCommandNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "enumeration":
					let newelm = parseEnumerationNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "record-type":
					let newelm = parseRecordTypeNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "value-type":
					let newelm = parseValueTypeNode(elementNode: elm)
					newdef.contents.append(newelm)
				default:
					NSLog("Unknown element in suite node: \(name)")
				}
			}
		}
		return newdef
	}

	private func parseCommandNode(elementNode cmdnode: XMLElement) -> CNCommandDefinition {
		let cmddef = CNCommandDefinition()
		parseAttributes(attributedDefinition: cmddef, elementNode: cmdnode)
		for elm in childElements(of: cmdnode) {
			if let name = elm.name {
				switch name {
				case "access-group":
					let newdef = parseAccessGroupNode(elementNode: elm)
					cmddef.contents.append(newdef)
				case "cocoa":
					let newdef = parseCocoaNode(elementNode: elm)
					cmddef.contents.append(newdef)
				case "parameter":
					let newdef = parseParameterNode(elementNode: elm)
					cmddef.contents.append(newdef)
				case "direct-parameter":
					let newdef = parseDirectParameterNode(elementNode: elm)
					cmddef.contents.append(newdef)
				case "result":
					let newdef = parseResultNode(elementNode: elm)
					cmddef.contents.append(newdef)
				default:
					NSLog("Unknown element in command node: \(name)")
				}
			}
		}
		return cmddef
	}

	private func parseParameterNode(elementNode elmnode: XMLElement) -> CNParameterDefinition {
		let newdef = CNParameterDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: elmnode)
		return newdef
	}

	private func parseDirectParameterNode(elementNode elmnode: XMLElement) -> CNDirectParameterDefinition {
		let newdef = CNDirectParameterDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: elmnode)
		return newdef
	}

	private func parseResultNode(elementNode elmnode: XMLElement) -> CNResultDefinition {
		let newdef = CNResultDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: elmnode)
		return newdef
	}

	private func parseClassNode(isExtension isext: Bool, elementNode clsnode: XMLElement) -> CNClassDefinition {
		let newdef = CNClassDefinition(isExtension: isext)
		parseAttributes(attributedDefinition: newdef, elementNode: clsnode)
		for elm in childElements(of: clsnode) {
			if let name = elm.name {
				switch name {
				case "access-group":
					let newelm = parseAccessGroupNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "cocoa":
					let newelm = parseCocoaNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "contents":
					let newelm = parseContentsNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "element":
					let newelm = parseElementNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "property":
					let newelm = parsePropertyNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "responds-to":
					let newelm = parseRespondsToNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "synonym":
					let newelm = parseSynonymNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "type":
					let newelm = parseTypeNode(elementNode: elm)
					newdef.contents.append(newelm)
				default:
					NSLog("Unknown element in class node: \(name)")
				}
			}
		}
		return newdef
	}

	private func parsePropertyNode(elementNode propnode: XMLElement) -> CNPropertyDefinition {
		let newdef = CNPropertyDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: propnode)
		/* Get attributes */
		if let val = attributeValue(name: "access", in: propnode) {
			if let acc = CNPropertyDefinition.AccessType.decode(string: val) {
				newdef.access = acc
			} else {
				NSLog("Unknown access type in property node: \(val)")
			}
		}
		return newdef
	}

	private func parseContentsNode(elementNode contnode: XMLElement) -> CNContentsDefinition {
		let newdef = CNContentsDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: contnode)
		return newdef
	}

	private func parseSynonymNode(elementNode contnode: XMLElement) -> CNSynonymDefinition {
		let newdef = CNSynonymDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: contnode)
		return newdef
	}

	private func parseEnumerationNode(elementNode enumnode: XMLElement) -> CNEnumerationDefinition {
		let newdef = CNEnumerationDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: enumnode)
		for elm in childElements(of: enumnode) {
			if let name = elm.name {
				switch name {
				case "enumerator":
					let newnode = parseEnumeratorNode(elementNode: elm)
					newdef.contents.append(newnode)
				default:
					NSLog("Unknown enumeration: \(name)")
				}
			}
		}
		return newdef
	}

	private func parseEnumeratorNode(elementNode enumnode: XMLElement) -> CNEnumeratorDefinition {
		let newdef = CNEnumeratorDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: enumnode)
		return newdef
	}

	private func parseRecordTypeNode(elementNode recnode: XMLElement) -> CNRecordTypeDefinition {
		let newdef = CNRecordTypeDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: recnode)
		for elm in childElements(of: recnode) {
			if let name = elm.name {
				switch name {
				case "cocoa":
					let newelm = parseCocoaNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "property":
					let newelm = parsePropertyNode(elementNode: elm)
					newdef.contents.append(newelm)
				default:
					NSLog("Unknown element in record-type node: \(name)")
				}
			}
		}
		return newdef
	}

	private func parseValueTypeNode(elementNode elmnode: XMLElement) -> CNValueTypeDefinition {
		let valdef = CNValueTypeDefinition()
		parseAttributes(attributedDefinition: valdef, elementNode: elmnode)
		for elm in childElements(of: elmnode) {
			if let ename = elm.name {
				switch ename {
				case "cocoa":
					let newdef = parseCocoaNode(elementNode: elm)
					valdef.contents.append(newdef)
				default:
					NSLog("Unknown element in value-type node: \(ename)")
				}
			}
		}
		return valdef
	}

	private func parseTypeNode(elementNode elmnode: XMLElement) -> CNTypeDefinition {
		let newdef = CNTypeDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: elmnode)
		if let val = attributeValue(name: "list", in: elmnode) {
			switch val {
			case "yes":	newdef.isList = true
			case "no":	newdef.isList = false
			default:	NSLog("Unknown value of list of type node: \(val)")
			}
		}
		return newdef
	}

	private func parseElementNode(elementNode elmnode: XMLElement) -> CNElementDefinition {
		let newdef = CNElementDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: elmnode)
		for elm in childElements(of: elmnode) {
			if let ename = elm.name {
				switch ename {
				case "access-group":
					let newelm = parseAccessGroupNode(elementNode: elm)
					newdef.contents.append(newelm)
				case "cocoa":
					let newelm = parseCocoaNode(elementNode: elm)
					newdef.contents.append(newelm)
				default:
					NSLog("Unknown element in responds-to: \(ename)")
				}
			}
		}
		return newdef
	}

	private func parseRespondsToNode(elementNode elmnode: XMLElement) -> CNRespondsToDefinition {
		let newdef = CNRespondsToDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: elmnode)
		for elm in childElements(of: elmnode) {
			if let ename = elm.name {
				switch ename {
				case "cocoa":
					let newelm = parseCocoaNode(elementNode: elm)
					newdef.contents.append(newelm)
				default:
					NSLog("Unknown element in responds-to: \(ename)")
				}
			}
		}
		return newdef
	}

	private func parseAccessGroupNode(elementNode elmnode: XMLElement) -> CNAccessGroupDefinition {
		let newdef = CNAccessGroupDefinition()
		parseAttributes(attributedDefinition: newdef, elementNode: elmnode)
		newdef.identifier = attributeValue(name: "identifier", in: elmnode)
		if let accstr = attributeValue(name: "access", in: elmnode) {
			newdef.access = CNAccessGroupDefinition.AccessType.decode(string: accstr)
		}
		return newdef
	}

	private func parseCocoaNode(elementNode elmnode: XMLElement) -> CNCocoaDefinition {
		let newdef = CNCocoaDefinition()
		if let attrs = elmnode.attributes {
			for attr in attrs {
				if let attrname = attr.name {
					switch attrname {
					case "class":
						newdef.className  = attr.stringValue
					case "key":
						newdef.keyName    = attr.stringValue
					case "method":
						newdef.methodName = attr.stringValue
					default:
						NSLog("Unknown attribute name in cocoa: \(attrname)")
					}
				}
			}
		}
		return newdef
	}

	private func parseAttributes(attributedDefinition attrdef: CNBaseDefinition, elementNode elmnode: XMLElement) {
		if let val = attributeValue(name: "name", in: elmnode) {
			attrdef.name = CNScriptDefinition.normalize(string: val)
		}
		if let val = attributeValue(name: "id", in: elmnode) {
			attrdef.idString = CNScriptDefinition.normalize(string: val)
		}
		if let val = attributeValue(name: "code", in: elmnode) {
			attrdef.code = CNScriptDefinition.normalize(string: val)
		}
		if let val = attributeValue(name: "description", in: elmnode) {
			attrdef.description = CNScriptDefinition.normalize(string: val)
		}
		if let val = attributeValue(name: "type", in: elmnode) {
			attrdef.type = CNPropertyDefinition.DataType.decode(string: val)
		}
		if let val = attributeValue(name: "hidden", in: elmnode) {
			switch val {
			case "yes":	attrdef.hidden = true
			case "no":	attrdef.hidden = false
			default:	NSLog("Unknown hidden parameter: \(val)")
			}
		}
	}

	private func childElements(of elmnode: XMLElement) -> Array<XMLElement> {
		if let children = elmnode.children {
			var result: Array<XMLElement> = []
			for child in children {
				if let elm = child as? XMLElement {
					result.append(elm)
				}
			}
			return result
		} else {
			return []
		}
	}

	private func attributeValue(name nm: String, in elm: XMLElement) -> String? {
		if let attr = elm.attribute(forName: nm) {
			if let name = attr.stringValue	{
				return name
			}
		}
		return nil
	}
}


