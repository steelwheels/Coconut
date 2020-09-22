/**
 * @file	CNRemoteApplication.swift
 * @brief	Define CNRemoteApplication class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)

import AppKit
import Foundation

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

	public init(application runapp: NSRunningApplication){
		mRunningApplication = runapp
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

open class CNEventReceiverApplication: CNRemoteApplication
{
	public enum ExecResult {
		case	ok(NSAppleEventDescriptor)
		case	error(NSError)
	}

	public enum StringResult {
		case	ok(String)
		case	error(NSError)
	}

	private var mApplicationDescriptor: NSAppleEventDescriptor?

	public var applicationDescriptor: NSAppleEventDescriptor? {
		get { return mApplicationDescriptor }
	}

	public override init(application runapp: NSRunningApplication){
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
		mApplicationDescriptor = desc
		super.init(application: runapp)
	}

	public func activate() -> ExecResult {
		let result: ExecResult
		if let appdesc = applicationDescriptor {
			let eclass	= CNEventCode.misc.code()
			let eid		= CNEventCode.activate.code()
			let newdesc	= baseDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			result = execute(descriptor: newdesc)
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	public func baseDescriptor(applicationDescriptor appdesc: NSAppleEventDescriptor, eventClass eclass: AEEventClass, eventID eid: AEEventID) -> NSAppleEventDescriptor {
		let retid	: AEReturnID		= -1	// generate session unique id
		let transid	: AETransactionID	= 0	// No transaction is in use
		return NSAppleEventDescriptor(eventClass: eclass, eventID: eid, targetDescriptor: appdesc, returnID: retid, transactionID: transid)
	}

	public func execute(descriptor desc: NSAppleEventDescriptor) -> ExecResult {
		do {
			//CNLog(logLevel: .debug, message: "Send event: \(desc.description)")
			NSLog("Send event: \(desc.description)")
			let result = try desc.sendEvent(options: .defaultOptions, timeout: 10.0)
			if let err = errorInDescription(descriptor: result) {
				return .error(err)
			} else {
				return .ok(result)
			}
		} catch let err as NSError {
			return .error(err)
		}
	}

	public enum Object {
		case context
		case document
		case window
	}

	public func selectFrontObject(number num: Int32, of object: Object) -> NSAppleEventDescriptor {
		let objcode: CNEventCode
		switch object {
		case .context:	objcode = CNEventCode.context
		case .document:	objcode = CNEventCode.document
		case .window:	objcode = CNEventCode.window
		}
		guard let result = NSAppleEventDescriptor.object() else {
			fatalError("Failed to allocate result")
		}
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.index.code()), forEventCode: .format)		// 'form':'indx'
		result.setDescriptor(NSAppleEventDescriptor(enumCode: objcode.code()), forEventCode: .classType)		// 'want':object
		result.setDescriptor(NSAppleEventDescriptor(int32: num), forEventCode: .selectData)				// 'seld':num
		result.setDescriptor(NSAppleEventDescriptor.null(), forEventCode: .from) 	// 'from':null
		return result
	}

	public func selectAllContext(of srcdesc: NSAppleEventDescriptor) -> NSAppleEventDescriptor {
		let alldesc = NSAppleEventDescriptor(enumCode: CNEventCode.all.code())
		guard let absdesc = NSAppleEventDescriptor(descriptorType: CNEventCode.absolute.code(), data: alldesc.data) else {
			fatalError("Failed to allocate descriptor")
		}
		guard let result = NSAppleEventDescriptor.object() else {
			fatalError("Failed to allocate result")
		}
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.index.code()), forEventCode: .format)		// 'form':'indx'
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.context.code()), forEventCode: .classType)	// 'want':'ctxt'
		result.setDescriptor(absdesc, forEventCode: .selectData)							// 'seld':{'abso': 'all'}
		result.setDescriptor(srcdesc, forEventCode: .from)								// 'from':object
		return result
	}

	public func selectNameProperty(of srcdesc: NSAppleEventDescriptor) -> NSAppleEventDescriptor {
		guard let result = NSAppleEventDescriptor.object() else {
			fatalError("Failed to allocate result")
		}
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.property.code()), forEventCode: .format)
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.property.code()), forEventCode: .classType)
		result.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.name.code()), forEventCode: .selectData)
		result.setDescriptor(srcdesc, forEventCode: .from)								// 'from':object
		return result
	}

	public func setAssignment(target targ: NSAppleEventDescriptor, destination dst: NSAppleEventDescriptor, source src: NSAppleEventDescriptor) {
		targ.setParam(src, forEventCode: .data)
		targ.setParam(dst, forEventCode: .directObject)

		// signature:65536
		let sigdesc = NSAppleEventDescriptor.init(int32: 65536)
		targ.setAttribute(sigdesc, forEventCode: .signatureClass)
	}

	public func setReference(target targ: NSAppleEventDescriptor, source src: NSAppleEventDescriptor) {
		targ.setParam(src, forEventCode: .directObject)

		// signature:65536
		let sigdesc = NSAppleEventDescriptor.init(int32: 65536)
		targ.setAttribute(sigdesc, forEventCode: .signatureClass)
	}

	private func errorInDescription(descriptor desc: NSAppleEventDescriptor) -> NSError? {
		if let errndesc = desc.paramDescriptor(forKeyword: CNEventCode.errorCount.code()) {
			CNLog(logLevel: .error, message: "errorInDescriptor: \(desc.description)")
			let errnum = errndesc.int32Value
			var errstr: String = ""
			if let errsdesc = desc.paramDescriptor(forKeyword: CNEventCode.errorString.code()) {
				if let estr = errsdesc.stringValue {
					errstr = estr
				}
			}
			return NSError.parseError(message: "AppleEventError(\(errnum)) \(errstr)")
		}
		return nil
	}

	public func setNameOfFrontWindow(name nm: String) -> ExecResult {
		let result: ExecResult
		if let appdesc = applicationDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.setData.code()
			let basedesc	= baseDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* Destination */
			let dst = selectNameProperty(of: selectFrontObject(number: 1, of: .document))
			/* Source string */
			let src  = NSAppleEventDescriptor(string: nm)
			/* Setup command */
			setAssignment(target: basedesc, destination: dst, source: src)
			/* Execute */
			result = execute(descriptor: basedesc)
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	public func nameOfFrontWindow() -> StringResult {
		let result: StringResult
		if let appdesc = applicationDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.getData.code()
			let basedesc	= baseDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* Source */
			let src = selectNameProperty(of: selectFrontObject(number: 1, of: .document))
			setReference(target: basedesc, source: src)
			/* Execute */
			switch execute(descriptor: basedesc) {
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

	public func ackToString(ackDescription ack: NSAppleEventDescriptor) -> StringResult {
		//NSLog("ack-desc=\(ack.description)")
		if let dirparam = ack.paramDescriptor(forKeyword: CNEventCode.directObject.code()) {
			if let str = dirparam.stringValue {
				return .ok(str)
			}
		}
		return .error(NSError.parseError(message: "The ack does not have "))
	}
}

public class CNTextEditApplication: CNEventReceiverApplication
{
	public func makeNewDocument() -> ExecResult {
		let result: ExecResult
		if let appdesc = self.applicationDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.make.code()
			let basedesc	= baseDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			setDocumentProperty(target: basedesc, name: nil)
			result = execute(descriptor: basedesc)
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	private func setDocumentProperty(target targ: NSAppleEventDescriptor, name nm: String?) {
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

	public func open(fileURL url: URL) -> ExecResult {
		let result: ExecResult
		if let appdesc = applicationDescriptor {
			let eclass	= CNEventCode.appleEvent.code()
			let eid		= CNEventCode.openDocument.code()
			let basedesc	= baseDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* File URL */
			basedesc.setDescriptor(NSAppleEventDescriptor(fileURL: url), forEventCode: .directObject)
			/* Execute */
			result = execute(descriptor: basedesc)
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	public func close(fileURL url: URL?) -> ExecResult {
		let result: ExecResult
		if let appdesc = applicationDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.closeDocument.code()
			let basedesc	= baseDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* 'kfil':File path */
			if let u = url {
				basedesc.setDescriptor(NSAppleEventDescriptor(fileURL: u), forEventCode: .file)
			}
			/* Execute */
			result = execute(descriptor: basedesc)
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	public func setContentOfFrontWindow(context ctxt: String) -> NSError? {
		let result: NSError?
		if let appdesc = applicationDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.setData.code()
			let basedesc	= baseDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)

			/* Destination: context of front document */
			let dst = selectAllContext(of: selectFrontObject(number: 1, of: .document))
			/* Source string */
			let src  = NSAppleEventDescriptor(string: ctxt)
			/* Setup command */
			setAssignment(target: basedesc, destination: dst, source: src)
			/* Execute */
			switch execute(descriptor: basedesc) {
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
		if let appdesc = applicationDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.getData.code()
			let basedesc	= baseDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* Source */
			let src = selectAllContext(of: selectFrontObject(number: 1, of: .document))
			setReference(target: basedesc, source: src)
			/* Execute */
			switch execute(descriptor: basedesc) {
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

	public func save(fileURL url: URL) -> ExecResult {
		let result: ExecResult
		if let appdesc = applicationDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.saveDocument.code()
			let basedesc	= baseDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* File URL */
			setFileLocation(target: basedesc, fileURL: url)
			/* Source object */
			let src = selectFrontObject(number: 1, of: .document)
			basedesc.setParam(src, forEventCode: .directObject)
			/* signature:65536 */
			let sigdesc = NSAppleEventDescriptor.init(int32: 65536)
			basedesc.setAttribute(sigdesc, forEventCode: .signatureClass)
			/* Execute */
			result = execute(descriptor: basedesc)
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}

	private func setFileLocation(target targ: NSAppleEventDescriptor, fileURL url: URL) {
		/* 'fltp':'ctxt' */
		targ.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.context.code()), forEventCode: .fileType)
		/* 'kfil':File path */
		targ.setDescriptor(NSAppleEventDescriptor(fileURL: url), forEventCode: .file)
	}
}

public class CNSafariApplication: CNEventReceiverApplication
{
	public func newTab() -> ExecResult {
		let result: ExecResult
		if let appdesc = applicationDescriptor {
			let eclass	= CNEventCode.core.code()
			let eid		= CNEventCode.make.code()
			let basedesc	= baseDescriptor(applicationDescriptor: appdesc, eventClass: eclass, eventID: eid)
			/* objectClass:tab */
			basedesc.setDescriptor(NSAppleEventDescriptor(enumCode: CNEventCode.tab.code()), forEventCode: .objectClass)
			basedesc.setAttribute(NSAppleEventDescriptor.init(int32: 65536), forEventCode: .signatureClass)
			/* tab object [format:index, selectData:1]*/
			let newtab = selectFrontObject(number: 1, of: .window)
			/* insertHere:object*/
			basedesc.setDescriptor(newtab, forEventCode: .insertHere)
			CNLog(logLevel: .detail, message: "newTab: \(basedesc.description)")
			/* Execute */
			result = execute(descriptor: basedesc)
		} else {
			result = .error(NSError.parseError(message: "No event descriptor"))
		}
		return result
	}
}

#endif

