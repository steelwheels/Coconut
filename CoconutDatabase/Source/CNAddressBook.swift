/**
 * @file	CNAuthorize.swift
 * @brief	Define CNAuthorize class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Contacts
import Foundation

public class CNAddressBook
{
	private var mState: CNAuthorizeState

	public init(){
		mState = .Undetermined
	}

	public var state: CNAuthorizeState { get { return mState }}

	public func authorize() -> CNAuthorizeState {
		if mState == .Undetermined {
			let status = CNContactStore.authorizationStatus(for: .contacts)
			switch status {
			case .authorized:
				mState = .Authorized
			case .denied:
				mState = .Denied
			case .notDetermined, .restricted:
				let store = CNContactStore()
				mState = .Examinating
				store.requestAccess(for: .contacts, completionHandler: {
					(_ granted: Bool, _ error: Error?) -> Void in
					if granted {
						self.mState = .Authorized
					} else {
						self.mState = .Denied
					}
				})
			}
		}
		return mState
	}

	public func contacts() -> CNNativeValue? {
		if mState == .Authorized {
			let keys    = [
				CNContactIdentifierKey		as CNKeyDescriptor,
				CNContactTypeKey		as CNKeyDescriptor,
				CNContactNamePrefixKey		as CNKeyDescriptor,
				CNContactGivenNameKey		as CNKeyDescriptor,
				CNContactMiddleNameKey		as CNKeyDescriptor,
				CNContactFamilyNameKey		as CNKeyDescriptor,
				CNContactPreviousFamilyNameKey	as CNKeyDescriptor,
				CNContactNameSuffixKey		as CNKeyDescriptor,
				CNContactBirthdayKey		as CNKeyDescriptor
			]
			let request = CNContactFetchRequest(keysToFetch: keys)
			do {
				let store = CNContactStore()
				var result: Array<CNNativeValue> = []
				try store.enumerateContacts(with: request, usingBlock: {
					(contact, pointer) in
					let dict = CNAddressBook.contactToDictionary(contact: contact)
					result.append(.dictionaryValue(dict))
				})
				return .arrayValue(result)
			}
			catch {
				return nil
			}
		} else {
			return nil
		}
	}

	private class func contactToDictionary(contact cont: CNContact) -> Dictionary<String, CNNativeValue> {
		var result: Dictionary<String, CNNativeValue> = [:]

		appendDictionary(destination: &result, property: CNContactIdentifierKey, 	value: cont.identifier)

		let typestr: String
		switch cont.contactType {
		case .organization:	typestr = "organization"
		case .person:		typestr = "person"
		}
		appendDictionary(destination: &result, property: CNContactTypeKey,		value: typestr)

		appendDictionary(destination: &result, property: CNContactNamePrefixKey,	value:	cont.namePrefix)
		appendDictionary(destination: &result, property: CNContactGivenNameKey, 	value:	cont.givenName)
		appendDictionary(destination: &result, property: CNContactMiddleNameKey,	value:	cont.middleName)
		appendDictionary(destination: &result, property: CNContactFamilyNameKey,	value:	cont.familyName)
		appendDictionary(destination: &result, property: CNContactPreviousFamilyNameKey, value: cont.previousFamilyName)
		appendDictionary(destination: &result, property: CNContactNameSuffixKey,	value: cont.nameSuffix)

		if let birthday = cont.birthday {
			appendDictionary(destination: &result, property: CNContactBirthdayKey, 	value:	birthday.description)
		}
		return result
	}

	private class func appendDictionary(destination dst: inout Dictionary<String, CNNativeValue>, property prop: String, value val: String) {
		if val.lengthOfBytes(using: .utf8) > 0 {
			dst[prop] = .stringValue(val)
		}
	}
}

