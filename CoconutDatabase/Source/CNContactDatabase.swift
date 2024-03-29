/**
 * @file	CNAddressBook.swift
 * @brief	Define CNAddressBook class
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 * @reference
 * - https://qiita.com/kato-i-l/items/0d79e8dcbc15541a5b0f
 */

import CoconutData
import Contacts
import Foundation

private class CNContactCache
{
	private var 	mIsDirty:		Bool

	public init(){
		mIsDirty	= true
	}

	public var isDirty: Bool {
		get         { return mIsDirty }
		set(newval) { mIsDirty = newval }
	}
}

public class CNContactDatabase: CNTable
{
	public static var className: String { get {
		return "ContactDatabase"
	}}

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

	private var mRecords:			Array<CNRecord>
	private var mState: 			State
	private var mCache:			Dictionary<Int, CNContactCache>
	private var mNextCacheId:		Int
	private var mDefaultFieldCacheId:	Int
	private var mRecordValuesCacheId:	Int

	private init(){
		mRecords		= []
		mState			= .undecided
		mCache			= [:]
		mNextCacheId		= 0
		mDefaultFieldCacheId	= 0
		mRecordValuesCacheId	= 0

		mDefaultFieldCacheId	= allocateDefaultFieldsCache()
		mRecordValuesCacheId	= allocateRecordValuesCache()
	}

	public var identifier: String? { get {
		return nil
	}}

	public func allocateDefaultFieldsCache() -> Int {
		return allocateCache()
	}

	public func allocateRecordValuesCache() -> Int {
		return allocateCache()
	}

	private func allocateCache() -> Int {
		let newcache = CNContactCache()
		let cid      = mNextCacheId
		mCache[cid] = newcache
		mNextCacheId += 1
		return cid
	}

	public func removeCache(cacheId cid: Int) {
		mCache[cid] = nil
	}

