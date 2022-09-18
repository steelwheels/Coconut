/**
 * @file	CNContactValueswift
 * @brief	Define CNContactValue class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Contacts
import Foundation

private let LabelHeader: String = "_$!<"
private let LabelFooter: String = ">!$_"

private func encodeLabel(label lab: String) -> String {
	let lab1 = lab.replacingOccurrences(of: LabelHeader, with: "")
	let lab2 = lab1.replacingOccurrences(of: LabelFooter, with: "")
	return lab2
}

private func decodeLabel(label lab: String) -> String {
	return LabelHeader + lab + LabelFooter
}

public extension CNPostalAddress
{
	static func encode(street str: String, city cty: String, state stt: String, postalCode pcd: String, country cry: String) -> CNValue {
		let result: Dictionary<String, CNValue> = [
			"street":	.stringValue(str),
			"city":		.stringValue(cty),
			"state":	.stringValue(stt),
			"postalCode":	.stringValue(pcd),
			"country":	.stringValue(cty)
		]
		return .dictionaryValue(result)
	}

	static func encode(addresses addrs: Array<CNLabeledValue<CNPostalAddress>>) -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for lvals in addrs {
			if let label = lvals.label {
				let key     = encodeLabel(label: label)
				let addr    = lvals.value
				result[key] = addr.encode()
			}
		}
		return .dictionaryValue(result)
	}

	func encode() -> CNValue {
		return CNPostalAddress.encode(street:     self.street,
					      city:       self.city,
					      state:      self.state,
					      postalCode: self.postalCode,
					      country:    self.country)
	}

	static func decode(value val: CNValue) -> Array<CNLabeledValue<CNPostalAddress>> {
		var result: Array<CNLabeledValue<CNPostalAddress>> = []
		if let dict = val.toDictionary() {
			for (label, val) in dict {
				let newaddr = CNMutablePostalAddress()
				newaddr.setNativeValue(val)

				let key   = decodeLabel(label: label)
				let laddr = CNLabeledValue(label: key, value: newaddr as CNPostalAddress)
				result.append(laddr)
			}
		}
		return result
	}
}

public extension CNMutablePostalAddress
{
	func setNativeValue(_ val: CNValue){
		if let dict = val.toDictionary() {
			for (key, val) in dict {
				if let str = val.toString() {
					switch key {
					case "street":		self.street	= str
					case "city":		self.city	= str
					case "state":		self.state	= str
					case "postalCode":	self.postalCode = str
					case "country":		self.country	= str
					default:
						CNLog(logLevel: .error, message: "Unknown property: \(key)", atFunction: #function, inFile: #file)
					}
				}
			}
		}
	}
}

public extension CNInstantMessageAddress
{
	static func encode(service srv: String, userName uname: String) -> CNValue {
		let result: Dictionary<String, CNValue> = [
			"service":  .stringValue(srv),
			"username": .stringValue(uname)
		]
		return .dictionaryValue(result)
	}

	func encode() -> CNValue {
		return CNInstantMessageAddress.encode(service:  self.service, userName: self.username)
	}

	static func decode(value val: CNValue) -> CNInstantMessageAddress? {
		if let dict = val.toDictionary() {
			var service:  String? = nil
			var username: String? = nil
			for (key, val) in dict {
				if let str = val.toString() {
					switch key {
					case "service":  service = str
					case "username": username = str
					default:
						CNLog(logLevel: .error, message: "Unexpected property name: \(key)", atFunction: #function, inFile: #file)
					}
				} else {
					CNLog(logLevel: .error, message: "Unexpected property value", atFunction: #function, inFile: #file)
				}
			}
			return CNInstantMessageAddress(username: username ?? "", service: service ?? "")
		} else {
			CNLog(logLevel: .error, message: "Unexpected source value", atFunction: #function, inFile: #file)
			return nil
		}
	}
}

public class CNLabeledInstantMessageAddresses
{
	static func encode(addresses addrs: Array<CNLabeledValue<CNInstantMessageAddress>>) -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for lvals in addrs {
			if let label = lvals.label {
				let key   = encodeLabel(label: label)
				let addr  = lvals.value
				result[key] = addr.encode()
			}
		}
		return .dictionaryValue(result)
	}

	static func decode(value val: CNValue) -> Array<CNLabeledValue<CNInstantMessageAddress>> {
		var result: Array<CNLabeledValue<CNInstantMessageAddress>> = []
		if let dict = val.toDictionary() {
			for (label, val) in dict {
				if let addr = CNInstantMessageAddress.decode(value: val) {
					let key   = decodeLabel(label: label)
					let laddr = CNLabeledValue(label: key, value: addr)
					result.append(laddr)
				}
			}
		}
		return result
	}
}

public extension CNPhoneNumber
{
	func getNativeValue() -> CNValue {
		return .stringValue(self.stringValue)
	}

	static func encode(numbers nums: Array<CNLabeledValue<CNPhoneNumber>>) -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for lvals in nums {
			if let label = lvals.label {
				let key  = encodeLabel(label: label)
				let num  = lvals.value
				result[key] = num.getNativeValue()
			}
		}
		return .dictionaryValue(result)
	}

	static func decode(value val: CNValue) -> Array<CNLabeledValue<CNPhoneNumber>> {
		var result: Array<CNLabeledValue<CNPhoneNumber>> = []
		if let dict = val.toDictionary() {
			for (label, val) in dict {
				if let addr = CNPhoneNumber.fromNativeValue(value: val) {
					let key   = decodeLabel(label: label)
					let laddr = CNLabeledValue(label: key, value: addr)
					result.append(laddr)
				}
			}
		}
		return result
	}

	static func fromNativeValue(value val: CNValue) -> CNPhoneNumber? {
		if let str = val.toString() {
			return CNPhoneNumber(stringValue: str)
		} else {
			return nil
		}
	}
}

public extension CNContactRelation
{
	func getNativeValue() -> CNValue {
		return .stringValue(self.name)
	}

	static func encode(relations rels: Array<CNLabeledValue<CNContactRelation>>) -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for lvals in rels {
			if let label = lvals.label {
				let key  = encodeLabel(label: label)
				let rel  = lvals.value
				result[key] = rel.getNativeValue()
			}
		}
		return .dictionaryValue(result)
	}

	static func decode(value val: CNValue) -> Array<CNLabeledValue<CNContactRelation>> {
		var result: Array<CNLabeledValue<CNContactRelation>> = []
		if let dict = val.toDictionary() {
			for (label, val) in dict {
				if let rel = CNContactRelation.fromNativeValue(value: val) {
					let key  = decodeLabel(label: label)
					let lrel = CNLabeledValue(label: key, value: rel)
					result.append(lrel)
				}
			}
		}
		return result
	}

	static func fromNativeValue(value val: CNValue) -> CNContactRelation? {
		if let str = val.toString() {
			return CNContactRelation(name: str)
		} else {
			return nil
		}
	}
}

public extension CNContactType
{
	private static let OrganizationItem	= "organization"
	private static let PersonItem		= "person"

	func encode() -> CNValue {
		let str: String
		switch self {
		case .organization:	str = CNContactType.OrganizationItem
		case .person:		str = CNContactType.PersonItem
		@unknown default:
			NSLog("Unknown contactType")
			str = CNContactType.OrganizationItem
		}
		return .stringValue(str)
	}

	static func decode(value val: CNValue) -> CNContactType? {
		if let str = val.toString() {
			var result: CNContactType? = nil
			switch str {
			case CNContactType.OrganizationItem:	result = .organization
			case CNContactType.PersonItem:		result = .person
			default:				result = nil
			}
			return result
		} else {
			return nil
		}
	}
}

public class CNLabeledStrings
{
	public static func encode(labeledStrings lstrs: Array<CNLabeledValue<NSString>>) -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for lval in lstrs {
			if let label = lval.label {
				let key     = encodeLabel(label: label)
				result[key] = .stringValue(lval.value as String)
			}
		}
		return .dictionaryValue(result)
	}

	public static func decode(value val: CNValue) -> Array<CNLabeledValue<NSString>>? {
		if let dict = val.toDictionary() {
			var result: Array<CNLabeledValue<NSString>> = []
			for (label, val) in dict {
				if let valstr = val.toString() {
					let key    = decodeLabel(label: label)
					let labstr = CNLabeledValue(label: key, value: valstr as NSString)
					result.append(labstr)
				}
			}
			return result
		} else {
			return nil
		}
	}
}

public class CNContactDate
{
	public static func encode(dateComponents dcomp: DateComponents?) -> CNValue {
		if let compp = dcomp {
			if let date = compp.date {
				return .objectValue(date as NSDate)
			}
		}
		return CNValue.null
	}

	public static func decode(date src: Date) -> DateComponents {
		return Calendar.current.dateComponents(in: TimeZone.current, from: src)
	}
}

public class CNLabeledDates
{
	public static func encode(labeledDateComponents comps: Array<CNLabeledValue<NSDateComponents>>) -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for comp in comps {
			if let label = comp.label {
				let key     = encodeLabel(label: label)
				result[key] = CNContactDate.encode(dateComponents: comp.value as DateComponents)
			}
		}
		return .dictionaryValue(result)
	}

	public static func decode(value val: CNValue) -> Array<CNLabeledValue<NSDateComponents>>? {
		if let dict = val.toDictionary() {
			var result: Array<CNLabeledValue<NSDateComponents>> = []
			for (label, val) in dict {
				if let date = val.toObject() as? NSDate {
					let comp   = CNContactDate.decode(date: date as Date)
					let key    = decodeLabel(label: label)
					let labstr = CNLabeledValue(label: key, value: comp as NSDateComponents)
					result.append(labstr)
				}
			}
			return result
		} else {
			return nil
		}
	}
}

public class CNContactImage
{
	public static func encode(imageData datap: Data?) -> CNValue {
		if let data = datap {
			if let img = CNImage(data: data) {
				return .objectValue(img)
			}
		}
		return CNValue.null
	}
}

