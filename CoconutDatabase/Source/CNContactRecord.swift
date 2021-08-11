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

/*
public class CNContactRecord: CNRecord
{
	

	/*
	 * mStringTable: Convert property-name to property type
	 */
	private static var	mStringTable:	Dictionary<String, Property>? = nil
	public static func stringToProperty(name nm: String) -> Property? {
		if let table = CNContactRecord.mStringTable {
			return table[nm]
		} else {
			var newtable: Dictionary<String, Property> = [:]
			for idx in 0..<Property.numberOfProperties {
				if let prop = Property(rawValue: idx) {
					newtable[prop.toName()] = prop
				}
			}
			CNContactRecord.mStringTable = newtable
			return newtable[nm]
		}
	}



	public var 		tag:		Int
	private var		mContact:	ContactHandle

	public init(contact cont: CNContact) {
		mContact	= .immutable(cont)
		tag		= 0
	}

	private var contactForRead: CNContact {
		get {
			let result: CNContact
			switch mContact {
			case .immutable(let cont):	result = cont
			case .mutable(let cont):	result = cont
			}
			return result
		}
	}

	private var contactForWrite: CNMutableContact {
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

	public var itemCount: Int {
		get { return Property.numberOfProperties }
	}

	public var identifier: CNNativeValue {
		get { return .stringValue(contactForRead.identifier) }
	}

	public var contactType: CNNativeValue {
		get {
			let str: String
			switch contactForRead.contactType {
			case .organization:	str = "organization"
			case .person:		str = "person"
			@unknown default:
				CNLog(logLevel: .error, message: "Unknown contact type", atFunction: #function, inFile: #file)
				str = "organization"
			}
			return .stringValue(str)
		}
		set(newval){
			if let str = newval.toString() {
				switch str {
				case "organization":
					contactForWrite.contactType = .organization
				case "person":
					contactForWrite.contactType = .person
				default:
					CNLog(logLevel: .error, message: "Unknown contactType: \(str)", atFunction: #function, inFile: #file)
				}
			} else {
				CNLog(logLevel: .error, message: "Unacceptable data as contactType", atFunction: #function, inFile: #file)
			}
		}
	}

	public var namePrefix: CNNativeValue {
		get { return .stringValue(contactForRead.namePrefix) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.namePrefix = str
			}
		}
	}

	public var givenName: CNNativeValue {
		get { return .stringValue(contactForRead.givenName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.givenName = str
			}
		}
	}

	public var middleName: CNNativeValue {
		get { return .stringValue(contactForRead.middleName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.middleName = str
			}
		}
	}

	public var familyName: CNNativeValue {
		get { return .stringValue(contactForRead.familyName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.familyName = str
			}
		}
	}

	public var previousFamilyName: CNNativeValue {
		get { return .stringValue(contactForRead.previousFamilyName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.previousFamilyName = str
			}
		}
	}

	public var nameSuffix: CNNativeValue {
		get { return .stringValue(contactForRead.nameSuffix) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.nameSuffix = str
			}
		}
	}

	public var nickname: CNNativeValue {
		get { return .stringValue(contactForRead.nickname) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.nickname = str
			}
		}
	}

	public var phoneticGivenName: CNNativeValue {
		get { return .stringValue(contactForRead.phoneticGivenName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.phoneticGivenName = str
			}
		}
	}

	public var phoneticMiddleName: CNNativeValue {
		get { return .stringValue(contactForRead.phoneticMiddleName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.phoneticMiddleName = str
			}
		}
	}

	public var phoneticFamilyName: CNNativeValue {
		get { return .stringValue(contactForRead.phoneticFamilyName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.phoneticFamilyName = str
			}
		}
	}

	public var jobTitle: CNNativeValue {
		get { return .stringValue(contactForRead.jobTitle) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.jobTitle = str
			}
		}
	}

	public var departmentName: CNNativeValue {
		get { return .stringValue(contactForRead.departmentName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.departmentName = str
			}
		}
	}

	public var organizationName: CNNativeValue {
		get { return .stringValue(contactForRead.organizationName) }
		set(strval){
			if let str = strval.toString() {
				contactForWrite.organizationName = str
			}
		}
	}

	public var phoneticOrganizationName: CNNativeValue {
		get { return .stringValue(contactForRead.phoneticOrganizationName)}
		set(strval){
			if let str = strval.toString() {
				contactForWrite.phoneticOrganizationName = str
			}
		}
	}

	public var postalAddresses: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let addrs = contactForRead.postalAddresses
			for addr in addrs {
				let label = addr.label ?? "_"
				let value = addr.value.getNativeValue()
				result[label] = value
			}
			return .dictionaryValue(result)
		}
		set(newval){
			if let dict = newval.toDictionary() {
				var addrs: Array<CNLabeledValue<CNPostalAddress>> = []
				for (lab, val) in dict {
					let newaddr = CNMutablePostalAddress()
					newaddr.setNativeValue(val)
					let newlab = CNLabeledValue(label: lab, value: newaddr as CNPostalAddress)
					addrs.append(newlab)
				}
				self.contactForWrite.postalAddresses = addrs
			} else {
				CNLog(logLevel: .error, message: "Unacceptable data as postalAddress", atFunction: #function, inFile: #file)
			}
		}
	}

	public var emailAddresses: CNNativeValue {
		get { return stringAddresses(addresses: contactForRead.emailAddresses) }
		set(newval){
			let addrs = valueToStringAddresses(value: newval)
			contactForWrite.emailAddresses = addrs
		}
	}

	public var urlAddresses: CNNativeValue {
		get { return stringAddresses(addresses: contactForRead.urlAddresses) }
		set(newval){
			let addrs = valueToStringAddresses(value: newval)
			contactForWrite.urlAddresses = addrs
		}
	}

	public var instantMessageAddresses: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let addrs = contactForRead.instantMessageAddresses
			for addr in addrs {
				let label = addr.label ?? "_"
				let value = addr.value.getNativeValue()
				result[label] = value
			}
			return .dictionaryValue(result)
		}
		set(newval){
			if let dict = newval.toDictionary() {
				var result: Array<CNLabeledValue<CNInstantMessageAddress>> = []
				for (lab, val) in dict {
					if let newaddr = CNInstantMessageAddress.fromNativeValue(value: val) {
						result.append(CNLabeledValue(label: lab, value: newaddr))
					}
				}
				contactForWrite.instantMessageAddresses = result
			} else {
				CNLog(logLevel: .error, message: "Unacceptable data as postalAddress", atFunction: #function, inFile: #file)
			}
		}
	}

	private func stringAddresses(addresses addrs: Array<CNLabeledValue<NSString>>) -> CNNativeValue {
		var result: Dictionary<String, CNNativeValue> = [:]
		for addr in addrs {
			let label = addr.label ?? "_"
			let value = addr.value as String
			result[label] = .stringValue(value)
		}
		return .dictionaryValue(result)
	}

	private func valueToStringAddresses(value val: CNNativeValue) -> Array<CNLabeledValue<NSString>> {
		if let dict = val.toDictionary() {
			var result: Array<CNLabeledValue<NSString>> = []
			for (key, val) in dict {
				if let str = val.toString() {
					let newlab = CNLabeledValue(label: key, value: str as NSString)
					result.append(newlab)
				} else {
					CNLog(logLevel: .error, message: "Unexpected value for addresses", atFunction: #function, inFile: #file)
				}
			}
			return result
		} else {
			CNLog(logLevel: .error, message: "Unexpected value for addresses", atFunction: #function, inFile: #file)
			return []
		}
	}

	public var phoneNumbers: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let numbers = contactForRead.phoneNumbers
			for number in numbers {
				let label     = number.label ?? "_"
				result[label] = number.value.getNativeValue()
			}
			return .dictionaryValue(result)
		}
		set(newval){
			if let dict = newval.toDictionary() {
				var result: Array<CNLabeledValue<CNPhoneNumber>> = []
				for (key, val) in dict {
					if let pnum = CNPhoneNumber.fromNativeValue(value: val) {
						let newlab = CNLabeledValue(label: key, value: pnum)
						result.append(newlab)
					}
				}
				contactForWrite.phoneNumbers = result
			} else {
				CNLog(logLevel: .error, message: "Unacceptable data as phonenumbers", atFunction: #function, inFile: #file)
			}
		}
	}

	public var birthday: CNNativeValue {
		get { return dateComponentToValue(component: contactForRead.birthday) }
		set(newval){
			if let date = newval.toDate() {
				contactForWrite.birthday = Calendar.current.dateComponents(in: TimeZone.current, from: date)
			}
		}
	}

	public var nonGregorianBirthday: CNNativeValue {
		get { return dateComponentToValue(component: contactForRead.nonGregorianBirthday) }
		set(newval){
			if let date = newval.toDate() {
				contactForWrite.nonGregorianBirthday = Calendar.current.dateComponents(in: TimeZone.current, from: date)
			}
		}
	}

	private func dateComponentToValue(component comp: DateComponents?) -> CNNativeValue {
		if let compp = comp {
			if let date = compp.date {
				return .dateValue(date)
			}
		}
		return .nullValue
	}

	public var dates: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let comps = contactForRead.dates
			for comp in comps {
				let label = comp.label ?? "_"
				let value = dateComponentToValue(component: comp.value)
				result[label] = value
			}
			return .dictionaryValue(result)
		}
		set(newval){
			if let dict = newval.toDictionary() {
				var result: Array<CNLabeledValue<NSDateComponents>> = []
				for (key, val) in dict {
					if let date = val.toDate() {
						let comp = Calendar.current.dateComponents(in: TimeZone.current, from: date) as NSDateComponents
						let lab  = CNLabeledValue(label: key, value: comp)
						result.append(lab)
					}
				}
				contactForWrite.dates = result
			} else {
				CNLog(logLevel: .error, message: "Unacceptable data as dates", atFunction: #function, inFile: #file)
			}
		}
	}

	private func dateComponentToValue(component comp: NSDateComponents?) -> CNNativeValue {
		if let compp = comp {
			if let date = compp.date {
				return .dateValue(date)
			}
		}
		return .nullValue
	}

	public var note: CNNativeValue {
		get { return .stringValue(contactForRead.note) }
		set(newval){
			if let str = newval.toString() {
				contactForWrite.note = str
			}
		}
	}

	public var imageData: CNNativeValue {
		get { return imageToValue(date: contactForRead.imageData) }
		set(newval){
			if let img = newval.toImage() {
				contactForWrite.imageData = img.pngData()
			}
		}
	}

	public var thumbnailImageData: CNNativeValue {
		get { return imageToValue(date: contactForRead.thumbnailImageData) }
	}

	public var imageDataAvailable: CNNativeValue {
		get { return .numberValue(NSNumber(booleanLiteral: contactForRead.imageDataAvailable)) }
	}

	public var relations: CNNativeValue {
		get {
			var result: Dictionary<String, CNNativeValue> = [:]
			let rels = contactForRead.contactRelations
			for rel in rels {
				let label = rel.label ?? "_"
				let value = rel.value.getNativeValue()
				result[label] = value
			}
			return .dictionaryValue(result)
		}
		set(newval){
			if let dict = newval.toDictionary() {
				var result: Array<CNLabeledValue<CNContactRelation>> = []
				for (key, val) in dict {
					if let str = val.toString() {
						let rel = CNContactRelation(name: str)
						let lab = CNLabeledValue(label: key, value: rel)
						result.append(lab)
					}
				}
				contactForWrite.contactRelations = result
			} else {
				CNLog(logLevel: .error, message: "Unacceptable data as retations", atFunction: #function, inFile: #file)
			}
		}
	}

	public func value(ofField name: String) -> CNNativeValue? {
		if let prop = CNContactRecord.stringToProperty(name: name) {
			let retval = value(forProperty: prop)
			switch retval {
			case .nullValue:
				return nil
			default:
				return retval
			}
		} else {
			CNLog(logLevel: .error, message: "Unknown property: \(name)", atFunction: #function, inFile: #file)
		}
		return nil
	}

	private func value(forProperty prop: Property) -> CNNativeValue {
		let result: CNNativeValue
		switch prop {
		case .identifier:		result = self.identifier
		case .contactType:		result = self.contactType
		case .namePrefix:		result = self.namePrefix
		case .givenName:		result = self.givenName
		case .middleName:		result = self.middleName
		case .familyName:		result = self.familyName
		case .previousFamilyName:	result = self.previousFamilyName
		case .nameSuffix:		result = self.nameSuffix
		case .nickname:			result = self.nickname
		case .phoneticGivenName:	result = self.phoneticGivenName
		case .phoneticMiddleName:	result = self.phoneticMiddleName
		case .phoneticFamilyName:	result = self.phoneticFamilyName
		case .jobTitle:			result = self.jobTitle
		case .departmentName:		result = self.departmentName
		case .organizationName:		result = self.organizationName
		case .phoneticOrganizationName:	result = self.phoneticOrganizationName
		case .postalAddresses:		result = self.postalAddresses
		case .emailAddresses:		result = self.emailAddresses
		case .urlAddresses:		result = self.urlAddresses
		case .instantMessageAddresses:	result = self.instantMessageAddresses
		case .phoneNumbers:		result = self.phoneNumbers
		case .birthday:			result = self.birthday
		case .nonGregorianBirthday:	result = self.nonGregorianBirthday
		case .dates:			result = self.dates
		case .note:			result = self.note
		case .imageData:		result = self.imageData
		case .thumbnailImageData:	result = self.thumbnailImageData
		case .imageDataAvailable:	result = self.imageDataAvailable
		case .relations:		result = self.relations
		}
		return result
	}

	public func setValue(value val: CNNativeValue, forField name: String) -> Bool {
		if let prop = CNContactRecord.stringToProperty(name: name) {
			return setValue(value: val, byProperty: prop)
		} else {
			CNLog(logLevel: .error, message: "Unknown property: \(name)", atFunction: #function, inFile: #file)
			return false
		}
	}

	private func setValue(value val: CNNativeValue, byProperty prop: Property) -> Bool {
		var result = true
		switch prop {
		case .identifier:			CNLog(logLevel: .error, message: "Writing identifier is NOT supported", atFunction: #function, inFile: #file)
		case .contactType:			self.contactType = val
		case .namePrefix:			self.namePrefix = val
		case .givenName:			self.givenName = val
		case .middleName:			self.middleName = val
		case .familyName:			self.familyName = val
		case .previousFamilyName:		self.previousFamilyName = val
		case .nameSuffix:			self.nameSuffix = val
		case .nickname:				self.nickname = val
		case .phoneticGivenName:		self.phoneticMiddleName = val
		case .phoneticMiddleName:		self.phoneticMiddleName = val
		case .phoneticFamilyName:		self.phoneticFamilyName = val
		case .jobTitle:				self.jobTitle = val
		case .departmentName:			self.departmentName = val
		case .organizationName:			self.organizationName = val
		case .phoneticOrganizationName: 	self.phoneticOrganizationName = val
		case .postalAddresses:			self.postalAddresses = val
		case .emailAddresses:			self.emailAddresses = val
		case .urlAddresses:			self.urlAddresses = val
		case .instantMessageAddresses:		self.instantMessageAddresses = val
		case .phoneNumbers:			self.phoneNumbers = val
		case .birthday:				self.birthday = val
		case .nonGregorianBirthday:		self.nonGregorianBirthday = val
		case .dates:				self.dates = val
		case .note:				self.note = val
		case .imageData:			self.imageData = val
		case .thumbnailImageData:
			CNLog(logLevel: .error, message: "Writing thumbnail image is NOT supported", atFunction: #function, inFile: #file)
			result = false
		case .imageDataAvailable:
			CNLog(logLevel: .error, message: "Writing imageDataAvailable is NOT supported", atFunction: #function, inFile: #file)
			result = false
		case .relations:			self.relations = val
		}
		return result
	}


}

*/

