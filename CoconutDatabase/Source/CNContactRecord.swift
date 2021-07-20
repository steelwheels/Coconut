/**
 * @file	CNContactRecord.swift
 * @brief	Define CNContactRecord class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Contacts
import Foundation

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
		case depertmentName			= 13
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
			case .depertmentName:		result = CNContactDepartmentNameKey
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
			case .depertmentName:		result = "department_name"
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

	public var 		tag:		Int
	private var		mContact:	CNContact
	private static var	mStringTable:	Dictionary<String, Property>? = nil

	public init(contact cont: CNContact) {
		mContact	= cont
		tag		= 0
	}

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

	public var identifier: CNNativeValue {
		get { return .stringValue(mContact.identifier) }
	}

	public var contactType: CNNativeValue {
		get {
			let str: String
			switch mContact.contactType {
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
		get { return .stringValue(mContact.namePrefix) }
	}

	public var givenName: CNNativeValue {
		get { return .stringValue(mContact.givenName) }
	}

	public var middleName: CNNativeValue {
		get { return .stringValue(mContact.middleName) }
	}

	public var familyName: CNNativeValue {
		get { return .stringValue(mContact.familyName) }
	}

	public var previousFamilyName: CNNativeValue {
		get { return .stringValue(mContact.previousFamilyName) }
	}

	public var nameSuffix: CNNativeValue {
		get { return .stringValue(mContact.nameSuffix) }
	}

	public var nickname: CNNativeValue {
		get { return .stringValue(mContact.nickname) }
	}

	public var phoneticGivenName: CNNativeValue {
		get { return .stringValue(mContact.phoneticGivenName) }
	}

	public var phoneticMiddleName: CNNativeValue {
		get { return .stringValue(mContact.phoneticMiddleName) }
	}

	public var phoneticFamilyName: CNNativeValue {
		get { return .stringValue(mContact.phoneticFamilyName) }
	}

	public var jobTitle: CNNativeValue {
		get { return .stringValue(mContact.jobTitle) }
	}

	public var depertmentName: CNNativeValue {
		get { return .stringValue(mContact.departmentName) }
	}

	public var organizationName: CNNativeValue {
		get { return .stringValue(mContact.organizationName) }
	}

	public var phoneticOrganizationName: CNNativeValue {
		get { return .stringValue(mContact.phoneticOrganizationName)}
	}

	public var postalAddresses: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let addrs = mContact.postalAddresses
			for addr in addrs {
				let label = addr.label ?? "_"
				let value = postalAddressToValue(address: addr.value)
				result[label] = value
			}
			return .dictionaryValue(result)
		}
	}

	private func postalAddressToValue(address addr: CNPostalAddress) -> CNNativeValue {
		let result: Dictionary<String, CNNativeValue> = [
			"street":	.stringValue(addr.street),
			"city":		.stringValue(addr.city),
			"state":	.stringValue(addr.state),
			"postalCode":	.stringValue(addr.postalCode),
			"country":	.stringValue(addr.country)
		]
		return .dictionaryValue(result)
	}

	public var emailAddresses: CNNativeValue {
		get { return stringAddresses(addresses: mContact.emailAddresses) }
	}

	public var urlAddresses: CNNativeValue {
		get { return stringAddresses(addresses: mContact.urlAddresses) }
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

	public var instantMessageAddresses: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let addrs = mContact.instantMessageAddresses
			for addr in addrs {
				let label = addr.label ?? "_"
				let value = instantAddressToValue(address: addr.value)
				result[label] = value
			}
			return .dictionaryValue(result)
		}
	}

	private func instantAddressToValue(address addr: CNInstantMessageAddress) -> CNNativeValue {
		let result: Dictionary<String, CNNativeValue> = [
			"service":  .stringValue(addr.service),
			"username": .stringValue(addr.username)
		]
		return .dictionaryValue(result)
	}

	public var phoneNumbers: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let numbers = mContact.phoneNumbers
			for number in numbers {
				let label = number.label ?? "_"
				let value = number.value.stringValue
				result[label] = .stringValue(value)
			}
			return .dictionaryValue(result)
		}
	}

	public var birthday: CNNativeValue {
		get { return dateComponentToValue(component: mContact.nonGregorianBirthday) }
	}

	public var nonGregorianBirthday: CNNativeValue {
		get { return dateComponentToValue(component: mContact.nonGregorianBirthday) }
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
			let comps = mContact.dates
			for comp in comps {
				let label = comp.label ?? "_"
				let value = dateComponentToValue(component: comp.value)
				result[label] = value
			}
			return .dictionaryValue(result)
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
		get { return .stringValue(mContact.note) }
	}

	public var image: CNNativeValue {
		get { return imageToValue(date: mContact.imageData) }
	}

	public var thumbnailImageData: CNNativeValue {
		get { return imageToValue(date: mContact.thumbnailImageData) }
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
		get { return .numberValue(NSNumber(booleanLiteral: mContact.imageDataAvailable)) }
	}

	public var relations: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let rels = mContact.contactRelations
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
		case .depertmentName:		result = self.depertmentName
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

	public func compare(_ s1: CNContactRecord, byProperties props: Array<Property>) -> ComparisonResult {
		for prop in props {
			let v0  = self.value(forProperty: prop)
			let v1  = s1.value(forProperty: prop)
			let res = CNCompareNativeValue(nativeValue0: v0, nativeValue1: v1)
			switch res {
			case .orderedAscending, .orderedDescending:
				return res
			case .orderedSame:
				break
			}
		}
		return .orderedSame
	}
}

