/**
 * @file	CNAddressBook.swift
 * @brief	Define CNAddressBook class
 * @par Copyright
 *   Copyright (C) 2021Steel Wheels Project
 */

import CoconutData
import Contacts
import Foundation

public class CNAddressBook
{
	public enum ReadResult {
		case contacts(Array<CNContact>)
		case error(NSError)
	}

	private var mState:	CNAuthorizeState

	public var state: CNAuthorizeState { get { return mState }}

	public init(){
		mState = .Undetermined
	}

	public func autorize() -> CNAuthorizeState {
		switch mState {
		case .Authorized, .Denied, .Examinating:
			return mState
		case .Undetermined:
			mState = CNAddressBook.execAuthorization()
			return mState
		@unknown default:
			return .Denied
		}
	}

	static private func execAuthorization() -> CNAuthorizeState {
		let result: CNAuthorizeState
		let status = CNContactStore.authorizationStatus(for: .contacts)
		switch status {
		case .authorized:
			result = .Authorized
		case .denied:
			result = .Denied
		case .notDetermined, .restricted:
			let store = CNContactStore()
			var accres: CNAuthorizeState = .Denied
			store.requestAccess(for: .contacts, completionHandler: {
				(_ granted: Bool, _ error: Error?) -> Void in
				if granted {
					accres = .Authorized
				} else {
					accres = .Denied
				}
			})
			result = accres
		@unknown default:
			result = .Denied
		}
		return result
	}

	public func read() -> ReadResult {
		let keys = [
			CNContactGivenNameKey,
			CNContactMiddleNameKey,
			CNContactFamilyNameKey,
			CNContactEmailAddressesKey,
			CNContactPhoneNumbersKey
		] as Array<CNKeyDescriptor>

		let result: ReadResult
		let store   = CNContactStore()
		let request = CNContactFetchRequest(keysToFetch: keys)
		var contacts: Array<CNContact> = []
		do {
			try store.enumerateContacts(with: request, usingBlock: {
				(contact, _) -> Void in
				contacts.append(contact)
			})
			result = .contacts(contacts)
		} catch let err as NSError {
			result = .error(err)
		} catch {
			let err = NSError.fileError(message: "Abort reading contact info")
			result = .error(err)
		}
		return result
	}
}

/*
public class CNContactDatabase
{
	public enum Key {
		case	givenName
		case	familyName

		public func toString() -> String {
			let result: String
			switch self {
			case .givenName:	result = CNContactGivenNameKey
			case .familyName:	result = CNContactFamilyNameKey
			}
			return result
		}
	}

	private var mState: CNAuthorizeState
	private var mStore: CNContactStore?

	public init(){
		mState = .Undetermined
		mStore = nil
	}
	
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
			@unknown default:
				NSLog("Unknown status")
				mState = .Denied
			}
		}
		return mState
	}

	public enum ReadResult {
		case	done(Array<CNContact>)
		case	error(NSError)
	}

	public func read(keys keyarray: Array<Key>, name nm: String) -> ReadResult {
		if let store = mStore {
			let predicate = CNContact.predicateForContacts(matchingName: nm)
			do {
				let result = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetchValue(keys: keyarray))
				return .done(result)
			} catch let err {
				return .error(err as NSError)
			}
		} else {
			return .error(NSError.fileError(message: "Not authorized"))
		}
	}

	private func keysToFetchValue(keys array: Array<Key>) -> Array<CNKeyDescriptor> {
		var result: Array<CNKeyDescriptor> = []
		for key in array {
			result.append(key.toString() as CNKeyDescriptor)
		}
		return result
	}
}

public class CNAddressBook
{


	public var state: CNAuthorizeState { get { return mState }}

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
		@unknown default:	NSLog("Unknown contact type") ; typestr = "<unknown>"
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
*/

