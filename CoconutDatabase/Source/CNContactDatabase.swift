/**
 * @file	CNAddressBook.swift
 * @brief	Define CNAddressBook class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 * @reference
 * - https://qiita.com/kato-i-l/items/0d79e8dcbc15541a5b0f
 */

import CoconutData
import Contacts
import Foundation

public class CNContactDatabase: CNTable
{
	/* Define singleton object */
	public static var mShared: CNContactDatabase? = nil
	public static var shared: CNContactDatabase { get {
		if let db = mShared {
			return db
		} else {
			let newdb = CNContactDatabase()
			mShared   = newdb
			return newdb
		}
	}}

	private enum State: Int32 {
		case undecided			= 0
		case accessAuthorized		= 1
		case accessDenied		= 2
		case loadFailed			= 3
		case loaded			= 4
	}

	private var mContacts:		Array<CNContactRecord>
	private var mState: 		State

	private init(){
		mContacts	= []
		mState		= .undecided
	}

	public var recordCount: Int { get {
		return mContacts.count
	}}

	public var fieldNames: Array<String> { get {
		return CNContactField.allFieldNames
	}}

	public func newRecord() -> CNRecord {
		return CNContactRecord(mutableContext: CNMutableContact())
	}

	public func record(at row: Int) -> CNRecord? {
		if 0<=row && row<mContacts.count {
			return mContacts[row]
		} else {
			return nil
		}
	}

	public func append(record rcd: CNRecord) {
		if let nrcd = rcd as? CNContactRecord {
			mContacts.append(nrcd)
		} else {
			CNLog(logLevel: .error, message: "Unexpected record type: \(rcd)", atFunction: #function, inFile: #file)
		}
	}

	public func forEach(callback cbfunc: (_ record: CNRecord) -> Void) {
		do {
			try mContacts.forEach({
				(_ record: CNRecord) throws -> Void in
				cbfunc(record)
			})
		} catch let err as NSError {
			CNLog(logLevel: .error, message: err.description, atFunction: #function, inFile: #file)
		}
	}

	public func authorize(callback cbfunc: @escaping (_ state: Bool) -> Void) {
		switch mState {
		case .accessAuthorized, .loaded:
			cbfunc(true)
			return
		case .undecided:
			break // continue
		case .accessDenied, .loadFailed:
			cbfunc(false)
			return
		}

		switch CNContactStore.authorizationStatus(for: .contacts) {
		case .authorized:
			mState = .accessAuthorized
			cbfunc(true)
		case .denied:
			mState = .accessDenied
			cbfunc(false)
		case .notDetermined, .restricted:
			let store     = CNContactStore()
			store.requestAccess(for: .contacts, completionHandler: {
				(_ granted: Bool, _ error: Error?) -> Void in
				if granted {
					self.mState = .accessAuthorized
					cbfunc(true)
				} else {
					self.mState = .accessDenied
					cbfunc(false)
				}
			})
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown case", atFunction: #function, inFile: #file)
			mState = .accessDenied
			cbfunc(false)
		}
	}

	public func load(fromURL url: URL?) -> CNTableLoadResult {
		switch mState {
		case .undecided, .accessDenied, .loadFailed, .loaded:
			break
		case .accessAuthorized:
			var keys: Array<CNKeyDescriptor> = []
			let props = CNContactField.allFields
			for prop in props {
				keys.append(prop.toKey() as CNKeyDescriptor)
			}
			do {
				let request = CNContactFetchRequest(keysToFetch: keys)
				try CNContactStore().enumerateContacts(with: request, usingBlock: {
					(contact, _) -> Void in
					let contobj = CNContactRecord(contact: contact)
					self.mContacts.append(contobj)
				})
				mState = .loaded
			} catch {
				mState = .loadFailed
			}
		}
		switch mState {
		case .loaded:		return .ok
		default:		return .error(NSError.parseError(message: "Failed to load contact database"))
		}
	}

	public func sort(byDescriptors descs: CNSortDescriptors) {
		/* Sort records */
		let records = descs.sort(source: mContacts, comparator: {
			(_ rec0: CNContactRecord, _ rec1: CNContactRecord, _ key: String) -> ComparisonResult in
			return rec0.compare(rec1, byField: key)
		})
		/* Update array */
		mContacts = records
	}
}
