/**
 * @file	CNContactField.swift
 * @brief	Define CNContactField class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Contacts
import Foundation

public enum CNContactField: Int
{
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
	case urlAddresses			= 18
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

	public static var numberOfFields: Int {
		get { return CNContactField.relations.rawValue + 1 }
	}

	public static var allFields: Array<CNContactField> {
		get {
			var result: Array<CNContactField> = []
			for i in 0..<numberOfFields {
				if let fld = CNContactField(rawValue: i) {
					result.append(fld)
				}
			}
			return result
		}
	}

	public static var allFieldNames: Array<String> {
		get {
			var result: Array<String> = []
			for i in 0..<numberOfFields {
				if let fld = CNContactField(rawValue: i) {
					result.append(fld.toName())
				}
			}
			return result
		}
	}

	public static func fieldName(at index: Int) -> String? {
		if 0<=index && index<numberOfFields {
			if let fld = CNContactField(rawValue: index) {
				return fld.toName()
			}
		}
		return nil
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
		case .urlAddresses:		result = CNContactUrlAddressesKey
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
		case .contactType:		result = "contact_type"
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
		case .urlAddresses:		result = "url_address"
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

