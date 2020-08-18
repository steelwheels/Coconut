/**
 * @file	CNRemoteTextEdit.swift
 * @brief	Define CNRemoteTextEdit class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNRemoteTextEdit: CNReceiverApplication
{
	public init?(){
		if let runapp = CNRemoteApplication.launch(bundleIdentifier: "com.apple.TextEdit") {
			super.init(application: runapp)
		} else {
			return nil
		}
	}

	public func documents() {

	}

	public func newDocument(withText text: String) -> SendEventResult {
		let event = CNAppleEventDescriptor(eventClass: .coreSuite, eventId: .createElement)
		let pdoc  = CNAppleEventKeyword.document.code()
		let pval: CNNativeValue = .enumValue("OSType", Int32(pdoc))
		event.setParameter(value: pval, forKeyword: CNAppleEventKeyword.objectClass)
		let context: Dictionary<String, CNNativeValue> = [
			CNAppleEventKeyword.text.toString(): .stringValue(text)
		]
		let dict: CNNativeValue = .dictionaryValue(context)
		event.setParameter(value: dict, forKeyword: CNAppleEventKeyword.propertyData)
		return self.sendEvent(eventDescriptor: event)
	}

	public func getDocuments(name nm: String) -> SendEventResult {
		let event   = CNAppleEventDescriptor(eventClass: .coreSuite, eventId: .getData)
		let selque  = CNAppleEventQuery.selectDocument(name: nm)
		//let propque = CNAppleEventQuery.get(property: .propertyName, from: selque)
		//let propval = propque.toNativeValue()
		//event.setParameter(value: propval, forKeyword: CNAppleEventKeyword.directObject)
		event.setDirectParameter(value: selque.toNativeValue())
		return self.sendEvent(eventDescriptor: event)
	}
}


