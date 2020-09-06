/**
 * @file	CNRemoteApplication.swift
 * @brief	Define CNRemoteApplication class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

#if os(OSX)

open class CNRemoteApplication: CNAppleEventGenerator
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

	public init(application runapp: NSRunningApplication){
		mRunningApplication = runapp
		let desc: NSAppleEventDescriptor?
		if let bident = runapp.bundleIdentifier {
			//NSLog("init: bundle=\(bident)")
			desc = NSAppleEventDescriptor(bundleIdentifier: bident)
		} else if let url = runapp.bundleURL {
			//NSLog("init: URL=\(url.absoluteString)")
			desc = NSAppleEventDescriptor(applicationURL: url)
		} else {
			//NSLog("init: nil")
			desc = nil
		}
		super.init(eventDescriptor: desc)
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
}

open class CNAppleEventGenerator
{
	private var mEventDescriptor:		NSAppleEventDescriptor?

	public init(eventDescriptor desc: NSAppleEventDescriptor?) {
		mEventDescriptor = desc
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

	public func setContext(context ctxt: String) -> NSError? {
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.setData.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)

			/* Destination: context of front document */
			let dst = CNRemoteApplication.selectAllContext(of: CNRemoteApplication.index(number: 1, of: .document))
			/* Source string */
			let src  = NSAppleEventDescriptor(string: ctxt)
			/* Setup command */
			CNRemoteApplication.setAssignmentCommand(target: newdesc, destination: dst, source: src)
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

	private static func setAssignmentCommand(target targ: NSAppleEventDescriptor, destination dst: NSAppleEventDescriptor, source src: NSAppleEventDescriptor) {
		targ.setParam(src, forKeyword: CNEventCode.data.code())
		targ.setParam(dst, forKeyword: CNEventCode.directObject.code())

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

	public enum Object {
		case context
		case document
	}

	public static func selectAllContext(of srcdesc: NSAppleEventDescriptor) -> NSAppleEventDescriptor {
		let alldesc = NSAppleEventDescriptor(enumCode: CNEventCode.all.code())
		guard let absdesc = NSAppleEventDescriptor(descriptorType: CNEventCode.absolute.code(), data: alldesc.data) else {
			fatalError("Failed to allocate descriptor")
		}
		guard let result = NSAppleEventDescriptor.object() else {
			fatalError("Failed to allocate result")
		}
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.index.code()), forKeyword: CNEventCode.format.code())		// 'form':'indx'
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.context.code()), forKeyword: CNEventCode.classType.code())	// 'want':'ctxt'
		result.setDescriptor(absdesc, forKeyword: CNEventCode.selectData.code())							// 'seld':{'abso': 'all'}
		result.setDescriptor(srcdesc, forKeyword: CNEventCode.from.code())								// 'from':object
		return result
	}

	public static func index(number num: Int32, of object: Object) -> NSAppleEventDescriptor {
		let objcode: CNEventCode
		switch object {
		case .context:	objcode = CNEventCode.context
		case .document:	objcode = CNEventCode.document
		}
		guard let result = NSAppleEventDescriptor.object() else {
			fatalError("Failed to allocate result")
		}
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.index.code()), forKeyword: CNEventCode.format.code())	// 'form':'indx'
		result.setDescriptor(NSAppleEventDescriptor(enumCode: objcode.code()), forKeyword: CNEventCode.classType.code())		// 'want':object
		result.setDescriptor(NSAppleEventDescriptor(int32: num), forKeyword: CNEventCode.selectData.code())				// 'seld':num
		result.setDescriptor(NSAppleEventDescriptor.null(), forKeyword: CNEventCode.from.code())						// 'from':null
		return result
	}
}


#endif

