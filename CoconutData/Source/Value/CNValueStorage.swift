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

	private var mSourceDirectory:		URL
	private var mCacheDirectory:		URL
	private var mFilePath:			String
	private var mRootValue:			CNMutableValue

	// packdir: Root directory for package (*.jspkg)
	// fpath:   The location of data file against packdir
	public init(sourceDirectory srcdir: URL, cacheDirectory cachedir: URL, filePath fpath: String) {
		mSourceDirectory	= srcdir
		mCacheDirectory		= cachedir
		mFilePath		= fpath
		mRootValue		= CNMutableDictionaryValue()
	}

	public var description: String { get {
		return "{srcdir=\(mSourceDirectory.path), cachedir=\(mCacheDirectory.path), file=\(mFilePath)}"
	}}

	private var sourceFile: URL { get { return mSourceDirectory.appendingPathComponent(mFilePath)	}}
	private var cacheFile:  URL { get { return mCacheDirectory.appendingPathComponent(mFilePath)	}}

	public func load() -> Result {
		/* Copy source file to cache file */
		let srcfile   = self.sourceFile
		let cachefile = self.cacheFile
		guard FileManager.default.copyFileIfItIsNotExist(sourceFile: srcfile, destinationFile: cachefile) else {
			return .error(NSError.fileError(message: "Failed to copy: \(srcfile.path) to \(cachefile.path)"))
		}
		/* Load from cache file */
		guard let ctxt = cachefile.loadContents() else {
			let err = NSError.fileError(message: "Failed to read file from \(cachefile.path)")
			return .error(err)
		}
		let parser = CNValueParser()
		let result: Result
		switch parser.parse(source: ctxt as String) {
		case .ok(let val):
			mRootValue = CNValueToMutableValue(from: val, sourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory)
			result = .ok(val)
		case .error(let err):
			result = .error(err)
		}
		return result
	}

	public func value(forPath path: CNValuePath) -> CNValue? {
		if let mval = mRootValue.value(forPath: path.elements) {
			let result: CNValue
			switch mval.type {
			case .reference:
				if let refval = mval as? CNMutableValueReference {
					result = refval.context()
				} else {
					CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
					result = .nullValue
				}
			default:
				result = mval.toValue()
			}
			return result
		} else {
			return nil
		}
	}

	public func set(value val: CNValue, forPath path: CNValuePath) -> Bool {
		let mval = CNValueToMutableValue(from: val, sourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory)
		return mRootValue.set(value: mval, forPath: path.elements)
	}

	public func append(value val: CNValue, forPath path: CNValuePath) -> Bool {
		let mval = CNValueToMutableValue(from: val, sourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory)
		return mRootValue.append(value: mval, forPath: path.elements)
	}

	public func delete(forPath path: CNValuePath) -> Bool {
		return mRootValue.delete(forPath: path.elements)
	}

	public func store() -> Bool {
		let cachefile = self.cacheFile
		let pathes    = cachefile.deletingLastPathComponent()
		if !FileManager.default.fileExists(atPath: pathes.path) {
			switch FileManager.default.createDirectories(directory: pathes) {
			case .ok:
				break // continue
			case .error(let err):
				CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
				return false // stop the save operation
			}
		}
		/* Save into the file */
		let val = mRootValue.toValue()
		let txt = val.toText().toStrings().joined(separator: "\n")
		if cachefile.storeContents(contents: txt + "\n") {
			return true
		} else {
			CNLog(logLevel: .error, message: "Failed to store storage: \(self.description)", atFunction: #function, inFile: #file)
			return false
		}
	}

	public func toText() -> CNText {
		let result = CNTextSection()
		result.header    = "ValueStorage: {"
		result.footer    = "}"
		result.separator = ", "

		let package = CNTextLine(string: self.description)
		result.add(text: package)
		result.add(text: mRootValue.toText())

		return result
	}
}


