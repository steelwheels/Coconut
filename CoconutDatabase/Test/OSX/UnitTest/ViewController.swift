//
//  ViewController.swift
//  UnitTest
//
//  Created by Tomoo Hamada on 2021/05/07.
//

import CoconutData
import CoconutDatabase
import Contacts
import Cocoa

class ViewController: NSViewController
{
	override func viewDidLoad() {
		super.viewDidLoad()

		CNPreference.shared.systemPreference.logLevel = .detail
	}

	override func viewDidAppear() {
		super.viewDidAppear()
		self.authorize()
		self.table()
		self.record()
	}

	private func authorize() {
		let db = CNContactDatabase.shared
		db.authorize(callback: {
			(_ granted: Bool) -> Void in
			if granted {
				NSLog("Authorization: OK")
				if db.load() {
					NSLog("Loading ... OK")
					db.forEach(callback: {
						(_ record: CNContactRecord) -> Void in
						self.print(record: record)
					})
				} else {
					NSLog("Loading ... Error")
				}
			} else {
				NSLog("Authorization: Error")
			}
		})
	}

	private func print(record rcd: CNContactRecord) {
		let ident  = rcd.identifier.toText().toStrings().joined(separator: "\n")
		let family = rcd.familyName.toText().toStrings().joined(separator: "\n")
		let given  = rcd.givenName.toText().toStrings().joined(separator: "\n")
		NSLog("ident=\(ident), family=\(family), given=\(given)")
	}

	private func table() {
		let table = CNContactTable()
		table.load(callback: {
			(_ result: Bool) -> Void in
			if result {
				NSLog("table: load ... OK")
			} else {
				NSLog("table: load ... NG")
			}
		})
		let colnum = table.columnCount
		let rownum = table.rowCount
		NSLog("column num = \(colnum), row num = \(rownum)")

		for cidx in 0..<colnum {
			let title = table.title(column: cidx)
			NSLog("title[\(cidx)]: \(title)")
		}

		for ridx in 0..<rownum {
			for cidx in 0..<colnum {
				let val = table.value(columnIndex: .number(cidx), row: ridx)
				let str = val.toText().toStrings().joined()
				NSLog("(\(ridx), \(cidx)): \(str)")
			}
		}

		NSLog("**** Sort")
		let desc = CNSortDescriptors()
		desc.add(key: CNContactRecord.Property.familyName.toName(), ascending: true)
		table.sort(byDescriptors: desc)
		let propname = CNContactRecord.Property.familyName.toName()
		for ridx in 0..<rownum {
			let val = table.value(columnIndex: .title(propname), row: ridx)
			let str = val.toText().toStrings().joined()
			NSLog("(\(ridx): \(str)")
		}
	}

