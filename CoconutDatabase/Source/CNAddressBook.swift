/**
 * @file	CNAddressBook.swift
 * @brief	Define CNAddressBook class
 * @par Copyright
 *   Copyright (C) 2021Steel Wheels Project
 * @reference
* *     - https://qiita.com/kato-i-l/items/0d79e8dcbc15541a5b0f
 */

import CoconutData
import Contacts
import Foundation


public class CNAddressBook
{
	public enum PropertyName {
		/* Contact Identification */
		case identifier
		case contactType
		case propertyAttribute
		/* Name */
		case namePrefix
		case givenName
		case middleName
		case familyName
		case previousFamilyName
		case nameSuffix
		case nickname
		case phoneticGivenName
		case phoneticMiddleName
		case phoneticFamilyName
		/* Work */
		case jobTitle
		case depertmentName
		case organizationName
		case phoneticOrganizationName
		/* Addresses */
		case postalAddresses
		case emailAddresses
		case URLAddresses
		case instantMessageAddresses
		/* Phone */
		case phoneNumbers
		/* Birthday */
		case birthday
		case nonGregorianBirthday
		case dates
		/* Notes */
		case note
		/* Images */
		case imageData
		case thumbnailImageData
		case imageDataAvailable
		/* Relation ships */
		case relations
		/* Instant messaging */
		case instantMessageAddress

		public static func allPropertyNames() -> Array<PropertyName> {
			return [
				identifier, contactType, propertyAttribute,
				namePrefix, givenName, middleName, familyName, previousFamilyName, nameSuffix, nickname, phoneticGivenName, phoneticMiddleName, phoneticFamilyName,
				jobTitle, depertmentName, organizationName, phoneticOrganizationName,
				postalAddresses, emailAddresses, URLAddresses, instantMessageAddresses,
				phoneNumbers,
				birthday, nonGregorianBirthday, dates, note,
				imageData, thumbnailImageData, imageDataAvailable,
				relations,
				instantMessageAddress
			]
		}

		public func toString() -> String {
			let result: String
			switch self {
			case .identifier:		result = CNContactIdentifierKey
			case .contactType:		result = CNContactTypeKey
			case .propertyAttribute:	result = CNContactPropertyAttribute
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
			case .instantMessageAddress:	result = CNContactInstantMessageAddressesKey
			}
			return result
		}
	}

	public init(){
	}

	public enum AutorizedStatus {
		case authorized
		case denied
	}

	public enum ReadResult {
		case table(CNNativeValue)
		case error(NSError)
	}

	public func checkAccessibility(callback cbfunc: @escaping (_ result: AutorizedStatus) -> Void) {
		let status = CNContactStore.authorizationStatus(for: .contacts)
		switch status {
		case .authorized:
			cbfunc(.authorized)
		case .denied:
			cbfunc(.denied)
		case .notDetermined, .restricted:
			let store = CNContactStore()
			store.requestAccess(for: .contacts, completionHandler: {
				(_ granted: Bool, _ error: Error?) -> Void in
				if granted {
					cbfunc(.authorized)
				} else {
					cbfunc(.denied)
				}
			})
		@unknown default:
			cbfunc(.denied)
		}
	}

	public func readContent() -> ReadResult {
		var keys: Array<CNKeyDescriptor> = []
		for prop in PropertyName.allPropertyNames() {
			keys.append(prop.toString() as CNKeyDescriptor)
		}

		do {
			let request = CNContactFetchRequest(keysToFetch: keys)
			var records: Array<CNNativeValue> = []

			try CNContactStore().enumerateContacts(with: request, usingBlock: {
				(contact, _) -> Void in
				if let record = self.contactToRecord(contact: contact) {
					records.append(record)
				}
			})

			return .table(.arrayValue(records))
		} catch {
			let err = NSError.fileError(message: "Failed to read contacts")
			return .error(err)
		}
	}

