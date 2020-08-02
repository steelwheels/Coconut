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
			let suites = root.elements(forName: "suite")
			for suite in suites {
				let newsuite = parseSuiteNode(elementNode: suite)
				newdef.suiteDefinitions.append(newsuite)
			}
		}
		return newdef
	}

	private func parseSuiteNode(elementNode suite: XMLElement) -> CNSuiteDefinition {
		let newdef = CNSuiteDefinition()
		parseAttributes(elementDefinition: newdef, elementNode: suite)
		for elm in childElements(of: suite) {
			if let name = elm.name {
				switch name {
				case "command":
					let newnode = parseCommandNode(elementNode: elm)
					newdef.elementDefinitions.append(newnode)
				case "class":
					let newnode = parseClassNode(elementNode: elm)
					newdef.elementDefinitions.append(newnode)
				case "enumeration":
					let newnode = parseEnumerationNode(elementNode: elm)
					newdef.elementDefinitions.append(newnode)
				default:
					NSLog("Unknown element: \(name)")
				}
			}
		}
		return newdef
	}

	private func parseCommandNode(elementNode cmdnode: XMLElement) -> CNCommandDefinition {
		let newdef = CNCommandDefinition()
		parseAttributes(elementDefinition: newdef, elementNode: cmdnode)
		return newdef
	}

	private func parseClassNode(elementNode clsnode: XMLElement) -> CNClassDefinition {
		let newdef = CNClassDefinition()
		parseAttributes(elementDefinition: newdef, elementNode: clsnode)
		for elm in childElements(of: clsnode) {
			switch elm.name {
			case "cocoa":
				if let clsname = attributeValue(name: "class", in: elm) {
					newdef.className = clsname
				} else {
					let err = NSError.parseError(message: "No class name in cocoa node")
					mErrors.append(err)
				}
			case "property":
				let newnode = parsePropertyNode(elementNode: elm)
				newdef.properties.append(newnode)
			default:
				NSLog("Unknown element \(String(describing: elm.name)) in class node")
			}
		}
		return newdef
	}

	private func parsePropertyNode(elementNode propnode: XMLElement) -> CNPropertyDefinition {
		let newdef = CNPropertyDefinition()
		parseAttributes(elementDefinition: newdef, elementNode: propnode)
		/* Get attributes */
		if let val = attributeValue(name: "type", in: propnode) {
			newdef.type = val
		}
		for elm in childElements(of: propnode) {
			if let name = elm.name {
				switch name {
				case "cocoa":
					if let keyname = attributeValue(name: "key", in: elm) {
						newdef.cocoaKey = keyname
					} else {
						let err = NSError.parseError(message: "No class name in cocoa node")
						mErrors.append(err)
					}
				default:
					NSLog("Unknown element \(String(describing: elm.name)) in property node")
				}
			}
		}
		return newdef
	}

	private func parseEnumerationNode(elementNode enumnode: XMLElement) -> CNEnumerationDefinition {
		let newdef = CNEnumerationDefinition()
		for elm in childElements(of: enumnode) {
			if let name = elm.name {
				switch name {
				case "enumerator":
					let newnode = parseEnumeratorNode(elementNode: elm)
					newdef.elements.append(newnode)
				default:
					NSLog("Unknown enumeration: \(name)")
				}
			}
		}
		return newdef
	}

	private func parseEnumeratorNode(elementNode enumnode: XMLElement) -> CNEnumeratorDefinition {
		let newdef = CNEnumeratorDefinition()
		parseAttributes(elementDefinition: newdef, elementNode: enumnode)
		return newdef
	}

	private func parseAttributes(elementDefinition elmdef: CNElementDefinition, elementNode elmnode: XMLElement) {
		if let val = attributeValue(name: "name", in: elmnode) {
			elmdef.name = val
		} else {
			let err = NSError.parseError(message: "No \"name\" attribute in enumerator node")
			mErrors.append(err)
		}
		if let val = attributeValue(name: "code", in: elmnode) {
			elmdef.code = val
		} else {
			let err = NSError.parseError(message: "No \"code\" attribute in enumerator node")
			mErrors.append(err)
		}
		if let val = attributeValue(name: "description", in: elmnode) {
			elmdef.description = val
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


