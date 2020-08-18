/**
 * @file	CNReceiverApplication.swift
 * @brief	Define CNReceiverApplication class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import ScriptingBridge
import Foundation

public class CNReceiverApplication: CNRemoteApplication
{
	private var mApplication:	SBApplication

	public override init(application runapp: NSRunningApplication) {
		if let app = SBApplication(processIdentifier: runapp.processIdentifier) {
			mApplication = app
		} else {
			fatalError("Failed to allocate SBApplication")
		}
		super.init(application: runapp)
	}

	public func windows() -> SBElementArray {
		if let result = mApplication.perform(Selector("windows")) as? SBElementArray {
			
		}
	}
}

/*
public class CNReceiverApplication: CNRemoteApplication
{
	/* Reference: https://hhas.bitbucket.io/welcome.html */
	static private let keyDirectObject: OSType = 0x2D2D2D2D
	//static private let keyErrorNumber:  OSType = 0x6572726E
	static private let keySubjectAttr:  OSType = 0x7375626A
	static private let enumConsiderations: OSType = 0x636F6E73
	static private let enumConsidsAndIgnores: OSType = 0x63736967

	private var mDescriptor: NSAppleEventDescriptor

	public override init(application runapp: NSRunningApplication) {
		mDescriptor = NSAppleEventDescriptor(processIdentifier: runapp.processIdentifier)
		super.init(application: runapp)
	}

	public func start() -> Bool {
		let status: OSStatus = AEDeterminePermissionToAutomateTarget(mDescriptor.aeDesc,
									     typeWildCard,
									     typeWildCard,
									     true)
		var result: Bool = false
		switch status {
		case noErr:
			result = true
		case OSStatus(errAEEventNotPermitted):
			NSLog("Not permitted")
		case OSStatus(procNotFound):
			NSLog("Not found")
		default:
			NSLog("Unknown error")
		}
		return result
	}

	public enum SendEventResult {
		case ok(CNAppleEventDescriptor)
		case error(Error)
	}

	public func sendEvent(eventDescriptor desc: CNAppleEventDescriptor) -> SendEventResult {
		let event = desc.toEvent(target: mDescriptor)
		NSLog("sendEvent: event = \(event.description)")
		do {
			let evtres = try event.sendEvent(options: .defaultOptions, timeout: 1.0)
			NSLog("sendEvent: responce = \(evtres.description)")
			if let result = evtres.toNativeDescriptor() {
				return .ok(result)
			} else {
				let err = NSError.parseError(message: "Failed to get responce")
				return .error(err)
			}
		} catch let err {
			return .error(err)
		}
	}
}
*/


