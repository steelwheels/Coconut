/**
 * @file	CNPropertyList.swift
 * @brief	Define CNPropertyList class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public class CNPropertyList
{
	private var mBundleDirName	: String
	private var mPropertyList	: NSDictionary?

	public init(bundleDirectoryName dirname: String){
		mBundleDirName = dirname
		mPropertyList  = nil
	}

	public var version: String? {
		get {
			if let plist = propertyList() {
				if let pname = plist.object(forKey: "CFBundleShortVersionString") as? NSString {
					return String(pname)
				}
			}
			return nil
		}
	}

	private func propertyList() -> NSDictionary? {
		if let plist = mPropertyList {
			return plist
		} else {
			if let pathname = mainBundlePath() {
				if let plist = NSDictionary(contentsOfFile: pathname) {
					mPropertyList = plist
					return plist
				}
			}
		}
		return nil
	}

	private func mainBundlePath() -> String? {
		if let path = Bundle.main.path(forResource: "Info", ofType: "plist", inDirectory: mBundleDirName + "/Contents") {
			return path
		} else {
			return nil
		}
	}
}
