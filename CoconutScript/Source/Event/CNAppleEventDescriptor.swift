/**
 * @file	CNAppleEventDescriptor.swift
 * @brief	Define CNAppleEventDescriptor class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

/* Reference: http://frontierkernel.sourceforge.net/cgi-bin/lxr/source/Common/headers/macconv.h */
public enum CNAppleEventKeyword {
	case appleEvent
	case coreSuite
	case createElement
	case objectClass
	case propertyData
	case quit

	public func toString() -> String {
		let result: String
		switch self {
		case .appleEvent:	result = "aevt"
		case .coreSuite:	result = "core"
		case .createElement:	result = "crel"
		case .propertyData:	result = "prdt"
		case .objectClass:	result = "kocl"
		case .quit:		result = "quit"
		}
		return result
	}
}


public class CNAppleEventDescriptor
{
	static private let keyDirectObject: OSType = 0x2D2D2D2D

	private var	mEventClass:		String
	private var	mEventID:		String
	private var	mParameters:		Dictionary<String, CNNativeValue>
	private var	mDirectParameter:	CNNativeValue?

	public var eventClass: String					{ get { return mEventClass	}}
	public var eventID: String					{ get { return mEventID		}}
	public var parameters: Dictionary<String, CNNativeValue>	{ get { return mParameters	}}
	public var directParameter: CNNativeValue?			{ get { return mDirectParameter	}}

	public init(eventClass eclass: String, eventId eid: String) {
		mEventClass		= eclass
		mEventID		= eid
		mParameters		= [:]
		mDirectParameter	= nil
	}

	public func setParameter(value val: CNNativeValue, forKeyword key: String){
		mParameters[key] = val
	}

	public func setDirectParameter(value val: CNNativeValue?) {
		mDirectParameter = val
	}

	public func toEvent(target targ: NSAppleEventDescriptor) -> NSAppleEventDescriptor {
		let eclass = NSAppleEventDescriptor.codeValue(code: mEventClass)
		let eid    = NSAppleEventDescriptor.codeValue(code: mEventID)

		let retid:   AEReturnID	     = AEReturnID(kAutoGenerateReturnID)
		let transid: AETransactionID = AETransactionID(kAnyTransactionID)

		let event = NSAppleEventDescriptor(eventClass: eclass, eventID: eid, targetDescriptor: targ, returnID: retid, transactionID: transid)

		/* Add keyword parameter */
		for (pkey, pval) in mParameters {
			let pdesc = pval.toEventDescriptor()
			event.set(descriptor: pdesc, forKeyword: pkey)
		}
		/* Set direct parameter */
		if let dirval = mDirectParameter {
			let dirdesc = dirval.toEventDescriptor()
			event.setParam(dirdesc, forKeyword: CNAppleEventDescriptor.keyDirectObject)
		}

		/* Set signature */
		//event.setAttribute(NSAppleEventDescriptor(), forKeyword: CNReceiverApplication.keySubjectAttr)
		/* Set condsidring */
		//let _kAECase: OSType = 0x63617365
		//event.setAttribute(NSAppleEventDescriptor(enumCode: _kAECase), forKeyword: CNReceiverApplication.enumConsiderations)
		//event.setAttribute(NSAppleEventDescriptor(int32: 12451841), forKeyword: CNReceiverApplication.enumConsidsAndIgnores)

		return event
	}
}

