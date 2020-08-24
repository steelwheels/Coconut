/**
 * @file	CNAppleEventManager.swift
 * @brief	Define CNAppleEventManager class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

#if os(OSX)

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
	private var mConstantTable:	Dictionary<OSType, NSObject>	// type, value
	public  var console:		CNConsole


	public init() {
		console = CNDefaultConsole()
		mAppleEventManager = NSAppleEventManager.shared()
		mConstantTable = [:]
	}

	public func setup(){
		setupHandlers()
	}

	private func setupHandlers() {
		/* get event */
		if true {
			let eclass	= CNEventClass.coreEvent.code()
			let eid		= CNEventID.getData.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(getEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* make event */
		if true {
			let eclass	= CNEventClass.coreEvent.code()
			let eid		= CNEventID.make.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(makeEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* openDocument event */
		if true {
			let eclass	= CNEventClass.coreEvent.code()
			let eid		= CNEventID.openDocument.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(openDocumentEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* printDocument event */
		if true {
			let eclass	= CNEventClass.coreEvent.code()
			let eid		= CNEventID.printDocument.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(printDocumentEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* quitApplication event */
		if true {
			let eclass	= CNEventClass.coreEvent.code()
			let eid		= CNEventID.quitApplication.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(quitApplicationEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* set event */
		if true {
			let eclass	= CNEventClass.coreEvent.code()
			let eid		= CNEventID.setData.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(setEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}
	}

	public func dump() {
		console.print(string: "Message from AppleEventManager\n")
	}

	@objc private func getEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		console.print(string: "gE(0): desc=\(desc.description)\n")
		var retval: NSAppleEventDescriptor? = nil
		var retmsg: String? = nil
		if let srcparam = desc.directParameter {
			if let srcobj = sourceObject(source: srcparam) {
				if let srcdesc = objectToDescription(object: srcobj) {
					retval = srcdesc
				}
			}
		}
		if retval == nil {
			retmsg = "Failed to get"
		}
		rep.setResult(resultValue: retval, error: retmsg)
		console.print(string: "gE(1): rep=\(rep.description)\n")
	}

	@objc private func setEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		console.print(string: "sE(0): desc=\(desc.description)\n")
		var haserr: Bool    = true
		var retmsg: String? = nil
		if let dstparam = desc.directParameter, let srcparam = desc.dataParameter {
			if let dsttype = destinationType(destination: dstparam), let srcobj = sourceObject(source: srcparam) {
				if setObject(destination: dsttype, source: srcobj){
					haserr = false
				}
			}
		}
		if haserr {
			retmsg = "Failed to set"
		}
		rep.setResult(resultValue: nil, error: retmsg)
		console.print(string: "sE(1): rep=\(rep.description)\n")
	}

	@objc private func makeEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		console.print(string: "mE: \(desc.description) \(rep.description)\n")
		var haserr: Bool	= true
		var retmsg: String?	= nil
		if let oclass = desc.objectClass {
			switch oclass {
			case CNEventObject.window.code():
				/* make document */
				//console.print(string: "Open new window")
				let docctrl = NSDocumentController.shared
				docctrl.newDocument(self)
				haserr = false
			default:
				break
			}
		}
		if !haserr {
			retmsg = "Failed to decode make event"
		}
		rep.setResult(resultValue: nil, error: retmsg)
	}

	@objc private func openDocumentEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		console.print(string: "oDE: \(desc.description) \(rep.description)\n")
	}

	@objc private func printDocumentEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		console.print(string: "pDE: \(desc.description) \(rep.description)\n")
	}

	@objc private func quitApplicationEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		console.print(string: "qAE: \(desc.description) \(rep.description)\n")
	}

	private func sourceObject(source src: NSAppleEventDescriptor) -> NSObject? {
		if let type = objectType(source: src) {
			/* Builtin Color */
			if let col = CNColor.decode(fromOSType: type) {
				return col
			}
			/* System property */
			switch type {
			case CNEventProperty.textColor.code():
				let termpref = CNPreference.shared.terminalPreference
				return termpref.foregroundTextColor
			case CNEventProperty.backgroundColor.code():
				let termpref = CNPreference.shared.terminalPreference
				return termpref.backgroundTextColor
			default:
				break // Do nothing
			}
		}
		return nil
	}

	private func destinationType(destination dst: NSAppleEventDescriptor) -> OSType? {
		return objectType(source: dst)
	}

	private func objectType(source src: NSAppleEventDescriptor) -> OSType? {
		if let form = src.format {
			switch form {
			case .property:
				if let seld = src.selectDataName {
					return seld
				}
			}
		}
		return nil
	}

	private func objectToDescription(object obj: NSObject) -> NSAppleEventDescriptor? {
		if let color = obj as? CNColor {
			return NSAppleEventDescriptor.fromColor(color: color)
		}
		return nil
	}

	private func setObject(destination dst: OSType, source src: NSObject) -> Bool {
		var result = false
		switch dst {
		case CNEventProperty.textColor.code():
			if let col = src as? CNColor {
				let termpref = CNPreference.shared.terminalPreference
				termpref.foregroundTextColor = col
				result = true
			}
		case CNEventProperty.backgroundColor.code():
			if let col = src as? CNColor {
				let termpref = CNPreference.shared.terminalPreference
				termpref.backgroundTextColor = col
				result = true
			}
		default:
			break	// Do nothing
		}
		return result
	}
}

#endif // os(OSX)