	public func isDirty(cacheId cid: Int) -> Bool {
		if let cache = mCache[cid] {
			return cache.isDirty
		} else {
			CNLog(logLevel: .error, message: "Invalid cache id", atFunction: #function, inFile: #file)
			return false
		}
	}

	private func setDirty(cacheId cid: Int) {
		if let cache = mCache[cid] {
			cache.isDirty = true
		} else {
			CNLog(logLevel: .error, message: "Invalid cache id", atFunction: #function, inFile: #file)
		}
	}

	public func setClean(cacheId cid: Int) {
		if let cache = mCache[cid] {
			cache.isDirty = false
		} else {
			CNLog(logLevel: .error, message: "Invalid cache id", atFunction: #function, inFile: #file)
		}
	}

	public func allocateEventFunction(eventFunc efunc: @escaping CNStorage.EventFunction) -> Int {
		CNLog(logLevel: .error, message: "Not supported", atFunction: #function, inFile: #file)
		return 0
	}

	public func removeEventFunction(eventFuncId eid: Int) {
		CNLog(logLevel: .error, message: "Not supported", atFunction: #function, inFile: #file)
	}

	public var recordCount: Int { get {
		return mRecords.count
	}}

	public var defaultFields: Dictionary<String, CNValue> { get {
		var result: Dictionary<String, CNValue> = [:]
		for name in CNContactField.allFieldNames {
			result[name] = .stringValue("")
		}
		return result
	}}

	public var fieldNames: Array<String> { get {
		return CNContactField.allFieldNames
	}}

	public func fieldName(at index: Int) -> String? {
		return CNContactField.fieldName(at: index)
	}

	public func newRecord() -> CNRecord {
		return CNStorageRecord(defaultFields: self.defaultFields)
	}

	public func record(at row: Int) -> CNRecord? {
		if 0<=row && row<mRecords.count {
			return mRecords[row]
		} else {
			return nil
		}
	}

	public func pointer(value val: CNValue, forField field: String) -> CNPointerValue? {
		CNLog(logLevel: .error, message: "Not supported yet", atFunction: #function, inFile: #file)
		return nil
	}

	public func search(value srcval: CNValue, forField field: String) -> Array<CNRecord> {
		var result: Array<CNRecord> = []
		let recnum = mRecords.count
		for i in 0..<recnum {
			let record = mRecords[i]
			if let val = record.value(ofField: field) {
				switch CNCompareValue(nativeValue0: val, nativeValue1: srcval) {
				case .orderedSame:
					result.append(record)
				case .orderedAscending, .orderedDescending:
					break
				}
			}
		}
		return result
	}

	public func append(record rcd: CNRecord) {
		mRecords.append(rcd)
		setDirty(cacheId: mRecordValuesCacheId)
	}

	public func append(pointer ptr: CNPointerValue) {
		CNLog(logLevel: .error, message: "Not supported yet", atFunction: #function, inFile: #file)
	}

	public func remove(at row: Int) -> Bool {
		CNLog(logLevel: .error, message: "Not supported yet: \(row)", atFunction: #function, inFile: #file)
		setDirty(cacheId: mRecordValuesCacheId)
		return false
	}

	public func save() -> Bool {
		CNLog(logLevel: .error, message: "Not supported yet", atFunction: #function, inFile: #file)
		return false
	}

	public func forEach(callback cbfunc: (_ record: CNRecord) -> Void) {
		do {
			try mRecords.forEach({
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
					let record = CNContactDatabase.makeRecord(from: contact)
					self.mRecords.append(record)
				})
				mState = .loaded
				setDirty(cacheId: mRecordValuesCacheId)
			} catch {
				mState = .loadFailed
			}
		}
		switch mState {
		case .loaded:		return .ok
		default:		return .error(NSError.parseError(message: "Failed to load contact database"))
		}
	}

	public static func makeRecord(from contact: CNContact) -> CNRecord {
		var result : Dictionary<String, CNValue> = [:]
		let num    = CNContactField.numberOfFields
		for i in 0..<num {
			if let field = CNContactField(rawValue: i), let name = CNContactField.fieldName(at: i) {
				if let value = self.value(ofField: field, in: contact) {
					result[name] = value
				}
			}
		}
		return CNStorageRecord(defaultFields: result)
	}

	private static func value(ofField fld: CNContactField, in cont: CNContact) -> CNValue? {
		var result: CNValue? = nil
		switch fld {
		case .identifier:
			result = .stringValue(cont.identifier)
		case .contactType:
			result = cont.contactType.encode()
		case .namePrefix:
			result = .stringValue(cont.namePrefix)
		case .givenName:
			result = .stringValue(cont.givenName)
		case .middleName:
			result = .stringValue(cont.middleName)
		case .familyName:
			result = .stringValue(cont.familyName)
		case .previousFamilyName:
			result = .stringValue(cont.previousFamilyName)
		case .nameSuffix:
			result = .stringValue(cont.nameSuffix)
		case .nickname:
			result = .stringValue(cont.nickname)
		case .phoneticGivenName:
			result = .stringValue(cont.phoneticGivenName)
		case .phoneticMiddleName:
			result = .stringValue(cont.phoneticMiddleName)
		case .phoneticFamilyName:
			result = .stringValue(cont.phoneticFamilyName)
		case .jobTitle:
			result = .stringValue(cont.jobTitle)
		case .departmentName:
			result = .stringValue(cont.departmentName)
		case .organizationName:
			result = .stringValue(cont.organizationName)
		case .phoneticOrganizationName:
			result = .stringValue(cont.phoneticOrganizationName)
		case .postalAddresses:
			result = CNPostalAddress.encode(addresses: cont.postalAddresses)
		case .emailAddresses:
			result = CNLabeledStrings.encode(labeledStrings: cont.emailAddresses)
		case .urlAddresses:
			result = CNLabeledStrings.encode(labeledStrings: cont.urlAddresses)
		case .instantMessageAddresses:
			result = CNLabeledInstantMessageAddresses.encode(addresses: cont.instantMessageAddresses)
		case .phoneNumbers:
			result = CNPhoneNumber.encode(numbers: cont.phoneNumbers)
		case .birthday:
			result = CNContactDate.encode(dateComponents: cont.birthday)
		case .nonGregorianBirthday:
			result = CNContactDate.encode(dateComponents: cont.nonGregorianBirthday)
		case .dates:
			result = CNLabeledDates.encode(labeledDateComponents: cont.dates)
		case .note:
			result = .stringValue(cont.note)
		case .imageData:
			result = CNContactImage.encode(imageData: cont.imageData)
		case .thumbnailImageData:
			result = CNContactImage.encode(imageData: cont.thumbnailImageData)
		case .imageDataAvailable:
			result = .numberValue(NSNumber(booleanLiteral: cont.imageDataAvailable))
		case .relations:
			result = CNContactRelation.encode(relations: cont.contactRelations)
		}
		return result
	}

	public func sort(byDescriptors descs: CNSortDescriptors) {
		/* Sort records */
		let records = descs.sort(source: mRecords, comparator: {
			(_ rec0: CNRecord, _ rec1: CNRecord, _ key: String) -> ComparisonResult in
			let val0p = rec0.value(ofField: key)
			let val1p = rec1.value(ofField: key)
			if let val0 = val0p, let val1 = val1p {
				return CNCompareValue(nativeValue0: val0, nativeValue1: val1)
			} else if val0p != nil {
				return .orderedAscending
			} else if val1p != nil {
				return .orderedDescending
			} else {
				return .orderedSame
			}
		})
		/* Update array */
		mRecords = records
	}
}
