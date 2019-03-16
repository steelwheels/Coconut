/**
 * @file	CNPropertyList.swift
 * @brief	Define CNPropertyList class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public class CNPropertyList
{
	private enum BundleDirectory {
		case bundleDirectory(String)
		case applicationDirectory
	}

	private var mBundleDirectory	: BundleDirectory
	private var mPropertyList	: NSDictionary?

	public required init(bundleDirectoryName dirname: String){
		mBundleDirectory = .bundleDirectory(dirname)
		mPropertyList    = nil
	}

	public required init(applicationDirectoryName dirname: String){
		mBundleDirectory = .applicationDirectory
		mPropertyList    = nil
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
			switch mBundleDirectory {
			case .applicationDirectory:
				if let dict = Bundle.main.infoDictionary {
					mPropertyList = NSDictionary(dictionary: dict)
					return mPropertyList
				}
			case .bundleDirectory(let bname):
				if let pathname = mainBundlePath(bundleName: bname) {
					if let plist = NSDictionary(contentsOfFile: pathname) {
						mPropertyList = plist
						return plist
					}
				}
			}
		}
		return nil
	}

	private func mainBundlePath(bundleName bname: String) -> String? {
		if let path = Bundle.main.path(forResource: "Info", ofType: "plist", inDirectory: bname + "/Contents") {
			return path
		} else {
			return nil
		}
	}
}
