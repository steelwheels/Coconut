/**
 * @file	CNWorkspace.swift
 * @brief	Define CNWorkspace class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation
#if os(OSX)
  import Cocoa
#endif
#if os(iOS)
  import UIKit
#endif

public class CNWorkspace
{
	static public func open(URL url: URL, callback cbfunc: @escaping (_ result: Bool) -> Void){
		#if os(OSX)
		let config = NSWorkspace.OpenConfiguration()
		let handler = {
			(_ app: NSRunningApplication?, _ err: Error?) -> Void in cbfunc(err == nil)
		}
		NSWorkspace.shared.open(url, configuration: config, completionHandler: handler)
		#else
		let handler = {
			(_ result: Bool) -> Void in cbfunc(result)
		}
		UIApplication.shared.open(url, options: [:], completionHandler: handler)
		#endif
	}
}

