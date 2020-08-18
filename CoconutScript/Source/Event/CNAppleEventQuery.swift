/**
 * @file	CNAppleEventQuery.swift
 * @brief	Define CNAppleEventQuery class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

//      'want' -- the type of element to identify (or 'prop' when identifying a property)
//      'form', 'seld' -- the reference form and selector data identifying the element(s) or property
//      'from' -- the parent descriptor in the linked list
//
//    For example:
//
//      name of document "ReadMe" [of application "TextEdit"]
//
//    is represented by the following chain of AEDescs:
//
//      {want:'prop', form:'prop', seld:'pnam', from:{want:'docu', form:'name', seld:"ReadMe", from:null}}

// sendEvent: event = <NSAppleEventDescriptor: 'core'\'getd'{ '----':{ 'form':'prop', 'seld':'pnam', 'want':'prop', 'from':{ 'seld':'utxt'("ñºèÃñ¢ê›íË7"), 'want':'docu', 'from':null(), 'form':'name' } } }>


public class CNAppleEventQuery
{
	public enum DataKind {
	case element
	case property
	}

	private var	mDataKind:		DataKind
	private var	mDataType:		CNAppleEventKeyword
	private var	mReferenceForm:		CNAppleEventKeyword
	private var	mReferenceSelector:	CNNativeValue
	private var	mSource:		CNAppleEventQuery?

	public var source: CNAppleEventQuery? {
		get		{ return mSource }
		set(src)	{ mSource = src}
	}

	public init(dataKind dkind: DataKind, dataType dtype: CNAppleEventKeyword, refefenceForm rform: CNAppleEventKeyword, referenceSelector rsel: CNNativeValue){
		mDataKind		= dkind
		mDataType		= dtype
		mReferenceForm		= rform
		mReferenceSelector	= rsel
		mSource			= nil
	}

	public static func get(property prop: CNAppleEventKeyword, from src: CNAppleEventQuery) -> CNAppleEventQuery {
		let kind: 	DataKind		= .property
		let type: 	CNAppleEventKeyword	= .property
		let refform:	CNAppleEventKeyword	= .text
		let refsel:	CNNativeValue		= .enumValue("OSType", Int32(prop.code()))
		let newque = CNAppleEventQuery(dataKind: kind, dataType: type, refefenceForm: refform, referenceSelector: refsel)
		newque.source = src
		return newque
	}

	public static func getNameProperty(from src: CNAppleEventQuery) -> CNAppleEventQuery {
		let selval: CNNativeValue = .enumValue("OSType", Int32(CNAppleEventKeyword.propertyName.code()))
		let newque = CNAppleEventQuery(dataKind: .element, dataType: .property, refefenceForm: .property, referenceSelector: selval)
		newque.source = src
		return newque
	}

	public static func selectDocument(name nm: String) -> CNAppleEventQuery {
		let selval: CNNativeValue = .stringValue(nm)
		let newque = CNAppleEventQuery(dataKind: .element, dataType: .document, refefenceForm: .objectName, referenceSelector: selval)
		return newque
	}

	public func toNativeValue() -> CNNativeValue {
		var dict: Dictionary<String, CNNativeValue> = [:]

		/* identify the element or property */
		let kind: CNAppleEventKeyword
		switch mDataKind {
		case .element:	kind = CNAppleEventKeyword.desiredClass
		case .property:	kind = CNAppleEventKeyword.propertyData
		}
		dict[kind.toString()] = .enumValue("OSType", Int32(mDataType.code()))

		/* reference format */
		dict[CNAppleEventKeyword.format.toString()] = .enumValue("OSType", Int32(mReferenceForm.code()))

		/* data to select reference */
		dict[CNAppleEventKeyword.selectData.toString()] = mReferenceSelector

		/* link to refefence */
		if let src = mSource {
			let srcdesc = src.toNativeValue()
			dict[CNAppleEventKeyword.from.toString()] = srcdesc
		} else {
			let srcdesc = CNNativeValue.nullValue
			dict[CNAppleEventKeyword.from.toString()] = srcdesc
		}

		return .dictionaryValue(dict)
	}
}

