/*
 * @file	CNValueStorage.swift
 * @brief	Define CNValueStorage class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public class CNValueStorage
{
	public typealias Result = CNValueParser.Result

	private var mPackageDirectory:		URL
	private var mFilePath:			String
	private var mRootValue:			CNMutableValue
	private var mParentStorage:		CNValueStorage?

	// packdir: Root directory for package (*.jspkg)
	// fpath:   The location of data file against packdir
	public init(packageDirectory packdir: URL, filePath fpath: String, parentStorage storage: CNValueStorage?) {
		mPackageDirectory	= packdir
		mFilePath		= fpath
		mRootValue		= CNMutableDictionaryValue()
		mParentStorage		= storage
	}

	/* The storage which has no file to load/save contents */
	public static func allocateVolatileValueStorage() -> CNValueStorage {
		return CNValueStorage(packageDirectory: URL.null(), filePath: "dummy.json", parentStorage: nil)
	}

	public var storageFile: URL {
		get { return mPackageDirectory.appendingPathComponent(mFilePath, isDirectory: false) }
	}

	public func load() -> Result {
		let file = self.storageFile
		guard let ctxt = file.loadContents() else {
			let err = NSError.fileError(message: "Failed to read file from \(file.path)")
			return .error(err)
		}
		let parser = CNValueParser()
		let result: Result
		switch parser.parse(source: ctxt as String) {
		case .ok(let val):
			mRootValue = CNValueToMutableValue(from: val)
			result = .ok(val)
		case .error(let err):
			result = .error(err)
		}
		return result
	}

	public func value(forPath path: CNValuePath) -> CNValue? {
		if let mval = mRootValue.value(forPath: path.elements, fromPackageDirectory: mPackageDirectory) {
			return mval.toValue()
		} else if let parent = mParentStorage {
			return parent.value(forPath: path)
		} else {
			return nil
		}
	}

	public func set(value val: CNValue, forPath path: CNValuePath) -> Bool {
		let mval = CNValueToMutableValue(from: val)
		return mRootValue.set(value: mval, forPath: path.elements, fromPackageDirectory: mPackageDirectory)
	}

	public func store() -> Bool {
		/* Make directory for the file */
		let file = self.storageFile
		let pathes = file.deletingLastPathComponent()
		switch FileManager.default.createDirectories(directory: pathes) {
		case .ok:
			break // continue
		case .error(let err):
			CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
			return false // stop the save operation
		}
		/* Save into the file */
		let val = mRootValue.toValue()
		let txt = val.toText().toStrings().joined(separator: "\n")
		return file.storeContents(contents: txt + "\n")
	}
}


