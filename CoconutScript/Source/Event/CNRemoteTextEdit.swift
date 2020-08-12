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

	public func openDocument() {
		let event = CNAppleEventDescriptor(eventClass: CNAppleEventKeyword.coreSuite.toString(),
						   eventId:    CNAppleEventKeyword.createElement.toString())
		let pval: CNNativeValue = .numberValue(NSNumber(integerLiteral: Int(NSAppleEventDescriptor.codeValue(code: "docu"))))
		event.setParameter(value: pval, forKeyword: CNAppleEventKeyword.objectClass.toString())

		let context: Dictionary<String, CNNativeValue> = [
			"ctxt": .stringValue("Hello world")
		]
		let dict: CNNativeValue = .dictionaryValue(context)
		event.setParameter(value: dict, forKeyword: CNAppleEventKeyword.propertyData.toString())

		if self.sendEvent(eventDescriptor: event) {
			NSLog("send event .. done")
		} else {
			NSLog("send event .. failed")
		}
	}
}