	private func contactToRecord(contact cont: CNContact) -> CNNativeValue? {
		var record: Dictionary<String, CNNativeValue> = [:]

		for prop in PropertyName.allPropertyNames() {
			let propkey = prop.toString()
			if !cont.isKeyAvailable(propkey) {
				continue
			}
			switch prop {
			case .identifier:
				updateProperty(contact: &record, key: propkey, string: cont.identifier)
			case .contactType:
				switch cont.contactType {
				case .organization:
					record[propkey] = .stringValue("organization")
				case .person:
					record[propkey] = .stringValue("person")
				@unknown default:
					CNLog(logLevel: .error, message: "Unknown contact type", atFunction: #function, inFile: #file)
				}
			case .propertyAttribute:
				NSLog("Unused key: .propertyAttribute")
			case .namePrefix:
				updateProperty(contact: &record, key: propkey, string: cont.namePrefix)
			case .givenName:
				updateProperty(contact: &record, key: propkey, string: cont.givenName)
			case .middleName:
				updateProperty(contact: &record, key: propkey, string: cont.middleName)
			case .familyName:
				updateProperty(contact: &record, key: propkey, string: cont.familyName)
			case .previousFamilyName:
				updateProperty(contact: &record, key: propkey, string: cont.previousFamilyName)
			case .nameSuffix:
				updateProperty(contact: &record, key: propkey, string: cont.nameSuffix)
			case .nickname:
				updateProperty(contact: &record, key: propkey, string: cont.nickname)
			case .phoneticGivenName:
				updateProperty(contact: &record, key: propkey, string: cont.phoneticGivenName)
			case .phoneticMiddleName:
				updateProperty(contact: &record, key: propkey, string: cont.phoneticMiddleName)
			case .phoneticFamilyName:
				updateProperty(contact: &record, key: propkey, string: cont.phoneticFamilyName)
			case .jobTitle:
				updateProperty(contact: &record, key: propkey, string: cont.jobTitle)
			case .depertmentName:
				updateProperty(contact: &record, key: propkey, string: cont.departmentName)
			case .organizationName:
				updateProperty(contact: &record, key: propkey, string: cont.organizationName)
			case .phoneticOrganizationName:
				updateProperty(contact: &record, key: propkey, string: cont.phoneticOrganizationName)
			case .postalAddresses:
				var result: Dictionary<String, CNNativeValue> = [:]
				for addr in cont.postalAddresses {
					if let label = addr.label {
						if let rec = postalAddressToRecord(address: addr.value) {
							result[label] = rec
						}
					}
				}
				if result.count > 0 { record[propkey] = .dictionaryValue(result) }
			case .emailAddresses:
				var result: Dictionary<String, CNNativeValue> = [:]
				for addr in cont.emailAddresses {
					if let label = addr.label {
						result[label] = .stringValue(addr.value as String)
					}
				}
				if result.count > 0 { record[propkey] = .dictionaryValue(result) }
			case .URLAddresses:
				var result: Dictionary<String, CNNativeValue> = [:]
				for addr in cont.urlAddresses {
					if let label = addr.label {
						result[label] = .stringValue(addr.value as String)
					}
				}
				if result.count > 0 { record[propkey] = .dictionaryValue(result) }
			case .instantMessageAddresses:
				var result: Dictionary<String, CNNativeValue> = [:]
				for addr in cont.instantMessageAddresses {
					if let label = addr.label {
						if let rec = instantMessageAddressToRecord(address: addr.value) {
							result[label] = rec
						}
					}
				}
				if result.count > 0 { record[propkey] = .dictionaryValue(result) }
			case .phoneNumbers:
				var result: Dictionary<String, CNNativeValue> = [:]
				for number in cont.phoneNumbers {
					if let label = number.label {
						result[label] = .stringValue(number.value.stringValue)
					}
				}
				if result.count > 0 { record[propkey] = .dictionaryValue(result) }
			case .birthday:
				if let comp = cont.birthday {
					if let date = comp.date {
						record[propkey] = .dateValue(date)
					}
				}
			case .nonGregorianBirthday:
				if let comp = cont.nonGregorianBirthday {
					if let date = comp.date {
						record[propkey] = .dateValue(date)
					}
				}
			case .dates:
				var result: Dictionary<String, CNNativeValue> = [:]
				for comp in cont.dates {
					if let label = comp.label, let date = comp.value.date {
						result[label] = .dateValue(date)
					}
				}
				if result.count > 0 { record[propkey] = .dictionaryValue(result) }
			case .note:
				updateProperty(contact: &record, key: propkey, string: cont.note)
			case .imageData:
				updateProperty(contact: &record, key: propkey, imageData: cont.imageData)
			case .thumbnailImageData:
				updateProperty(contact: &record, key: propkey, imageData: cont.thumbnailImageData)
			case .imageDataAvailable:
				updateProperty(contact: &record, key: propkey, boolValue: cont.imageDataAvailable)
			case .relations:
				var result: Dictionary<String, CNNativeValue> = [:]
				for rel in cont.contactRelations {
					if let label = rel.label {
						if let rec = contactRelationToRecord(relation: rel.value) {
							result[label] = rec
						}
					}
				}
				if result.count > 0 { record[propkey] = .dictionaryValue(result) }
			case .instantMessageAddress:
				var result: Dictionary<String, CNNativeValue> = [:]
				for addrs in cont.instantMessageAddresses {
					if let label = addrs.label {
						if let rec = instantMessageAddressToRecord(address: addrs.value) {
							result[label] = rec
						}
					}
				}
				if result.count > 0 { record[propkey] = .dictionaryValue(result) }
			}
		}
		return .dictionaryValue(record)
	}

	private func postalAddressToRecord(address addr: CNPostalAddress) -> CNNativeValue? {
		var result: Dictionary<String, CNNativeValue> = [:]
		updateProperty(contact: &result, key: CNPostalAddressStreetKey, string: addr.street)
		updateProperty(contact: &result, key: CNPostalAddressCityKey, string: addr.city)
		updateProperty(contact: &result, key: CNPostalAddressStateKey, string: addr.state)
		updateProperty(contact: &result, key: CNPostalAddressPostalCodeKey, string: addr.postalCode)
		updateProperty(contact: &result, key: CNPostalAddressCountryKey, string: addr.country)
		updateProperty(contact: &result, key: CNPostalAddressISOCountryCodeKey, string: addr.isoCountryCode)
		if result.count > 0 {
			return .dictionaryValue(result)
		} else {
			return nil
		}
	}

	private func instantMessageAddressToRecord(address addr: CNInstantMessageAddress) -> CNNativeValue? {
		var result: Dictionary<String, CNNativeValue> = [:]
		updateProperty(contact: &result, key: CNInstantMessageAddressServiceKey, string: addr.service)
		updateProperty(contact: &result, key: CNInstantMessageAddressUsernameKey, string: addr.username)
		if result.count > 0 {
			return .dictionaryValue(result)
		} else {
			return nil
		}
	}

	private func contactRelationToRecord(relation rel : CNContactRelation) -> CNNativeValue? {
		var result: Dictionary<String, CNNativeValue> = [:]
		updateProperty(contact: &result, key: "name", string: rel.name)
		if result.count > 0 {
			return .dictionaryValue(result)
		} else {
			return nil
		}
	}

	private func updateProperty(contact record: inout Dictionary<String, CNNativeValue>, key kstr: String, string vstr: String) {
		if vstr != "" {
			record[kstr] = .stringValue(vstr)
		}
	}

	private func updateProperty(contact record: inout Dictionary<String, CNNativeValue>, key kstr: String, boolValue val: Bool) {
		record[kstr] = .numberValue(NSNumber(booleanLiteral: val))
	}

	private func updateProperty(contact record: inout Dictionary<String, CNNativeValue>, key kstr: String, imageData vdat: Data?) {
		if let data = vdat {
			if let img = CNImage(data: data) {
				record[kstr] = .imageValue(img)
			}
		}
	}
}

