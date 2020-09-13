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

	public enum ExecResult {
		case	ok(NSAppleEventDescriptor)
		case	error(NSError)
	}

	public enum StringResult {
		case	ok(String)
		case	error(NSError)
	}

	public init(eventDescriptor desc: NSAppleEventDescriptor?) {
		mEventDescriptor = desc
	}

	public func activate() -> ExecResult {
		let result: ExecResult
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.misc.code()
			let eid		= CNEventCode.activate.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			result = CNRemoteApplication.execute(descriptor: newdesc)
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	public func version() -> ExecResult {
		let result: ExecResult
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.application.code()
			let eid		= CNEventCode.getData.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			let versdesc	= NSAppleEventDescriptor(enumCode: CNEventCode.version.code())
			CNRemoteApplication.setRefereCommand(target: newdesc, source: versdesc)
			result = CNRemoteApplication.execute(descriptor: newdesc)
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	public func makeNewDocument() -> ExecResult {
		let result: ExecResult
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.make.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			CNRemoteApplication.setDocumentProperty(target: newdesc, name: nil)
			result = CNRemoteApplication.execute(descriptor: newdesc)
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	public func makeNewMail(subject substr: String) -> ExecResult {
		let result: ExecResult
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.make.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			CNRemoteApplication.setMailProperty(target: newdesc, subject: substr)
			switch CNRemoteApplication.execute(descriptor: newdesc) {
			case .ok(let desc):	result = .ok(desc)
			case .error(let err):	result = .error(err)
			}
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	public func open(fileURL url: URL) -> ExecResult {
		let result: ExecResult
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.appleEvent.code()
			let eid		= CNEventCode.openDocument.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* File URL */
			newdesc.setDescriptor(NSAppleEventDescriptor(fileURL: url), forKeyword: CNEventCode.directObject.code())
			/* Execute */
			result = CNRemoteApplication.execute(descriptor: newdesc)
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	public func close(fileURL url: URL?) -> NSError? {
		let result: NSError?
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.closeDocument.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* 'kfil':File path */
			if let u = url {
				newdesc.setDescriptor(NSAppleEventDescriptor(fileURL: u), forKeyword: CNEventCode.file.code())
			}
			/* Execute */
			switch CNRemoteApplication.execute(descriptor: newdesc) {
			case .ok(_):		result = nil
			case .error(let err):	result = err
			}
		} else {
			result = NSError.parseError(message: "No event descriptor")
		}
		return result
	}

	public func setNameOfFrontWindow(name nm: String) -> NSError? {
		let result: NSError?
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.setData.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* Destination */
			let dst = CNRemoteApplication.nameProperty(of: CNRemoteApplication.frontObject(number: 1, of: .document))
			/* Source string */
			let src  = NSAppleEventDescriptor(string: nm)
			/* Setup command */
			CNRemoteApplication.setAssignmentCommand(target: newdesc, destination: dst, source: src)
			/* Execute */
			switch CNRemoteApplication.execute(descriptor: newdesc) {
			case .ok(_):		result = nil
			case .error(let err):	result = err
			}
		} else {
			result = NSError.parseError(message: "No event descriptor")
		}
		return result
	}

	public func nameOfFrontWindow() -> StringResult {
		let result: StringResult
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.getData.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* Source */
			let src = CNRemoteApplication.nameProperty(of: CNRemoteApplication.frontObject(number: 1, of: .document))
			CNRemoteApplication.setRefereCommand(target: newdesc, source: src)
			/* Execute */
			switch CNRemoteApplication.execute(descriptor: newdesc) {
			case .ok(let desc):
				result = ackToString(ackDescription: desc)
			case .error(let err):
				result = .error(err)
			}
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	public func setContentOfFrontWindow(context ctxt: String) -> NSError? {
		let result: NSError?
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.setData.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)

			/* Destination: context of front document */
			let dst = CNRemoteApplication.selectAllContext(of: CNRemoteApplication.frontObject(number: 1, of: .document))
			/* Source string */
			let src  = NSAppleEventDescriptor(string: ctxt)
			/* Setup command */
			CNRemoteApplication.setAssignmentCommand(target: newdesc, destination: dst, source: src)
			/* Execute */
			switch CNRemoteApplication.execute(descriptor: newdesc) {
			case .ok(_):		result = nil
			case .error(let err):	result = err
			}
		} else {
			result = NSError.parseError(message: "No event descriptor")
		}
		return result
	}

	public func contentOfFrontWindow() -> StringResult {
		let result: StringResult
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.getData.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* Source */
			let src = CNRemoteApplication.selectAllContext(of: CNRemoteApplication.frontObject(number: 1, of: .document))
			CNRemoteApplication.setRefereCommand(target: newdesc, source: src)
			/* Execute */
			switch CNRemoteApplication.execute(descriptor: newdesc) {
			case .ok(let desc):
				result = ackToString(ackDescription: desc)
			case .error(let err):
				result = .error(err)
			}
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	public func save(fileURL url: URL) -> NSError? {
		let result: NSError?
		if let appdesc = mEventDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.saveDocument.code()
			let newdesc	= newDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* File URL */
			setFileLocation(target: newdesc, fileURL: url)
			/* Source object */
			let src = CNRemoteApplication.frontObject(number: 1, of: .document)
			newdesc.setParam(src, forKeyword: CNEventCode.directObject.code())
			/* signature:65536 */
			let sigdesc = NSAppleEventDescriptor.init(int32: 65536)
			newdesc.setAttribute(sigdesc, forKeyword: CNEventCode.signatureClass.code())
			/* Execute */
			switch CNRemoteApplication.execute(descriptor: newdesc) {
			case .ok(_):		result = nil
			case .error(let err):	result = err
			}
		} else {
			result = NSError.parseError(message: "No event descriptor")
		}
		return result
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

	private static func setMailProperty(target targ: NSAppleEventDescriptor, subject substr: String) {
		// objectType:outgoingMessage
		let typedesc = NSAppleEventDescriptor(enumCode: CNEventCode.outgoingMessage.code())
		targ.setParam(typedesc, forKeyword: CNEventCode.objectClass.code())

		// &subject:null()
		targ.setAttribute(NSAppleEventDescriptor(string: substr), forKeyword: CNEventCode.subject.code())

		// &signature:65536
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

	private static func setRefereCommand(target targ: NSAppleEventDescriptor, source src: NSAppleEventDescriptor) {
		targ.setParam(src, forKeyword: CNEventCode.directObject.code())

		// signature:65536
		let sigdesc = NSAppleEventDescriptor.init(int32: 65536)
		targ.setAttribute(sigdesc, forKeyword: CNEventCode.signatureClass.code())
	}

	public static func execute(descriptor desc: NSAppleEventDescriptor) -> ExecResult {
		do {
			//CNLog(logLevel: .debug, message: "Send event: \(desc.description)")
			NSLog("Send event: \(desc.description)")
			let result = try desc.sendEvent(options: .defaultOptions, timeout: 10.0)
			return .ok(result)
		} catch let err as NSError {
			return .error(err)
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

	public static func nameProperty(of srcdesc: NSAppleEventDescriptor) -> NSAppleEventDescriptor {
		guard let result = NSAppleEventDescriptor.object() else {
			fatalError("Failed to allocate result")
		}
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.property.code()), forKeyword: CNEventCode.format.code())
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.property.code()), forKeyword: CNEventCode.classType.code())
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.name.code()), forKeyword: CNEventCode.selectData.code())
		result.setDescriptor(srcdesc, forKeyword: CNEventCode.from.code())								// 'from':object
		return result
	}

	public static func frontObject(number num: Int32, of object: Object) -> NSAppleEventDescriptor {
		let objcode: CNEventCode
		switch object {
		case .context:	objcode = CNEventCode.context
		case .document:	objcode = CNEventCode.document
		}
		guard let result = NSAppleEventDescriptor.object() else {
			fatalError("Failed to allocate result")
		}
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.index.code()), forKeyword: CNEventCode.format.code())		// 'form':'indx'
		result.setDescriptor(NSAppleEventDescriptor(enumCode: objcode.code()), forKeyword: CNEventCode.classType.code())		// 'want':object
		result.setDescriptor(NSAppleEventDescriptor(int32: num), forKeyword: CNEventCode.selectData.code())				// 'seld':num
		result.setDescriptor(NSAppleEventDescriptor.null(), forKeyword: CNEventCode.from.code())					// 'from':null
		return result
	}

	private func setFileLocation(target targ: NSAppleEventDescriptor, fileURL url: URL) {
		/* 'fltp':'ctxt' */
		targ.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.context.code()), forKeyword: CNEventCode.fileType.code())
		/* 'kfil':File path */
		targ.setDescriptor(NSAppleEventDescriptor(fileURL: url), forKeyword: CNEventCode.file.code())
	}

	private func ackToString(ackDescription ack: NSAppleEventDescriptor) -> StringResult {
		//NSLog("ack-desc=\(ack.description)")
		if let dirparam = ack.paramDescriptor(forKeyword: CNEventCode.directObject.code()) {
			if let str = dirparam.stringValue {
				return .ok(str)
			}
		}
		return .error(NSError.parseError(message: "The ack does not have "))
	}
}

#endif

