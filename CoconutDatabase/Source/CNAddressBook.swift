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
	public init(){
		
	}

	public enum AutorizedStatus {
		case authorized
		case denied(NSError)
	}

	public func checkAccessibility(callback cbfunc: @escaping (_ result: AutorizedStatus) -> Void) {
		let status = CNContactStore.authorizationStatus(for: .contacts)
		switch status {
		case .authorized:
			cbfunc(.authorized)
		case .denied:
			let err = NSError.fileError(message: "Access denied")
			cbfunc(.denied(err))
		case .notDetermined, .restricted:
			let store = CNContactStore()
			store.requestAccess(for: .contacts, completionHandler: {
				(_ granted: Bool, _ error: Error?) -> Void in
				if granted {
					cbfunc(.authorized)
				} else {
					let err = NSError.fileError(message: "Access denied")
					cbfunc(.denied(err))
				}
			})
		@unknown default:
			let err = NSError.fileError(message: "Unknown error")
			cbfunc(.denied(err))
		}
	}
}

/*
public class CNAddressRecord: CNDataRecord
{
	public static let FieldCount = 1
	public enum FieldType: Int {
		case givenName	= 0
	}

	public init(){
		super.init(fieldCount: CNAddressRecord.FieldCount)
	}

	public var givenName: String? {
		get {
			if let val = super.field(index: FieldType.givenName.rawValue){
				return val.toString()
			} else {
				return nil
			}
		}
		set(name){
			let value: CNNativeValue
			if let n = name {
				value = .stringValue(n)
			} else {
				value = .nullValue
			}
			super.setField(index: FieldType.givenName.rawValue, value: value)
		}
	}
}

public class CNAddressBook
{
	public enum ReadResult {
		case table(CNDataTable)
		case error(NSError)
	}

	public init(){
	}

	public func read(callback: @escaping (_ status : ReadResult) -> Void){
		let status = CNContactStore.authorizationStatus(for: .contacts)
		switch status {
		case .authorized:
			callback(readContent())
		case .denied:
			let err = NSError.fileError(message: "Access denied")
			callback(.error(err))
		case .restricted:
			let err = NSError.fileError(message: "Not authorized")
			callback(.error(err))
		case .notDetermined:
			CNContactStore().requestAccess(for: .contacts, completionHandler: {
				(granted, _) -> Void in
				if granted {
					callback(self.readContent())
				} else {
					let err = NSError.fileError(message: "Request failed")
					callback(.error(err))
				}
			})
		@unknown default:
			let err = NSError.fileError(message: "Unknown error")
			callback(.error(err))
		}
	}

	private func readContent() -> ReadResult {
		let keys = [
			CNContactGivenNameKey,
			CNContactMiddleNameKey,
			CNContactFamilyNameKey,
			CNContactEmailAddressesKey,
			CNContactPhoneNumbersKey
		] as Array<CNKeyDescriptor>

		do {
			let request = CNContactFetchRequest(keysToFetch: keys)
			let table   = CNDataTable()

			try CNContactStore().enumerateContacts(with: request, usingBlock: {
				(contact, _) -> Void in
				let record = self.contactToRecord(contact: contact)
				table.append(record: record)
			})

			return .table(table)
		} catch {
			let err = NSError.fileError(message: "Failed to read contacts")
			return .error(err)
		}
	}

	private func contactToRecord(contact ctct: CNContact) -> CNAddressRecord {
		let newrect = CNAddressRecord()
		newrect.givenName = ctct.givenName
		NSLog("givenName = \(String(describing: newrect.givenName))")
		return newrect
	}
}
*/

