/**
 * @file	CNAppleEventParser.swift
 * @brief	Define NSAppleEventParser class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

#if os(OSX)

public class CNEventParser
{
	public enum ParseResult {
		case ok(CNEventParameter)
		case error(NSError)
	}

	public init(){
	}

	public func parseParameter(descriptor desc: NSAppleEventDescriptor) -> ParseResult {
		do {
			if desc.isRecordDescriptor {
				let obj = try parseDescriptor(descriptor: desc)
				return .ok(try parseObject(object: obj))
			} else {
				switch desc.enumCodeValue {
				case CNEventCode.window.code():
					return .ok(.window(.none))
				case CNEventCode.terminalWidth.code():
					return .ok(.preference(.terminalWidth))
				case CNEventCode.terminalHeight.code():
					return .ok(.preference(.terminalHeight))
				default:
					if let val = desc.toValue() {
						return .ok(.value(val))
					} else if let col = desc.toColor() {
						return .ok(.color(col))
					} else {
						let err = NSError.parseError(message: "Invalid format: \(desc.description)")
						return .error(err)
					}
				}
			}
		} catch let err as NSError {
			return .error(err as NSError)
		} catch {
			let err = NSError.parseError(message: "Unknown error")
			return .error(err)
		}
	}

	public func parseDescriptor(descriptor desc: NSAppleEventDescriptor) throws -> CNEventObject {
		let objtype: CNEventObjectType
		if let typedesc = desc.forKeyword(CNEventCode.classType.code()) {
			switch typedesc.enumCodeValue {
			case CNEventCode.property.code():
				objtype = .property
			case CNEventCode.window.code():
				objtype = .window
			default:
				throw NSError.parseError(message: "Unknown class type for object: \(typedesc.description)")
			}
		} else {
			throw NSError.parseError(message: "No object type for object")
		}

		let objsel: CNEventSelector
		if let seldesc = desc.forKeyword(CNEventCode.selectData.code()) {
			//let descstr = CNEventCode.descriptionTypeToString(code: seldesc.descriptorType)
			//mConsole.print(string: "SELECTOR DESC: \(descstr)\n")
			if let val = seldesc.toValue() {
				objsel = .value(val)
			} else {
				objsel = .osType(seldesc.enumCodeValue)
			}
		} else {
			throw NSError.parseError(message: "No select data for object")
		}

		let objref: CNEventObject? = nil

		return CNEventObject(type: objtype, selector: objsel, reference: objref)
	}

	private func parseObject(object obj: CNEventObject) throws -> CNEventParameter {
		switch obj.type {
		case .property:
			switch obj.selector {
			case .osType(let type):
				return try osTypeToColorParameter(osType: type)
			case .value(let val):
				throw NSError.parseError(message: "Value \"\(val.description)\" is not suitable to select color")
			}
		case .window:
			switch obj.selector {
			case .osType(let type):
				let typestr = CNEventCode.descriptionTypeToString(code: type)
				throw NSError.parseError(message: "Type \"\(typestr)\" is not suitable to select window")
			case .value(let val):
				return try nameToWindowParameter(value: val)
			}
		}
	}

	private func osTypeToColorParameter(osType type: OSType) throws -> CNEventParameter {
		let result: CNEventParameter
		switch type {
		case CNEventCode.textColor.code():
			result = .preference(.foregroundColor)
		case CNEventCode.backgroundColor.code():
			result = .preference(.backgroundColor)
		case CNEventCode.terminalHeight.code():
			result = .preference(.terminalHeight)
		case CNEventCode.terminalWidth.code():
			result = .preference(.terminalWidth)
		case CNEventCode.black.code():
			result = .color(CNColor.black)
		case CNEventCode.red.code():
			result = .color(CNColor.red)
		case CNEventCode.green.code():
			result = .color(CNColor.green)
		case CNEventCode.yellow.code():
			result = .color(CNColor.yellow)
		case CNEventCode.blue.code():
			result = .color(CNColor.blue)
		case CNEventCode.magenta.code():
			result = .color(CNColor.magenta)
		case CNEventCode.cyan.code():
			result = .color(CNColor.cyan)
		case CNEventCode.white.code():
			result = .color(CNColor.white)
		default:
			let typestr = CNEventCode.descriptionTypeToString(code: type)
			throw NSError.parseError(message: "Unknown ostype: \(typestr)")
		}
		return result
	}

	private func nameToWindowParameter(value val: CNValue) throws -> CNEventParameter {
		let result: CNEventParameter
		if let imm = val.intValue {
			result = .window(.id(imm))
		} else if let imm = val.stringValue {
			result = .window(.name(imm))
		} else {
			throw NSError.parseError(message: "\(val.description) is not suitable to select window")
		}
		return result
	}

	public func parseMakeTarget(descriptor desc: NSAppleEventDescriptor) -> CNEventMakeTarget? {
		let result: CNEventMakeTarget?
		switch desc.enumCodeValue {
		case CNEventCode.window.code():
			result = .window
		default:
			result = nil
		}
		return result
	}
}

#endif

