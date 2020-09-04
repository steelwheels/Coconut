/**
 * @file	CNRemoteApplication.swift
 * @brief	Define CNRemoteApplication class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

#if os(OSX)

open class CNRemoteApplication
{
	public static func launch(application appurl: URL?, document docurl: URL?) -> NSRunningApplication? {
		do {
			let app: NSRunningApplication
			if let aurl = appurl {
				if let durl = docurl {
					app = try NSWorkspace.shared.open([durl], withApplicationAt: aurl, options: .async, configuration: [:])
				} else {
					app = try NSWorkspace.shared.open(aurl, options: .async, configuration: [:])
				}
			} else {
				if let durl = docurl {
					app = try NSWorkspace.shared.open(durl, options: .async, configuration: [:])
				} else {
					return nil
				}
			}
			return app
		} catch {
			return nil
		}
	}

	public static func launch(bundleIdentifier bident: String) -> NSRunningApplication? {
		/* Search current process */
		let curprocs = NSRunningApplication.runningApplications(withBundleIdentifier: bident)
		if curprocs.count > 0 {
			return curprocs[0]
		}
		/* Launch the application */
		if NSWorkspace.shared.launchApplication(withBundleIdentifier: bident, options: .withoutActivation, additionalEventParamDescriptor: nil, launchIdentifier: nil) {
			let newprocs = NSRunningApplication.runningApplications(withBundleIdentifier: bident)
			if newprocs.count > 0 {
				return newprocs[0]
			}
		}
		return nil
	}

	private var mRunningApplication:	NSRunningApplication
	private var mEventDescriptor:		NSAppleEventDescriptor?

	public init(application runapp: NSRunningApplication){
		mRunningApplication = runapp
		if let bident = runapp.bundleIdentifier {
			//NSLog("init: bundle=\(bident)")
			mEventDescriptor = NSAppleEventDescriptor(bundleIdentifier: bident)
		} else if let url = runapp.bundleURL {
			//NSLog("init: URL=\(url.absoluteString)")
			mEventDescriptor = NSAppleEventDescriptor(applicationURL: url)
		} else {
			//NSLog("init: nil")
			mEventDescriptor = nil
		}
	}

	public var name: String? {
		get { return mRunningApplication.localizedName }
	}

	public var bundleIdentifier: String? {
		get { return mRunningApplication.bundleIdentifier }
	}

	public var processIdentifier: pid_t {
		return mRunningApplication.processIdentifier
	}

	public func isEqual(application app: NSRunningApplication) -> Bool {
		return mRunningApplication.isEqual(app)
	}

	public var isFinishLaunching: Bool {
		get { return mRunningApplication.isFinishedLaunching }
	}

	public func terminate() -> Bool {
		return mRunningApplication.terminate()
	}

	public func forceTerminate() -> Bool {
		return mRunningApplication.forceTerminate()
	}

	public func activate() -> NSError? {
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.misc.code()
			let eid		= CNEventCode.activate.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			return CNRemoteApplication.execute(descriptor: newdesc)
		} else {
			return NSError.parseError(message: "No event descriptor")
		}
	}

	public func makeNewDocument() -> NSError? {
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.make.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			CNRemoteApplication.setDocumentProperty(target: newdesc, name: nil)
			return CNRemoteApplication.execute(descriptor: newdesc)
		} else {
			return NSError.parseError(message: "No event descriptor")
		}
	}

	private func newDescriptor(applicationDescriptor appdesc: NSAppleEventDescriptor, eventClass eclass: AEEventClass, eventID eid: AEEventID) -> NSAppleEventDescriptor {
		let retid	: AEReturnID		= -1	// generate session unique id
		let transid	: AETransactionID	= 0	// No transaction is in use
		return NSAppleEventDescriptor(eventClass: eclass, eventID: eid, targetDescriptor: appdesc, returnID: retid, transactionID: transid)
	}

	private static func setDocumentProperty(target targ: NSAppleEventDescriptor, name nm: String?) {
		// objectType:document
		let typedesc = NSAppleEventDescriptor(enumCode: CNEventCode.document.code())
		targ.setParam(typedesc, forKeyword: CNEventCode.objectClass.code())

		// subject:name
		let namedesc: NSAppleEventDescriptor
		if let n = nm {
			namedesc = NSAppleEventDescriptor(string: n)
		} else {
			namedesc = NSAppleEventDescriptor()
		}
		targ.setAttribute(namedesc, forKeyword: CNEventCode.subject.code())

		// signature:65536
		let sigdesc = NSAppleEventDescriptor.init(int32: 65536)
		targ.setAttribute(sigdesc, forKeyword: CNEventCode.signatureClass.code())
	}

	public static func execute(descriptor desc: NSAppleEventDescriptor) -> NSError? {
		do {
			//CNLog(logLevel: .debug, message: "Send event: \(desc.description)")
			NSLog("Send event: \(desc.description)")
			try desc.sendEvent(options: .defaultOptions, timeout: 10.0)
			return nil
		} catch let err as NSError {
			return err
		}
	}
}

#endif

