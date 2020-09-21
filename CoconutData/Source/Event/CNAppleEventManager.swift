/**
 * @file	CNAppleEventManager.swift
 * @brief	Define CNAppleEventManager class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)

import AppKit
import Foundation

public class CNAppleEventManager
{
	private static var mSharedManager: CNAppleEventManager? = nil
	public static func shared() -> CNAppleEventManager {
		if let mgr = mSharedManager {
			return mgr
		} else {
			let mgr = CNAppleEventManager()
			mSharedManager = mgr
			return mgr
		}
	}

	private var mAppleEventManager: NSAppleEventManager
	private var mColorTable:	Dictionary<String, CNColor>

	public init() {
		mAppleEventManager = NSAppleEventManager.shared()
		mColorTable	   = [:]
	}

	public func setup(){
		setupHandlers()
		setupProperties()
	}

	private func setupHandlers() {
		/* get event */
		if true {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.getData.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(getEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* make event */
		if true {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.make.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(makeEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* openDocument event */
		if true {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.openDocument.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(openDocumentEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* closeDocument event */
		if true {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.closeDocument.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(closeDocumentEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* save event */
		if true {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.saveDocument.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(saveDocumentEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* printDocument event */
		if true {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.printDocument.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(printDocumentEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* quitApplication event */
		if true {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.quitApplication.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(quitApplicationEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* set event */
		if true {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.setData.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(setEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}
	}

	private func setupProperties() {
		/* Register color names */
		mColorTable["black"] 		= CNColor.black
		mColorTable["red"]		= CNColor.red
		mColorTable["green"]		= CNColor.green
		mColorTable["yellow"]		= CNColor.yellow
		mColorTable["blue"]		= CNColor.blue
		mColorTable["magenta"]		= CNColor.magenta
		mColorTable["cyan"]		= CNColor.cyan
		mColorTable["white"]		= CNColor.white
	}

	public func hasProperty(named name: String) -> Bool {
		if property(forKey: name) != nil {
			return true
		} else {
			CNLog(logLevel: .detail, message: "Inquiry about property: \(name)")
			return false
		}
	}

	public func property(forKey key: String) -> Any? {
		/* Search default color */
		if let col = mColorTable[key] {
			return col
		}
		switch key {
		case "foregroundColor":
			let termpref = CNPreference.shared.terminalPreference
			return termpref.foregroundTextColor
		case "backgroundColor":
			let termpref = CNPreference.shared.terminalPreference
			return termpref.backgroundTextColor
		case "terminalHeight":
			let termpref = CNPreference.shared.terminalPreference
			return NSNumber(integerLiteral: termpref.rowNumber)
		case "terminalWidth":
			let termpref = CNPreference.shared.terminalPreference
			return NSNumber(integerLiteral: termpref.columnNumber)
		default:
			CNLog(logLevel: .error, message: "[Error] Can not get property named: \(key)")
		}
		return nil
	}

	open func setProperty(_ value: Any?, forKey key: String) {
		var hasset: Bool = false
		switch key {
		case "foregroundColor":
			if let col = value as? CNColor {
				let termpref = CNPreference.shared.terminalPreference
				termpref.foregroundTextColor = col
				hasset = true
			}
		case "backgroundColor":
			if let col = value as? CNColor {
				let termpref = CNPreference.shared.terminalPreference
				termpref.backgroundTextColor = col
				hasset = true
			}
		case "terminalHeight":
			if let num = value as? NSNumber {
				let termpref = CNPreference.shared.terminalPreference
				termpref.rowNumber = num.intValue
				hasset = true
			}
		case "terminalWidth":
			if let num = value as? NSNumber {
				let termpref = CNPreference.shared.terminalPreference
				termpref.columnNumber = num.intValue
				hasset = true
			}
		default:
			break
		}
		if !hasset {
			CNLog(logLevel: .error, message: "[Error] Can not set the property named: \(key)")
		}
	}

	public func dump() {
		CNLog(logLevel: .debug, message: "Message from AppleEventManager")
	}

	@objc private func getEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		CNLog(logLevel: .debug, message: "gE(0): desc=\(desc.description)")

		var retval: NSAppleEventDescriptor? = nil
		var retmsg: String? = nil

		if let srcdesc = desc.paramDescriptor(forKeyword: CNEventCode.directObject.code()) {
			let parser = CNEventParser()
			switch parser.parseParameter(descriptor: srcdesc) {
			case .ok(let param):
				if let desc = param.toDescriptor() {
					retval = desc
				} else {
					retmsg = "Failed to convert to descriptor"
				}
			case .error(let err):
				retmsg = err.description
			}
		}

		rep.setResult(resultValue: retval, error: retmsg)
		CNLog(logLevel: .debug, message: "gE(1): rep=\(rep.description)")
	}

	@objc private func setEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		CNLog(logLevel: .debug, message: "sE(0): desc=\(desc.description)")

		var retmsg: String? = nil
		if let srcdesc = desc.paramDescriptor(forKeyword: CNEventCode.data.code()),
		   let dstdesc = desc.paramDescriptor(forKeyword: CNEventCode.directObject.code()) {
			let parser = CNEventParser()
			switch parser.parseParameter(descriptor: srcdesc) {
			case .ok(let srcparam):
				switch parser.parseParameter(descriptor: dstdesc) {
				case .ok(let dstparam):
					retmsg = set(destination: dstparam, source: srcparam)
				case .error(let err):
					retmsg = err.toString()
				}
			case .error(let err):
				retmsg = err.toString()
			}
		}

		rep.setResult(resultValue: nil, error: retmsg)
		CNLog(logLevel: .debug, message: "sE(1): rep=\(rep.description)")
	}

	private func set(destination dstparam: CNEventParameter, source srcparam: CNEventParameter) -> String? {
		switch dstparam {
		case .preference(let dstptr):
			let termpref = CNPreference.shared.terminalPreference
			/* Get source value */
			let srcvalue: CNEventImmediate
			switch srcparam {
			case .color(let col):
				srcvalue = .color(col)
			case .value(let val):
				srcvalue = .value(val)
			case .preference(let pref):
				switch pref {
				case .foregroundColor:
					srcvalue = .color(termpref.foregroundTextColor)
				case .backgroundColor:
					srcvalue = .color(termpref.backgroundTextColor)
				case .terminalHeight:
					srcvalue = .value(CNValue(intValue: termpref.rowNumber))
				case .terminalWidth:
					srcvalue = .value(CNValue(intValue: termpref.columnNumber))
				}
			case .window(_):
				return "the window object can not be source parameter"
			}
			/* Assign to destination */
			switch dstptr {
			case .foregroundColor:
				if let col = srcvalue.toColor() {
					termpref.foregroundTextColor = col
				} else {
					return "Color object is required to set foreground color"
				}
			case .backgroundColor:
				if let col = srcvalue.toColor() {
					termpref.backgroundTextColor = col
				} else {
					return "Color object is required to set foreground color"
				}
			case .terminalHeight:
				if let val = srcvalue.toInt() {
					termpref.rowNumber = val
				} else {
					return "Integer is required to set terminal height"
				}
			case .terminalWidth:
				if let val = srcvalue.toInt() {
					termpref.columnNumber = val
				} else {
					return "Integer is required to set termninal width"
				}
			}
		case .window(_), .color(_), .value(_):
			return "Not writable destination"
		}
		return nil
	}

	@objc private func makeEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		CNLog(logLevel: .debug, message: "mE(0): desc=\(desc.description)")

		var retmsg: String?	= nil
		if let targdesc = desc.forKeyword(CNEventCode.objectClass.code()) {
			let parser = CNEventParser()
			if let target = parser.parseMakeTarget(descriptor: targdesc) {
				switch target {
				case .window:
					/* Make new window */
					let docctrl = NSDocumentController.shared
					docctrl.newDocument(self)
				}
			} else {
				retmsg = "Unknown target: \(targdesc.description)"
			}
		} else {
			retmsg = "No target to make"
		}

		rep.setResult(resultValue: nil, error: retmsg)
		CNLog(logLevel: .debug, message: "mE(1): rep=\(rep.description)")
	}

	@objc private func openDocumentEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		CNLog(logLevel: .debug, message: "oDE: \(desc.description) \(rep.description)")
	}

	@objc private func closeDocumentEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		CNLog(logLevel: .debug, message: "cDE(0): desc=\(desc.description)")

		var retmsg: String?	= nil
		if let srcdesc = desc.paramDescriptor(forKeyword: CNEventCode.directObject.code()) {
			let parser = CNEventParser()
			switch parser.parseParameter(descriptor: srcdesc) {
			case .ok(let param):
				switch param {
				case .color(_), .preference(_), .value(_):
					retmsg = "Invalid target to close: \(param.description)"
				case .window(let index):
					retmsg = closeWindow(index: index)
				}
			case .error(let err):
				retmsg = err.toString()
			}
		}

		rep.setResult(resultValue: nil, error: retmsg)
		CNLog(logLevel: .debug, message: "cDE(1): rep=\(rep.description)")
	}

	@objc private func saveDocumentEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		CNLog(logLevel: .debug, message: "sDE(0): desc=\(desc.description)")
		rep.setResult(resultValue: nil, error: "Save command is not supported yet")
		CNLog(logLevel: .debug, message: "sDE(1): rep=\(rep.description)")
	}

	private func closeWindow(index idx: CNEventIndex) -> String? {
		let docs = NSDocumentController.shared.documents
		var doc: NSDocument?
		switch idx {
		case .none:
			if docs.count > 0 {
				doc = docs[0]
			} else {
				return "No documents to close"
			}
		case .id(let did):
			if 1<=did && did<=docs.count {
				doc = docs[did-1]
			} else {
				return "No document idexed \(did)"
			}
		case .name(let name):
			for tmp in docs {
				if tmp.displayName == name {
					doc = tmp
					break
				}
			}
			if doc == nil {
				return "No document named \(name)"
			}
		}
		if let doc = doc {
			doc.close()
		}
		return nil
	}

	@objc private func printDocumentEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		CNLog(logLevel: .debug, message: "pDE: \(desc.description) \(rep.description)")
	}

	@objc private func quitApplicationEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		CNLog(logLevel: .debug, message: "qAE: \(desc.description) \(rep.description)")
	}

}

#endif // os(OSX)