	private func record() {
		let db     = CNContactDatabase.shared
		guard let record = db.record(at: 0) else {
			NSLog("Failed to get record")
			return
		}

		printElement(elementName: "identifier", value: record.identifier)

		record.contactType = .stringValue("person")
		printElement(elementName: CNContactRecord.Property.contactType.toName(),
			     value: record.contactType)

		record.namePrefix = .stringValue("Sgt.")
		printElement(elementName: CNContactRecord.Property.namePrefix.toName(),
			     value: record.namePrefix)

		record.givenName = .stringValue("Peppers")
		printElement(elementName: CNContactRecord.Property.givenName.toName(),
			     value: record.givenName)

		record.middleName = .stringValue("LonlyHearts")
		printElement(elementName: CNContactRecord.Property.middleName.toName(),
			     value: record.middleName)

		record.familyName = .stringValue("ClubBand")
		printElement(elementName: CNContactRecord.Property.familyName.toName(),
			     value: record.familyName)

		record.previousFamilyName = .stringValue("Lucy")
		printElement(elementName: CNContactRecord.Property.previousFamilyName.toName(),
			     value: record.previousFamilyName)

		record.nameSuffix = .stringValue("In")
		printElement(elementName: CNContactRecord.Property.nameSuffix.toName(),
			     value: record.nameSuffix)

		record.nickname = .stringValue("The")
		printElement(elementName: CNContactRecord.Property.nickname.toName(),
			     value: record.nickname)

		record.phoneticGivenName = .stringValue("Sky")
		printElement(elementName: CNContactRecord.Property.phoneticGivenName.toName(),
			     value: record.phoneticGivenName)

		record.phoneticMiddleName = .stringValue("With")
		printElement(elementName: CNContactRecord.Property.phoneticMiddleName.toName(),
			     value: record.phoneticMiddleName)

		record.phoneticFamilyName = .stringValue("Diamonds")
		printElement(elementName: CNContactRecord.Property.phoneticFamilyName.toName(),
			     value: record.phoneticFamilyName)

		record.jobTitle = .stringValue("Programmer")
		printElement(elementName: CNContactRecord.Property.jobTitle.toName(),
			     value: record.jobTitle)

		record.departmentName = .stringValue("The 08th MS Team")
		printElement(elementName: CNContactRecord.Property.departmentName.toName(),
			     value: record.departmentName)

		record.organizationName = .stringValue("A.E.U.G")
		printElement(elementName: CNContactRecord.Property.organizationName.toName(),
			     value: record.organizationName)

		record.phoneticOrganizationName = .stringValue("United Nation Troops")
		printElement(elementName: CNContactRecord.Property.phoneticOrganizationName.toName(),
			     value: record.phoneticOrganizationName)

		let postaddr  = CNPostalAddress.makeNativeValue(street: "Higashiyama", city: "Kyoto-Shi", state: "Kyoto-Fu", postalCode: "605-0862", country: "Japan")
		let postaddrs: Dictionary<String, CNNativeValue> = [
			"main": postaddr
		]
		record.postalAddresses = .dictionaryValue(postaddrs)
		printElement(elementName: CNContactRecord.Property.postalAddresses.toName(),
			     value: record.postalAddresses)

		let eaddrs: Dictionary<String, CNNativeValue> = [
			"main": .stringValue("steel.wheels.project@gmail.com")
		]
		record.emailAddresses = .dictionaryValue(eaddrs)
		printElement(elementName: CNContactRecord.Property.emailAddresses.toName(),
			     value: record.emailAddresses)

		let uaddrs: Dictionary<String, CNNativeValue> = [
			"main": .stringValue("https://github.com/steelwheels")
		]
		record.urlAddresses = .dictionaryValue(uaddrs)
		printElement(elementName: CNContactRecord.Property.urlAddresses.toName(),
			     value: record.urlAddresses)

		let imaddr = CNInstantMessageAddress.makeNativeValue(service: "Twitter", userName: "SteelWheels")
		let imaddrs: Dictionary<String, CNNativeValue> = [
			"main": imaddr
		]
		record.instantMessageAddresses = .dictionaryValue(imaddrs)
		printElement(elementName: CNContactRecord.Property.instantMessageAddresses.toName(),
			     value: record.instantMessageAddresses)


		let phones: Dictionary<String, CNNativeValue> = [
			"main": .stringValue("012-345-6789")
		]
		record.phoneNumbers = .dictionaryValue(phones)
		printElement(elementName: CNContactRecord.Property.phoneNumbers.toName(),
			     value: record.phoneNumbers)

		let birtyday = Date(timeIntervalSinceNow: 0)
		record.birthday = .dateValue(birtyday)
		printElement(elementName: CNContactRecord.Property.birthday.toName(),
			     value: record.birthday)

		let ngbirthday = Date(timeIntervalSince1970: 0)
		record.nonGregorianBirthday = .dateValue(ngbirthday)
		printElement(elementName: CNContactRecord.Property.nonGregorianBirthday.toName(),
			     value: record.nonGregorianBirthday)

		let dates: Dictionary<String, CNNativeValue> = [
			"a": .dateValue(birtyday),
			"b": .dateValue(ngbirthday)
		]
		record.dates = .dictionaryValue(dates)
		printElement(elementName: CNContactRecord.Property.dates.toName(),
			     value: record.dates)

		record.note = .stringValue("This is note")
		printElement(elementName: CNContactRecord.Property.note.toName(),
			     value: record.note)

		let relations: Dictionary<String, CNNativeValue> = [
			"a": .stringValue("rel-a"),
			"b": .stringValue("rel-b")
		]
		record.relations = .dictionaryValue(relations)
		printElement(elementName: CNContactRecord.Property.relations.toName(),
			     value: record.relations)

		/*
		switch self {
		case .imageData:		result = CNContactImageDataKey
		case .thumbnailImageData:	result = CNContactThumbnailImageDataKey
		case .imageDataAvailable:	result = CNContactImageDataAvailableKey
		*/
	}

	private func printElement(elementName name: String, value val: CNNativeValue){
		let valstr = val.toText().toStrings().joined(separator: "\n")
		NSLog("element: \(name), value: \(valstr)")
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}

