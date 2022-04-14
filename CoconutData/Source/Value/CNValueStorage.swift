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
	private var mValueCache:		CNValueCache
	private var mLock:			NSLock

	// packdir: Root directory for package (*.jspkg)
	// fpath:   The location of data file against packdir
	public init(sourceDirectory srcdir: URL, cacheDirectory cachedir: URL, filePath fpath: String) {
		mSourceDirectory	= srcdir
		mCacheDirectory		= cachedir
		mFilePath		= fpath
		mRootValue		= CNMutableDictionaryValue()
		mValueCache		= CNValueCache()
		mLock			= NSLock()
	}

	public var cache: CNValueCache { get {
		return mValueCache
	}}
	public var description: String { get {
		return "{srcdir=\(mSourceDirectory.path), cachedir=\(mCacheDirectory.path), file=\(mFilePath)}"
	}}

	private var sourceFile: URL { get { return mSourceDirectory.appendingPathComponent(mFilePath)	}}
	private var cacheFile:  URL { get { return mCacheDirectory.appendingPathComponent(mFilePath)	}}

	public func load() -> Result {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }

		/* Copy source file to cache file */
		let srcfile   = self.sourceFile
		let cachefile = self.cacheFile

		guard let contents = CNValueStorage.createCacheFile(cacheFile: cachefile, sourceFile: srcfile) else {
			let err = NSError.fileError(message: "Failed to create cache file: \(cachefile.path)")
			return .error(err)
		}

		let parser = CNValueParser()
		let result: Result
		switch parser.parse(source: contents as String) {
		case .ok(let val):
			mRootValue = CNValueToMutableValue(from: val, sourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory)
			result = .ok(val)
		case .error(let err):
			result = .error(err)
		}
		return result
	}

	public static func createCacheFile(cacheFile cache: URL, sourceFile source: URL) -> String? {
		let fmanager = FileManager.default
		guard fmanager.fileExists(atURL: source) else {
			CNLog(logLevel: .error, message: "Source file \(source.path) is NOT exist", atFunction: #function, inFile: #file)
			return nil
		}
		if fmanager.fileExists(atURL: cache){
			/* Already exist */
			return cache.loadContents() as String?
		} else {
			/* File is not exist */
			if fmanager.copyFile(sourceFile: source, destinationFile: cache, doReplace: false) {
				return cache.loadContents() as String?
			} else {
				CNLog(logLevel: .error, message: "Failed to create cache file: \(cache.path)", atFunction: #function, inFile: #file)
				return nil
			}
		}
	}

	public func clearCache() -> Result {
		switch FileManager.default.removeFile(atURL: self.cacheFile) {
		case .ok:
			break // continue processing
		case .error(let err):
			return .error(err)
		}
		return self.load()
	}

	public func value(forPath path: CNValuePath) -> CNValue? {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }

		if let mval = mRootValue.value(forPath: path) {
			let result: CNValue
			switch mval.type {
			case .segment:
				if let refval = mval as? CNMutableValueSegment {
					if let cval = refval.context {
						result = cval.toValue()
					} else {
						result = .nullValue
					}
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
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }

		let mval = CNValueToMutableValue(from: val, sourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory)
		if mRootValue.set(value: mval, forPath: path) {
			mValueCache.setDirty(at: path)
			return true
		} else {
			return false
		}
	}

	public func append(value val: CNValue, forPath path: CNValuePath) -> Bool {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }

		let mval = CNValueToMutableValue(from: val, sourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory)
		if mRootValue.append(value: mval, forPath: path) {
			mValueCache.setDirty(at: path)
			return true
		} else {
			return false
		}
	}

	public func delete(forPath path: CNValuePath) -> Bool {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }
		mValueCache.setDirty(at: path)
		if mRootValue.delete(forPath: path.elements) {
			return true
		} else {
			return false
		}
	}

	public func save() -> Bool {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }

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
		if save(value: mRootValue, outFile: cachefile) {
			return true
		} else {
			CNLog(logLevel: .error, message: "Failed to store storage: \(cachefile.path)", atFunction: #function, inFile: #file)
			return false
		}
	}

	private func save(value val: CNMutableValue, outFile file: URL) -> Bool {
		/* save it self */
		var result = true
		if mRootValue.isDirty {
			let txt = val.toValue().toText().toStrings().joined(separator: "\n")
			if file.storeContents(contents: txt + "\n") {
				val.isDirty = false
			} else {
				CNLog(logLevel: .error, message: "Failed to store storage: \(file.path)", atFunction: #function, inFile: #file)
				result = false
			}
		}
		/* save segmented values */
		let refs = CNAllSegmentsInValue(value: val)
		for ref in refs {
			if let cval = ref.context {
				if !save(value: cval, outFile: ref.cacheFile) {
					result = false
				}
			}
		}
		return result
	}

	public func toValue() -> CNValue {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }
		return mRootValue.toValue()
	}
}


