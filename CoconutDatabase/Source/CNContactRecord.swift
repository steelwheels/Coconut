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
		case immutable(CNContact)
		case mutable(CNMutableContact)
	}

	private var mContact:		ContactHandle
	private var mFieldNames:	Dictionary<String, CNContactField>

	public init(contact ctct: CNContact){
		mContact	= .immutable(ctct)
		mFieldNames	= [:]
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
		let num = CNContactField.numberOfFields
		for i in 0..<num {
			if let fld = CNContactField(rawValue: i) {
				mFieldNames[fld.toName()] = fld
			}
		}
	}

	public var fieldCount: Int { get {
		return CNContactField.numberOfFields
	}}

	public var fieldNames: Array<String> { get {
		return CNContactField.allFieldNames
	}}

	private var contact: CNContact { get {
		switch mContact {
		case .immutable(let ctct):
			return ctct
		case .mutable(let ctct):
			return ctct
		}
	}}

	private var mutableContact: CNMutableContact {
		get {
			let result: CNMutableContact
			switch mContact {
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
		}
	}

	public func value(ofField name: String) -> CNNativeValue? {
		if let fld = mFieldNames[name] {
			return value(ofField: fld)
		} else {
			return nil
		}
	}

	public func setValue(value val: CNNativeValue, forField name: String) -> Bool {
		if let fld = mFieldNames[name] {
			return setValue(value: val, forField: fld)
		} else {
			return false
		}
	}

	private func value(ofField fld: CNContactField) -> CNNativeValue? {
		var result: CNNativeValue? = nil
		let cont = contact
		switch fld {
		case .identifier:
			result = .stringValue(cont.identifier)
		case .contactType:
			result = cont.contactType.getNativeValue()
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
			result = CNPostalAddress.makeNativeValue(addresses: cont.postalAddresses)
		case .emailAddresses:
			result = makeNativeValue(labeledStrings: cont.emailAddresses)
		case .urlAddresses:
			result = makeNativeValue(labeledStrings: cont.urlAddresses)
		case .instantMessageAddresses:
			result = CNInstantMessageAddress.makeNativeValue(addresses: cont.instantMessageAddresses)
		case .phoneNumbers:
			result = CNPhoneNumber.makeNativeValue(numbers: cont.phoneNumbers)
		case .birthday:
			result = makeNativeValue(dateComponents: cont.birthday)
		case .nonGregorianBirthday:
			result = makeNativeValue(dateComponents: cont.nonGregorianBirthday)
		case .dates:
			result = makeNativeValue(labeledDateComponents: cont.dates)
		case .note:
			result = .stringValue(cont.note)
		case .imageData:
			result = makeNativeValue(imageData: cont.imageData)
		case .thumbnailImageData:
			result = makeNativeValue(imageData: cont.thumbnailImageData)
		case .imageDataAvailable:
			result = .numberValue(NSNumber(booleanLiteral: cont.imageDataAvailable))
		case .relations:
			result = CNContactRelation.makeNativeValue(relations: cont.contactRelations)
		}
		return result
	}

	private func makeNativeValue(labeledStrings lstrs: Array<CNLabeledValue<NSString>>) -> CNNativeValue {
		var result: Dictionary<String, CNNativeValue> = [:]
		for lval in lstrs {
			if let label = lval.label {
				result[label] = .stringValue(lval.value as String)
			}
		}
		return .dictionaryValue(result)
	}

	private func makeNativeValue(dateComponents dcomp: DateComponents?) -> CNNativeValue {
		if let compp = dcomp {
			if let date = compp.date {
				return .dateValue(date)
			}
		}
		return .nullValue
	}

	private func makeNativeValue(labeledDateComponents comps: Array<CNLabeledValue<NSDateComponents>>) -> CNNativeValue {
		var result: Dictionary<String, CNNativeValue> = [:]
		for comp in comps {
			if let label = comp.label {
				result[label] = makeNativeValue(dateComponents: comp.value as DateComponents)
			}
		}
		return .dictionaryValue(result)
	}

	private func makeNativeValue(imageData datap: Data?) -> CNNativeValue {
		if let data = datap {
			if let img = CNImage(data: data) {
				return .imageValue(img)
			}
		}
		return .nullValue
	}

	private func setValue(value val: CNNativeValue, forField fld: CNContactField) -> Bool {
		var result = false
		let mcont  = mutableContact
		switch fld {
		case .identifier:
			break
		case .contactType:
			if let ctype = CNContactType.fromNativeValue(value: val) {
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
			mcont.postalAddresses = CNPostalAddress.decodePostalAddresses(value: val)
			result = true
		case .emailAddresses:
			if let addrs = decodeLabeledString(value: val) {
				mcont.emailAddresses = addrs
				result = true
			}
		case .urlAddresses:
			if let addrs = decodeLabeledString(value: val) {
				mcont.urlAddresses = addrs
				result = true
			}
		case .instantMessageAddresses:
			mcont.instantMessageAddresses = CNInstantMessageAddress.decodeInstantMessageAddresses(value: val)
			result = true
		case .phoneNumbers:
			mcont.phoneNumbers = CNPhoneNumber.decodePhoneNumbers(value: val)
			result = true
		case .birthday:
			if let date = val.toDate() {
				mcont.birthday = dateToComponent(date: date)
				result = true
			}
		case .nonGregorianBirthday:
			if let date = val.toDate() {
				mcont.nonGregorianBirthday = dateToComponent(date: date)
				result = true
			}
		case .dates:
			if let dates = decodeLabeledDateComponent(value: val) {
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
			mcont.contactRelations = CNContactRelation.decodeRelations(value: val)
			result = true
		}
		if !result {
			CNLog(logLevel: .error, message: "Failed to set property: \(fld.toName())", atFunction: #function, inFile: #file)
		}
		return result
	}

	private func decodeLabeledString(value val: CNNativeValue) -> Array<CNLabeledValue<NSString>>? {
		if let dict = val.toDictionary() {
			var result: Array<CNLabeledValue<NSString>> = []
			for (key, val) in dict {
				if let valstr = val.toString() {
					let labstr = CNLabeledValue(label: key, value: valstr as NSString)
					result.append(labstr)
				}
			}
			return result
		} else {
			return nil
		}
	}

	private func decodeLabeledDateComponent(value val: CNNativeValue) -> Array<CNLabeledValue<NSDateComponents>>? {
		if let dict = val.toDictionary() {
			var result: Array<CNLabeledValue<NSDateComponents>> = []
			for (key, val) in dict {
				if let date = val.toDate() {
					let comp = dateToComponent(date: date)
					let labstr = CNLabeledValue(label: key, value: comp as NSDateComponents)
					result.append(labstr)
				}
			}
			return result
		} else {
			return nil
		}
	}

	private func dateToComponent(date src: Date) -> DateComponents {
		return Calendar.current.dateComponents(in: TimeZone.current, from: src)
	}

	public func save(){
		switch mContact {
		case .immutable(_):
			break		// Not modified
		case .mutable(let cont):
			let req = CNSaveRequest()
			req.update(cont)
			let store = CNContactStore()
			do {
				try store.execute(req)
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
		return CNCompareNativeValue(nativeValue0: v0, nativeValue1: v1)
	}

	public func toNativeValue() -> CNNativeValue {
		var result: Dictionary<String, CNNativeValue> = [:]
		let allfield = CNContactField.allFields
		for field in allfield {
			if let val = self.value(ofField: field) {
				switch val {
				case .nullValue:
					break // ignore
				case .stringValue(let str):
					if !str.isEmpty {
						result[field.toName()] = val
					}
				default:
					result[field.toName()] = val
				}
			}
		}
		return .dictionaryValue(result)
	}
}


