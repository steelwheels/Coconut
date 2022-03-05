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
	private enum ContactHandle {
		case none
		case immutable(CNContact)
		case mutable(CNMutableContact)
	}

	private var mContact:		ContactHandle
	private var mFieldNames:	Dictionary<String, CNContactField>
	private var mIsDirty:		Bool

	public init(contact ctct: CNContact){
		mContact	= .immutable(ctct)
		mFieldNames	= [:]
		mIsDirty	= true
		let num = CNContactField.numberOfFields
		for i in 0..<num {
			if let fld = CNContactField(rawValue: i) {
				mFieldNames[fld.toName()] = fld
			}
		}
	}

	public init(mutableContext ctct: CNMutableContact){
		mContact	= .mutable(ctct)
		mFieldNames	= [:]
		mIsDirty	= true
		let num = CNContactField.numberOfFields
		for i in 0..<num {
			if let fld = CNContactField(rawValue: i) {
				mFieldNames[fld.toName()] = fld
			}
		}
	}

	public init(){
		mContact	= .none
		mFieldNames	= [:]
		mIsDirty	= true
		let num = CNContactField.numberOfFields
		for i in 0..<num {
			if let fld = CNContactField(rawValue: i) {
				mFieldNames[fld.toName()] = fld
			}
		}
	}

	public var contactType: CNContactType? { get {
		if let cont = self.contact {
			return cont.contactType
		} else {
			return nil
		}
	}}

	public var fieldCount: Int { get {
		return CNContactField.numberOfFields
	}}

	public var fieldNames: Array<String> { get {
		return Array(mFieldNames.keys)
	}}

	public var isDirty: Bool { get {
		return mIsDirty
	}}

	public var filledFieldNames: Array<String> { get {
		var result: Array<String> = []
		for key in mFieldNames.keys {
			if let field = mFieldNames[key] {
				if let val = value(ofField: field) {
					if !val.isEmpty() {
						result.append(key)
					}
				}
			}
		}
		return result
	}}

	private var contact: CNContact? { get {
		let result: CNContact?
		switch mContact {
		case .none:
			result = nil
		case .immutable(let ctct):
			result = ctct
		case .mutable(let ctct):
			result = ctct
		}
		return result
	}}

	private var mutableContact: CNMutableContact? { get {
		let result: CNMutableContact?
		switch mContact {
		case .none:
			result = nil
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
	}}

	public func value(ofField name: String) -> CNValue? {
		if let fld = mFieldNames[name] {
			return value(ofField: fld)
		} else {
			return nil
		}
	}

	public func setValue(value val: CNValue, forField name: String) -> Bool {
		if let fld = mFieldNames[name] {
			mIsDirty = true
			return setValue(value: val, forField: fld)
		} else {
			return false
		}
	}

	private func value(ofField fld: CNContactField) -> CNValue? {
		guard let cont = self.contact else {
			return nil
		}

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

	private func setValue(value val: CNValue, forField fld: CNContactField) -> Bool {
		guard let mcont = mutableContact else {
			return false
		}
		var result = false
		switch fld {
		case .identifier:
			break
		case .contactType:
			if let ctype = CNContactType.decode(value: val) {
				mcont.contactType = ctype
				result = true
			}
		case .namePrefix:
			if let str = val.toString() {
				mcont.namePrefix = str
				result = true
			}
		case .givenName:
			if let str = val.toString() {
				mcont.givenName = str
				result = true
			}
		case .middleName:
			if let str = val.toString() {
				mcont.middleName = str
				result = true
			}
		case .familyName:
			if let str = val.toString() {
				mcont.familyName = str
				result = true
			}
		case .previousFamilyName:
			if let str = val.toString() {
				mcont.previousFamilyName = str
				result = true
			}
		case .nameSuffix:
			if let str = val.toString() {
				mcont.nameSuffix = str
				result = true
			}
		case .nickname:
			if let str = val.toString() {
				mcont.nickname = str
				result = true
			}
		case .phoneticGivenName:
			if let str = val.toString() {
				mcont.phoneticGivenName = str
				result = true
			}
		case .phoneticMiddleName:
			if let str = val.toString() {
				mcont.phoneticMiddleName = str
				result = true
			}
		case .phoneticFamilyName:
			if let str = val.toString() {
				mcont.phoneticFamilyName = str
				result = true
			}
		case .jobTitle:
			if let str = val.toString() {
				mcont.jobTitle = str
				result = true
			}
		case .departmentName:
			if let str = val.toString() {
				mcont.departmentName = str
				result = true
			}
		case .organizationName:
			if let str = val.toString() {
				mcont.organizationName = str
				result = true
			}
		case .phoneticOrganizationName:
			if let str = val.toString() {
				mcont.phoneticOrganizationName = str
				result = true
			}
		case .postalAddresses:
			mcont.postalAddresses = CNPostalAddress.decode(value: val)
			result = true
		case .emailAddresses:
			if let addrs = CNLabeledStrings.decode(value: val) {
				mcont.emailAddresses = addrs
				result = true
			}
		case .urlAddresses:
			if let addrs = CNLabeledStrings.decode(value: val) {
				mcont.urlAddresses = addrs
				result = true
			}
		case .instantMessageAddresses:
			mcont.instantMessageAddresses = CNLabeledInstantMessageAddresses.decode(value: val)
			result = true
		case .phoneNumbers:
			mcont.phoneNumbers = CNPhoneNumber.decode(value: val)
			result = true
		case .birthday:
			if let date = val.toDate() {
				mcont.birthday = CNContactDate.decode(date: date)
				result = true
			}
		case .nonGregorianBirthday:
			if let date = val.toDate() {
				mcont.nonGregorianBirthday = CNContactDate.decode(date: date)
				result = true
			}
		case .dates:
			if let dates = CNLabeledDates.decode(value: val) {
				mcont.dates = dates
				result = true
			}
		case .note:
			if let str = val.toString() {
				mcont.note = str
				result = true
			}
		case .imageData:
			if let img = val.toImage() {
				mcont.imageData = img.pngData()
			}
		case .thumbnailImageData:
			break
		case .imageDataAvailable:
			break
		case .relations:
			mcont.contactRelations = CNContactRelation.decode(value: val)
			result = true
		}
		if !result {
			CNLog(logLevel: .error, message: "Failed to set property: \(fld.toName())", atFunction: #function, inFile: #file)
		}
		return result
	}
	
	public func save(){
		switch mContact {
		case .none:
			break		// No content
		case .immutable(_):
			break		// Not modified
		case .mutable(let cont):
			let req = CNSaveRequest()
			req.update(cont)
			let store = CNContactStore()
			do {
				try store.execute(req)
				mIsDirty = false
			}
			catch let err as NSError {
				CNLog(logLevel: .error, message: "Failed to save record: \(err.toString())",
				      atFunction: #function, inFile: #file)
			}
		}
	}

	public func compare(_ s1: CNContactRecord, byField fld: String) -> ComparisonResult {
		let v0 = self.value(ofField: fld) ?? .nullValue
		let v1 = s1.value(ofField:   fld) ?? .nullValue
		return CNCompareValue(nativeValue0: v0, nativeValue1: v1)
	}
}


