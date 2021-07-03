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

public class CNContactDatabase: CNDatabase
{
	public typealias RecordType = CNContactRecord

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

	public var recordCount:	Int   { get { return mContacts.count }}

	private init(){
		mContacts	= []
		mState		= .undecided
	}

	public func authorize(callback cbfunc: @escaping (_ state: Bool) -> Void) {
		guard mState == .undecided else {
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

	public func load() -> Bool {
		switch mState {
		case .undecided, .accessDenied, .loadFailed, .loaded:
			break
		case .accessAuthorized:
			var keys: Array<CNKeyDescriptor> = []
			let props = CNContactRecord.Property.allProperties
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
		return mState == .loaded
	}

	public func record(at index: Int) -> CNContactRecord? {
		switch mState {
		case .loaded:
			if 0<=index && index<mContacts.count {
				return mContacts[index]
			}
		case .undecided, .accessAuthorized, .accessDenied, .loadFailed:
			break
		}
		return nil
	}

	public func append(record rcd: CNContactRecord) {
		switch mState {
		case .loaded:
			mContacts.append(rcd)
		case .undecided, .accessAuthorized, .accessDenied, .loadFailed:
			break
		}
	}

	public func forEach(callback cbfunc: (_ record: CNContactRecord) -> Void){
		do {
			try mContacts.forEach({
				(_ record: CNContactRecord) throws -> Void in
				cbfunc(record)
			})
		} catch let err as NSError {
			CNLog(logLevel: .error, message: err.description, atFunction: #function, inFile: #file)
		}
	}
}

