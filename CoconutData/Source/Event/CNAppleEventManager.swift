/**
 * @file	CNAppleEventManager.swift
 * @brief	Define CNAppleEventManager class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

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

	public  var console:		CNConsole
	private var mAppleEventManager: NSAppleEventManager

	public init() {
		console = CNDefaultConsole()
		mAppleEventManager = NSAppleEventManager.shared()
	}

	public func setup(){
		/* Setup make event */
		if true {
			let eclass	= CNEventClass.coreEvent.code()
			let eid		= CNEventID.make.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(makeEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* Setup openDocument event */
		if true {
			let eclass	= CNEventClass.coreEvent.code()
			let eid		= CNEventID.openDocument.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(openDocumentEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* Setup printDocument event */
		if true {
			let eclass	= CNEventClass.coreEvent.code()
			let eid		= CNEventID.printDocument.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(printDocumentEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}

		/* Setup quitApplication event */
		if true {
			let eclass	= CNEventClass.coreEvent.code()
			let eid		= CNEventID.quitApplication.code()
			mAppleEventManager.setEventHandler(self, andSelector: #selector(quitApplicationEvent(descriptor:reply:)), forEventClass: eclass, andEventID: eid)
		}
	}

	public func dump() {
		console.print(string: "Message from AppleEventManager\n")
	}

	@objc private func makeEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		console.print(string: "mE: \(desc.description) \(rep.description)")
	}

	@objc private func openDocumentEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		console.print(string: "oDE: \(desc.description) \(rep.description)")
	}

	@objc private func printDocumentEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		console.print(string: "pDE: \(desc.description) \(rep.description)")
	}

	@objc private func quitApplicationEvent(descriptor desc: NSAppleEventDescriptor, reply rep: NSAppleEventDescriptor) {
		console.print(string: "qAE: \(desc.description) \(rep.description)")
	}
}
