/**
 * @file	CNContactRecord.swift
 * @brief	Define CNContactRecord class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Contacts
import Foundation

public extension CNPostalAddress {
	func getNativeValue() -> CNNativeValue {
		let result: Dictionary<String, CNNativeValue> = [
			"street":	.stringValue(self.street),
			"city":		.stringValue(self.city),
			"state":	.stringValue(self.state),
			"postalCode":	.stringValue(self.postalCode),
			"country":	.stringValue(self.country)
		]
		return .dictionaryValue(result)
	}
}

public extension CNMutablePostalAddress {
	func setNativeValue(_ val: CNNativeValue){
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

public extension CNInstantMessageAddress {
	func getNativeValue() -> CNNativeValue {
		let result: Dictionary<String, CNNativeValue> = [
			"service":  .stringValue(self.service),
			"username": .stringValue(self.username)
		]
		return .dictionaryValue(result)
	}

	static func fromNativeValue(value val: CNNativeValue) -> CNInstantMessageAddress? {
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

public extension CNPhoneNumber {
	func getNativeValue() -> CNNativeValue {
		return .stringValue(self.stringValue)
	}

	static func fromNativeValue(value val: CNNativeValue) -> CNPhoneNumber? {
		if let str = val.toString() {
			return CNPhoneNumber(stringValue: str)
		} else {
			return nil
		}
	}
}


public class CNContactRecord: CNRecord
{
	public enum Property: Int {
		/* Contact Identification */
		case identifier				= 0
		case contactType			= 1
		/* Name */
		case namePrefix				= 2
		case givenName				= 3
		case middleName				= 4
		case familyName				= 5
		case previousFamilyName			= 6
		case nameSuffix				= 7
		case nickname				= 8
		case phoneticGivenName			= 9
		case phoneticMiddleName			= 10
		case phoneticFamilyName			= 11
		/* Work */
		case jobTitle				= 12
		case departmentName			= 13
		case organizationName			= 14
		case phoneticOrganizationName		= 15
		/* Addresses */
		case postalAddresses			= 16
		case emailAddresses			= 17
		case URLAddresses			= 18
		case instantMessageAddresses		= 19
		/* Phone */
		case phoneNumbers			= 20
		/* Birthday */
		case birthday				= 21
		case nonGregorianBirthday		= 22
		case dates				= 23
		/* Notes */
		case note				= 24
		/* Images */
		case imageData				= 25
		case thumbnailImageData			= 26
		case imageDataAvailable			= 27
		/* Relation ships */
		case relations				= 28

		public static var numberOfProperties: Int {
			get { return CNContactRecord.Property.relations.rawValue + 1 }
		}

		public static var allProperties: Array<Property> {
			get {
				var result: Array<Property> = []
				for i in 0..<numberOfProperties {
					if let prop = Property(rawValue: i) {
						result.append(prop)
					}
				}
				return result
			}
		}

		public func toKey() -> String {
			let result: String
			switch self {
			case .identifier:		result = CNContactIdentifierKey
			case .contactType:		result = CNContactTypeKey
			case .namePrefix:		result = CNContactNamePrefixKey
			case .givenName:		result = CNContactGivenNameKey
			case .middleName:		result = CNContactMiddleNameKey
			case .familyName:		result = CNContactFamilyNameKey
			case .previousFamilyName:	result = CNContactPreviousFamilyNameKey
			case .nameSuffix:		result = CNContactNameSuffixKey
			case .nickname:			result = CNContactNicknameKey
			case .phoneticGivenName:	result = CNContactPhoneticGivenNameKey
			case .phoneticMiddleName:	result = CNContactPhoneticMiddleNameKey
			case .phoneticFamilyName:	result = CNContactPhoneticFamilyNameKey
			case .jobTitle:			result = CNContactJobTitleKey
			case .departmentName:		result = CNContactDepartmentNameKey
			case .organizationName:		result = CNContactOrganizationNameKey
			case .phoneticOrganizationName:	result = CNContactPhoneticOrganizationNameKey
			case .postalAddresses:		result = CNContactPostalAddressesKey
			case .emailAddresses:		result = CNContactEmailAddressesKey
			case .URLAddresses:		result = CNContactUrlAddressesKey
			case .instantMessageAddresses:	result = CNContactInstantMessageAddressesKey
			case .phoneNumbers:		result = CNContactPhoneNumbersKey
			case .birthday:			result = CNContactBirthdayKey
			case .nonGregorianBirthday:	result = CNContactNonGregorianBirthdayKey
			case .dates:			result = CNContactDatesKey
			case .note:			result = CNContactNoteKey
			case .imageData:		result = CNContactImageDataKey
			case .thumbnailImageData:	result = CNContactThumbnailImageDataKey
			case .imageDataAvailable:	result = CNContactImageDataAvailableKey
			case .relations:		result = CNContactRelationsKey
			}
			return result
		}

		public func toName() -> String {
			let result: String
			switch self {
			case .identifier:		result = "identifier"
			case .contactType:		result = "type"
			case .namePrefix:		result = "name_prefix"
			case .givenName:		result = "given_name"
			case .middleName:		result = "middile_name"
			case .familyName:		result = "family_name"
			case .previousFamilyName:	result = "previous_family_name"
			case .nameSuffix:		result = "name_suffix"
			case .nickname:			result = "nickname"
			case .phoneticGivenName:	result = "phonetic_given_name"
			case .phoneticMiddleName:	result = "phonetic_middle_name"
			case .phoneticFamilyName:	result = "phonetic_family_name"
			case .jobTitle:			result = "job_title"
			case .departmentName:		result = "department_name"
			case .organizationName:		result = "organization_name"
			case .phoneticOrganizationName:	result = "phonetic_organization_name"
			case .postalAddresses:		result = "postal_address"
			case .emailAddresses:		result = "email_address"
			case .URLAddresses:		result = "URL_address"
			case .instantMessageAddresses:	result = "instant_message_addresses"
			case .phoneNumbers:		result = "phone_numbers"
			case .birthday:			result = "birthday"
			case .nonGregorianBirthday:	result = "non_gregorian_birthday"
			case .dates:			result = "dates"
			case .note:			result = "note"
			case .imageData:		result = "image_data"
			case .thumbnailImageData:	result = "thumbnail_image_data"
			case .imageDataAvailable:	result = "image_data_available"
			case .relations:		result = "relations"
			}
			return result
		}
	}

	/*
	 * mStringTable: Convert property-name to property type
	 */
	private static var	mStringTable:	Dictionary<String, Property>? = nil
	public static func stringToProperty(name nm: String) -> Property? {
		if let table = CNContactRecord.mStringTable {
			return table[nm]
		} else {
			var newtable: Dictionary<String, Property> = [:]
			for idx in 0..<Property.numberOfProperties {
				if let prop = Property(rawValue: idx) {
					newtable[prop.toName()] = prop
				}
			}
			CNContactRecord.mStringTable = newtable
			return newtable[nm]
		}
	}

	private enum ContactHandle {
		case immutable(CNContact)
		case mutable(CNMutableContact)
	}

	public var 		tag:		Int
	private var		mContact:	ContactHandle

	public init(contact cont: CNContact) {
		mContact	= .immutable(cont)
		tag		= 0
	}

	private var contactForRead: CNContact {
		get {
			let result: CNContact
			switch mContact {
			case .immutable(let cont):	result = cont
			case .mutable(let cont):	result = cont
			}
			return result
		}
	}

	private var contactForWrite: CNMutableContact {
		get {
			let result: CNMutableContact
			switch mContact {
			case .immutable(let cont):
				if let newcont = cont.mutableCopy() as? CNMutableContact {
					result = newcont
					mContact = .mutable(newcont)
				} else {
					fatalError("Failed to allocate mutable contact")
				}
			case .mutable(let cont):
				result = cont
			}
			return result
		}
	}

	public var identifier: CNNativeValue {
		get { return .stringValue(contactForRead.identifier) }
	}

	public var contactType: CNNativeValue {
		get {
			let str: String
			switch contactForRead.contactType {
			case .organization:	str = "organization"
			case .person:		str = "person"
			@unknown default:
				CNLog(logLevel: .error, message: "Unknown contact type", atFunction: #function, inFile: #file)
				str = "organization"
			}
			return .stringValue(str)
		}
	}

	public var namePrefix: CNNativeValue {
		get { return .stringValue(contactForRead.namePrefix) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.namePrefix = str
			}
		}
	}

	public var givenName: CNNativeValue {
		get { return .stringValue(contactForRead.givenName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.givenName = str
			}
		}
	}

	public var middleName: CNNativeValue {
		get { return .stringValue(contactForRead.middleName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.middleName = str
			}
		}
	}

	public var familyName: CNNativeValue {
		get { return .stringValue(contactForRead.familyName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.familyName = str
			}
		}
	}

	public var previousFamilyName: CNNativeValue {
		get { return .stringValue(contactForRead.previousFamilyName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.previousFamilyName = str
			}
		}
	}

	public var nameSuffix: CNNativeValue {
		get { return .stringValue(contactForRead.nameSuffix) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.nameSuffix = str
			}
		}
	}

	public var nickname: CNNativeValue {
		get { return .stringValue(contactForRead.nickname) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.nickname = str
			}
		}
	}

	public var phoneticGivenName: CNNativeValue {
		get { return .stringValue(contactForRead.phoneticGivenName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.phoneticGivenName = str
			}
		}
	}

	public var phoneticMiddleName: CNNativeValue {
		get { return .stringValue(contactForRead.phoneticMiddleName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.phoneticMiddleName = str
			}
		}
	}

	public var phoneticFamilyName: CNNativeValue {
		get { return .stringValue(contactForRead.phoneticFamilyName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.phoneticFamilyName = str
			}
		}
	}

	public var jobTitle: CNNativeValue {
		get { return .stringValue(contactForRead.jobTitle) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.jobTitle = str
			}
		}
	}

	public var departmentName: CNNativeValue {
		get { return .stringValue(contactForRead.departmentName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.departmentName = str
			}
		}
	}

	public var organizationName: CNNativeValue {
		get { return .stringValue(contactForRead.organizationName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.organizationName = str
			}
		}
	}

	public var phoneticOrganizationName: CNNativeValue {
		get { return .stringValue(contactForRead.phoneticOrganizationName)}
		set(strval){
			if let str = strval.toString() {
				contactForWrite.phoneticOrganizationName = str
			}
		}
	}

	public var postalAddresses: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let addrs = contactForRead.postalAddresses
			for addr in addrs {
				let label = addr.label ?? "_"
				let value = addr.value.getNativeValue()
				result[label] = value
			}
			return .dictionaryValue(result)
		}
		set(newval){
			if let dict = newval.toDictionary() {
				var addrs: Array<CNLabeledValue<CNPostalAddress>> = []
				for (lab, val) in dict {
					let newaddr = CNMutablePostalAddress()
					newaddr.setNativeValue(val)
					let newlab = CNLabeledValue(label: lab, value: newaddr as CNPostalAddress)
					addrs.append(newlab)
				}
				self.contactForWrite.postalAddresses = addrs
			} else {
				CNLog(logLevel: .error, message: "Unacceptable data as postalAddress", atFunction: #function, inFile: #file)
			}
		}
	}

	public var emailAddresses: CNNativeValue {
		get { return stringAddresses(addresses: contactForRead.emailAddresses) }
		set(newval){
			let addrs = valueToStringAddresses(value: newval)
			contactForWrite.emailAddresses = addrs
		}
	}

	public var urlAddresses: CNNativeValue {
		get { return stringAddresses(addresses: contactForRead.urlAddresses) }
	}

	public var instantMessageAddresses: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let addrs = contactForRead.instantMessageAddresses
			for addr in addrs {
				let label = addr.label ?? "_"
				let value = addr.value.getNativeValue()
				result[label] = value
			}
			return .dictionaryValue(result)
		}
		set(newval){
			if let dict = newval.toDictionary() {
				var result: Array<CNLabeledValue<CNInstantMessageAddress>> = []
				for (lab, val) in dict {
					if let newaddr = CNInstantMessageAddress.fromNativeValue(value: val) {
						result.append(CNLabeledValue(label: lab, value: newaddr))
					}
				}
				contactForWrite.instantMessageAddresses = result
			} else {
				CNLog(logLevel: .error, message: "Unacceptable data as postalAddress", atFunction: #function, inFile: #file)
			}
		}
	}

	private func stringAddresses(addresses addrs: Array<CNLabeledValue<NSString>>) -> CNNativeValue {
		var result: Dictionary<String, CNNativeValue> = [:]
		for addr in addrs {
			let label = addr.label ?? "_"
			let value = addr.value as String
			result[label] = .stringValue(value)
		}
		return .dictionaryValue(result)
	}

	private func valueToStringAddresses(value val: CNNativeValue) -> Array<CNLabeledValue<NSString>> {
		if let dict = val.toDictionary() {
			var result: Array<CNLabeledValue<NSString>> = []
			for (key, val) in dict {
				if let str = val.toString() {
					let newlab = CNLabeledValue(label: key, value: str as NSString)
					result.append(newlab)
				} else {
					CNLog(logLevel: .error, message: "Unexpected value for addresses", atFunction: #function, inFile: #file)
				}
			}
			return result
		} else {
			CNLog(logLevel: .error, message: "Unexpected value for addresses", atFunction: #function, inFile: #file)
			return []
		}
	}

	public var phoneNumbers: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let numbers = contactForRead.phoneNumbers
			for number in numbers {
				let label     = number.label ?? "_"
				result[label] = number.value.getNativeValue()
			}
			return .dictionaryValue(result)
		}
		set(newval){
			if let dict = newval.toDictionary() {
				var result: Array<CNLabeledValue<CNPhoneNumber>> = []
				for (key, val) in dict {
					if let pnum = CNPhoneNumber.fromNativeValue(value: val) {
						let newlab = CNLabeledValue(label: key, value: pnum)
						result.append(newlab)
					}
				}
				contactForWrite.phoneNumbers = result
			} else {
				CNLog(logLevel: .error, message: "Unacceptable data as phonenumbers", atFunction: #function, inFile: #file)
			}
		}
	}

	public var birthday: CNNativeValue {
		get { return dateComponentToValue(component: contactForRead.birthday) }
		set(newval){
			if let date = newval.toDate() {
				contactForWrite.birthday = Calendar.current.dateComponents(in: TimeZone.current, from: date)
			}
		}
	}

	public var nonGregorianBirthday: CNNativeValue {
		get { return dateComponentToValue(component: contactForRead.nonGregorianBirthday) }
		set(newval){
			if let date = newval.toDate() {
				contactForWrite.nonGregorianBirthday = Calendar.current.dateComponents(in: TimeZone.current, from: date)
			}
		}
	}

	private func dateComponentToValue(component comp: DateComponents?) -> CNNativeValue {
		if let compp = comp {
			if let date = compp.date {
				return .dateValue(date)
			}
		}
		return .nullValue
	}

	public var dates: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let comps = contactForRead.dates
			for comp in comps {
				let label = comp.label ?? "_"
				let value = dateComponentToValue(component: comp.value)
				result[label] = value
			}
			return .dictionaryValue(result)
		}
		set(newval){
			if let dict = newval.toDictionary() {
				var result: Array<CNLabeledValue<NSDateComponents>> = []
				for (key, val) in dict {
					if let date = val.toDate() {
						let comp = Calendar.current.dateComponents(in: TimeZone.current, from: date) as NSDateComponents
						let lab  = CNLabeledValue(label: key, value: comp)
						result.append(lab)
					}
				}
				contactForWrite.dates = result
			} else {
				CNLog(logLevel: .error, message: "Unacceptable data as dates", atFunction: #function, inFile: #file)
			}
		}
	}

	private func dateComponentToValue(component comp: NSDateComponents?) -> CNNativeValue {
		if let compp = comp {
			if let date = compp.date {
				return .dateValue(date)
			}
		}
		return .nullValue
	}

	public var note: CNNativeValue {
		get { return .stringValue(contactForRead.note) }
		set(newval){
			if let str = newval.toString() {
				contactForWrite.note = str
			}
		}
	}

	public var image: CNNativeValue {
		get { return imageToValue(date: contactForRead.imageData) }
		set(newval){
			if let img = newval.toImage() {
				contactForWrite.imageData = img.pngData()
			}
		}
	}

	public var thumbnailImageData: CNNativeValue {
		get { return imageToValue(date: contactForRead.thumbnailImageData) }
	}

	private func imageToValue(date dat: Data?) -> CNNativeValue {
		if let data = dat {
			if let img = CNImage(data: data) {
				return .imageValue(img)
			}
		}
		return .nullValue
	}

	public var imageDataAvailable: CNNativeValue {
		get { return .numberValue(NSNumber(booleanLiteral: contactForRead.imageDataAvailable)) }
	}

	public var relations: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let rels = contactForRead.contactRelations
			for rel in rels {
				let label = rel.label ?? "_"
				let value = relationToValue(relation: rel.value)
				result[label] = value
			}
			return .dictionaryValue(result)
		}
	}

	private func relationToValue(relation rel: CNContactRelation) -> CNNativeValue {
		return .stringValue(rel.name)
	}

	public func value(forProperty prop: Property) -> CNNativeValue {
		let result: CNNativeValue
		switch prop {
		case .identifier:		result = self.identifier
		case .contactType:		result = self.contactType
		case .namePrefix:		result = self.namePrefix
		case .givenName:		result = self.givenName
		case .middleName:		result = self.middleName
		case .familyName:		result = self.familyName
		case .previousFamilyName:	result = self.previousFamilyName
		case .nameSuffix:		result = self.nameSuffix
		case .nickname:			result = self.nickname
		case .phoneticGivenName:	result = self.phoneticGivenName
		case .phoneticMiddleName:	result = self.phoneticMiddleName
		case .phoneticFamilyName:	result = self.phoneticFamilyName
		case .jobTitle:			result = self.jobTitle
		case .departmentName:		result = self.departmentName
		case .organizationName:		result = self.organizationName
		case .phoneticOrganizationName:	result = self.phoneticOrganizationName
		case .postalAddresses:		result = self.postalAddresses
		case .emailAddresses:		result = self.emailAddresses
		case .URLAddresses:		result = self.urlAddresses
		case .instantMessageAddresses:	result = self.instantMessageAddresses
		case .phoneNumbers:		result = self.phoneNumbers
		case .birthday:			result = self.birthday
		case .nonGregorianBirthday:	result = self.nonGregorianBirthday
		case .dates:			result = self.dates
		case .note:			result = self.note
		case .imageData:		result = self.image
		case .thumbnailImageData:	result = self.thumbnailImageData
		case .imageDataAvailable:	result = self.imageDataAvailable
		case .relations:		result = self.relations
		}
		return result
	}

	public var itemCount: Int {
		get { return Property.numberOfProperties }
	}

	public func value(forName name: String) -> CNNativeValue? {
		if let prop = CNContactRecord.stringToProperty(name: name) {
			let retval = value(forProperty: prop)
			switch retval {
			case .nullValue:
				return nil
			default:
				return retval
			}
		} else {
			CNLog(logLevel: .error, message: "Unknown property: \(name)", atFunction: #function, inFile: #file)
		}
		return nil
	}

	public func setValue(value val: CNNativeValue, byName name: String) {
		NSLog("Failed to set value")
	}

	public func setValue(value val: CNNativeValue, byProperty prop: Property) {
		NSLog("Failed to set value")
	}

	public func compare(_ s1: CNContactRecord, byProperty prop: Property) -> ComparisonResult {
		let v0 = self.value(forProperty: prop)
		let v1 = s1.value(forProperty: prop)
		return CNCompareNativeValue(nativeValue0: v0, nativeValue1: v1)
	}
}

