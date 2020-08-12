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
	private var mRunningApplication:	NSRunningApplication

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

	public init(application runapp: NSRunningApplication){
		mRunningApplication = runapp
	}

	public var bundleIdentifier: String? {
		get { return mRunningApplication.bundleIdentifier }
	}

	public var isFinishLaunching: Bool {
		get { return mRunningApplication.isFinishedLaunching }
	}
}

#endif

