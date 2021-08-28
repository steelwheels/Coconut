/**
 * @file	CNContactValueswift
 * @brief	Define CNContactValue class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Contacts
import Foundation

public extension CNPostalAddress
{
	static func makeNativeValue(street str: String, city cty: String, state stt: String, postalCode pcd: String, country cry: String) -> CNValue {
		let result: Dictionary<String, CNValue> = [
			"street":	.stringValue(str),
			"city":		.stringValue(cty),
			"state":	.stringValue(stt),
			"postalCode":	.stringValue(pcd),
			"country":	.stringValue(cty)
		]
		return .dictionaryValue(result)
	}

	static func makeNativeValue(addresses addrs: Array<CNLabeledValue<CNPostalAddress>>) -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for lvals in addrs {
			if let label = lvals.label {
				let addr  = lvals.value
				result[label] = addr.getNativeValue()
			}
		}
		return .dictionaryValue(result)
	}

	func getNativeValue() -> CNValue {
		return CNPostalAddress.makeNativeValue(street:     self.street,
						       city:       self.city,
						       state:      self.state,
						       postalCode: self.postalCode,
						       country:    self.country)
	}

	static func decodePostalAddresses(value val: CNValue) -> Array<CNLabeledValue<CNPostalAddress>> {
		var result: Array<CNLabeledValue<CNPostalAddress>> = []
		if let dict = val.toDictionary() {
			for (key, val) in dict {
				let newaddr = CNMutablePostalAddress()
				newaddr.setNativeValue(val)

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
	static func makeNativeValue(service srv: String, userName uname: String) -> CNValue {
		let result: Dictionary<String, CNValue> = [
			"service":  .stringValue(srv),
			"username": .stringValue(uname)
		]
		return .dictionaryValue(result)
	}

	static func makeNativeValue(addresses addrs: Array<CNLabeledValue<CNInstantMessageAddress>>) -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for lvals in addrs {
			if let label = lvals.label {
				let addr  = lvals.value
				result[label] = addr.getNativeValue()
			}
		}
		return .dictionaryValue(result)
	}

	func getNativeValue() -> CNValue {
		return CNInstantMessageAddress.makeNativeValue(service:  self.service,
							       userName: self.username)
	}

	static func decodeInstantMessageAddresses(value val: CNValue) -> Array<CNLabeledValue<CNInstantMessageAddress>> {
		var result: Array<CNLabeledValue<CNInstantMessageAddress>> = []
		if let dict = val.toDictionary() {
			for (key, val) in dict {
				if let addr = CNInstantMessageAddress.fromNativeValue(value: val) {
					let laddr = CNLabeledValue(label: key, value: addr)
					result.append(laddr)
				}
			}
		}
		return result
	}

	static func fromNativeValue(value val: CNValue) -> CNInstantMessageAddress? {
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

public extension CNPhoneNumber
{
	func getNativeValue() -> CNValue {
		return .stringValue(self.stringValue)
	}

	static func makeNativeValue(numbers nums: Array<CNLabeledValue<CNPhoneNumber>>) -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for lvals in nums {
			if let label = lvals.label {
				let num  = lvals.value
				result[label] = num.getNativeValue()
			}
		}
		return .dictionaryValue(result)
	}

	static func decodePhoneNumbers(value val: CNValue) -> Array<CNLabeledValue<CNPhoneNumber>> {
		var result: Array<CNLabeledValue<CNPhoneNumber>> = []
		if let dict = val.toDictionary() {
			for (key, val) in dict {
				if let addr = CNPhoneNumber.fromNativeValue(value: val) {
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

	static func makeNativeValue(relations rels: Array<CNLabeledValue<CNContactRelation>>) -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for lvals in rels {
			if let label = lvals.label {
				let rel  = lvals.value
				result[label] = rel.getNativeValue()
			}
		}
		return .dictionaryValue(result)
	}

	static func decodeRelations(value val: CNValue) -> Array<CNLabeledValue<CNContactRelation>> {
		var result: Array<CNLabeledValue<CNContactRelation>> = []
		if let dict = val.toDictionary() {
			for (key, val) in dict {
				if let rel = CNContactRelation.fromNativeValue(value: val) {
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

	func getNativeValue() -> CNValue {
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

	static func fromNativeValue(value val: CNValue) -> CNContactType? {
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
