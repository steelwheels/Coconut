/**
 * @file	CNAppleEventDescriptor.swift
 * @brief	Define CNAppleEventDescriptor class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNAppleEventDescriptor
{
	private var	mEventClass:		CNAppleEventKeyword
	private var	mEventID:		CNAppleEventKeyword
	private var	mParameters:		Dictionary<CNAppleEventKeyword, CNNativeValue>
	private var	mDirectParameter:	CNNativeValue?

	public var eventClass: CNAppleEventKeyword				{ get { return mEventClass	}}
	public var eventID:    CNAppleEventKeyword				{ get { return mEventID		}}
	public var parameters: Dictionary<CNAppleEventKeyword, CNNativeValue>	{ get { return mParameters	}}
	public var directParameter: CNNativeValue?				{ get { return mDirectParameter	}}

	public init(eventClass eclass: CNAppleEventKeyword, eventId eid: CNAppleEventKeyword) {
		mEventClass		= eclass
		mEventID		= eid
		mParameters		= [:]
		mDirectParameter	= nil
	}

	public func setParameter(value val: CNNativeValue, forKeyword key: CNAppleEventKeyword){
		mParameters[key] = val
	}

	public func setDirectParameter(value val: CNNativeValue?) {
		mDirectParameter = val
	}

	public func elementOfDirectParameter(keyword key: CNAppleEventKeyword) -> CNNativeValue? {
		if let dirparam = mDirectParameter {
			if let dict = dirparam.toDictionary() {
				return dict[key.toString()]
			}
		}
		return nil
	}

	public func dump(to cons: CNConsole) {
		let txt = self.toText()
		txt.print(console: cons, terminal: "")
	}

	private func toText() -> CNText {
		let top = CNTextSection()
		top.header = "apple-event-description: {" ; top.footer = "}"
		top.add(text: CNTextLine(string: "eventClass: \(mEventClass.toString())"))
		top.add(text: CNTextLine(string: "eventID:    \(mEventID.toString())"))

		let params = CNTextSection()
		params.header = "{" ; params.footer = "}"
		for (key, val) in mParameters {
			let keytxt = key.toString()
			let valtxt = val.toText()
			if let valline = valtxt as? CNTextLine {
				params.add(text: CNTextLine(string: "\(keytxt) : \(valline.string)"))
			} else if let valsec = valtxt as? CNTextSection {
				valsec.header = "\(keytxt) : " + valsec.header
				params.add(text: valsec)
			}
		}
		if let dirparam = mDirectParameter {
			let dirtxt = dirparam.toText()
			if let dirline = dirtxt as? CNTextLine {
				params.add(text: CNTextLine(string: "direct-param : \(dirline.string)"))
			} else if let dirsec = dirtxt as? CNTextSection {
				dirsec.header = "direct-param : " + dirsec.header
				params.add(text: dirsec)
			}
		}
		top.add(text: params)
		return top
	}

	public func toEvent(target targ: NSAppleEventDescriptor) -> NSAppleEventDescriptor {
		let eclass = mEventClass.code()
		let eid    = mEventID.code()

		let retid:   AEReturnID	     = AEReturnID(kAutoGenerateReturnID)
		let transid: AETransactionID = AETransactionID(kAnyTransactionID)

		let event = NSAppleEventDescriptor(eventClass: eclass, eventID: eid, targetDescriptor: targ, returnID: retid, transactionID: transid)

		/* Add keyword parameter */
		for (pkey, pval) in mParameters {
			event.setParameter(value: pval, forKeyword: pkey)
		}
		/* Set direct parameter */
		if let dirval = mDirectParameter {
			event.setParameter(value: dirval, forKeyword: .directObject)
		}

		return event
	}
}

public extension NSAppleEventDescriptor {

	func toNativeDescriptor() -> CNAppleEventDescriptor? {
		guard let eclass = CNAppleEventKeyword.encode(keyword: self.eventClass),
		      let eid    = CNAppleEventKeyword.encode(keyword: self.eventID) else {
			NSLog("Unknown event class or event id")
			return nil
		}

		let result = CNAppleEventDescriptor(eventClass: eclass, eventId: eid)

		if let params = self.paramDescriptor(forKeyword: CNAppleEventKeyword.directObject.code()) {
			result.setDirectParameter(value: params.toNativeValue())
		}

		if let errn = self.paramDescriptor(forKeyword: CNAppleEventKeyword.errorNumber.code()) {
			let numobj = NSNumber(integerLiteral: Int(errn.int32Value))
			setParameter(value: .numberValue(numobj), forKeyword: CNAppleEventKeyword.errorNumber)
		}
		if let errs = self.paramDescriptor(forKeyword: CNAppleEventKeyword.errorString.code()) {
			let msg: String
			if let msgstr = errs.stringValue {
				msg = msgstr
			} else {
				msg = "Unknown"
			}
			setParameter(value: .stringValue(msg), forKeyword: CNAppleEventKeyword.errorString)
		}

		return result
	}

	private func toNativeValue() -> CNNativeValue {
		var result: CNNativeValue = .nullValue
		if let desctype = CNAppleEventKeyword.encode(keyword: self.descriptorType) {
			switch desctype {
			case .enumerate:
				let code = self.enumCodeValue
				result = .enumValue("OSType", Int32(code))
			case .null:
				result = .nullValue
			case .objectSpecifier:
				let itemnum = self.numberOfItems
				var dict: Dictionary<String, CNNativeValue> = [:]
				for i in 1...itemnum {
					let key = self.keywordForDescriptor(at: i)
					if let word = CNAppleEventKeyword.encode(keyword: key) {
						if let desc = self.forKeyword(key) {
							let child = desc.toNativeValue()
							dict[word.toString()] = child
						} else {
							NSLog("No value: \(key)")
						}
					} else {
						NSLog("Failed to encode: \(key)")
					}
				}
				result = .dictionaryValue(dict)
			case .type:
				let code = self.typeCodeValue
				result = .enumValue("OSType", Int32(code))
			case .unicodeText:
				if let val = self.stringValue {
					result = .stringValue(val)
				} else {
					NSLog("Failed to convert value: \(desctype.toString())")
				}
			default:
				NSLog("Unsupported description type: \(desctype.toString())")
			}
		} else {
			NSLog("Unknown description type: \(String(self.descriptorType, radix: 16))")
		}
		return result
	}
}

