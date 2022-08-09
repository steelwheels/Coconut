/*
 * @file	CNStorage.swift
 * @brief	Define CNStorage class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

private class CNStorageCache
{
	private var	mPath:			CNValuePath
	private var 	mIsDirty:		Bool

	public init(path p: CNValuePath){
		mPath		= p
		mIsDirty	= true
	}

	public var path: CNValuePath { get { return mPath }}

	public var isDirty: Bool {
		get         { return mIsDirty }
		set(newval) { mIsDirty = newval }
	}
}

private class CNStorageCallback
{
	public typealias EventFunction = CNStorage.EventFunction

	private var mPath:		CNValuePath
	private var mEventFunction:	EventFunction

	public init(path p: CNValuePath, eventFunc efunc: @escaping EventFunction){
		mPath		= p
		mEventFunction	= efunc
	}

	public var path: CNValuePath { get { return mPath }}
	public var eventFunc: EventFunction { get { return mEventFunction }}
}

public class CNStorage
{
	public typealias EventFunction = () -> Void

	private var mSourceDirectory:		URL
	private var mCacheDirectory:		URL
	private var mFilePath:			String
	private var mRootValue:			CNMutableValue
	private var mCache:			Dictionary<Int, CNStorageCache>
	private var mNextCacheId:		Int
	private var mEventFunctions:		Dictionary<Int, CNStorageCallback>
	private var mNextEventFuncId:		Int
	private var mLock:			NSLock

	// packdir: Root directory for package (*.jspkg)
	// fpath:   The location of data file against packdir
	public init(sourceDirectory srcdir: URL, cacheDirectory cachedir: URL, filePath fpath: String) {
		mSourceDirectory	= srcdir
		mCacheDirectory		= cachedir
		mFilePath		= fpath
		mRootValue		= CNMutableDictionaryValue(sourceDirectory: srcdir, cacheDirectory: cachedir)
		mCache			= [:]
		mNextCacheId		= 0
		mEventFunctions		= [:]
		mNextEventFuncId	= 0
		mLock			= NSLock()
	}

	public var description: String { get {
		return "{srcdir=\(mSourceDirectory.path), cachedir=\(mCacheDirectory.path), file=\(mFilePath)}"
	}}

	private var sourceFile: URL { get { return mSourceDirectory.appendingPathComponent(mFilePath)	}}
	private var cacheFile:  URL { get { return mCacheDirectory.appendingPathComponent(mFilePath)	}}

	public func load() -> Result<CNValue, NSError> {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }

		/* Copy source file to cache file */
		let srcfile   = self.sourceFile
		let cachefile = self.cacheFile

		guard let contents = CNStorage.createCacheFile(cacheFile: cachefile, sourceFile: srcfile) else {
			let err = NSError.fileError(message: "Failed to create cache file: \(cachefile.path)")
			return .failure(err)
		}

		let parser = CNValueParser()
		let result: Result<CNValue, NSError>
		switch parser.parse(source: contents as String) {
		case .success(let val):
			mRootValue = CNMutableValue.valueToMutableValue(from: val, sourceDirectory: mSourceDirectory, cacheDirectory: mCacheDirectory)
			result = .success(val)
		case .failure(let err):
			result = .failure(err)
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

	public func removeCacheFile() -> Result<CNValue, NSError> {
		switch FileManager.default.removeFile(atURL: self.cacheFile) {
		case .ok:
			break // continue processing
		case .error(let err):
			return .failure(err)
		}
		return self.load()
	}

	public func allocateCache(forPath path: CNValuePath) -> Int {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }

		let cache = CNStorageCache(path: path)
		let cid   = mNextCacheId
		mCache[mNextCacheId] = cache
		mNextCacheId += 1
		return cid
	}

	public func removeCache(cacheId cid: Int) {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }

		mCache[cid] = nil
	}

	public func isDirty(cacheId cid: Int) -> Bool {
		if let cache = mCache[cid] {
			return cache.isDirty
		} else {
			CNLog(logLevel: .error, message: "Unknown cache id: \(cid)", atFunction: #function, inFile: #file)
			return false
		}
	}

	private func setDirty(at path: CNValuePath) {
		for cache in mCache.values {
			if cache.path.isIncluded(in: path) {
				cache.isDirty = true
			}
		}
	}

	public func setClean(cacheId cid: Int) {
		if let cache = mCache[cid] {
			cache.isDirty = false
		} else {
			CNLog(logLevel: .error, message: "Unknown cache id: \(cid)", atFunction: #function, inFile: #file)
		}
	}

	public func allocateEventFunction(forPath path: CNValuePath, eventFunc efunc: @escaping EventFunction) -> Int {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }

		let cbfunc = CNStorageCallback(path: path, eventFunc: efunc)
		let eid    = mNextEventFuncId
		mEventFunctions[mNextEventFuncId] = cbfunc
		mNextEventFuncId += 1
		return eid
	}

	public func removeEventFunction(eventFuncId eid: Int) {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }
		mEventFunctions[eid] = nil
	}

	public func value(forPath path: CNValuePath) -> CNValue? {
		/* Mutex lock */
		mLock.lock() ; defer { mLock.unlock() }
		if let elms = normalizeValuePath(valuePath: path) {
			switch mRootValue.value(forPath: elms) {
			case .success(let val):
				return val
			case .failure(let err):
				CNLog(logLevel: .error, message: "Error: \(err.toString())", atFunction: #function, inFile: #file)
			}
		}
		return nil
	}

	public func set(value val: CNValue, forPath path: CNValuePath) -> Bool {
		/* Mutex lock and unlock */
		mLock.lock() ; defer { mLock.unlock() ; triggerCallbacks(path: path)}

		var result: Bool
		if let elms = normalizeValuePath(valuePath: path) {
			if let err = mRootValue.set(value: val, forPath: elms) {
				/* Some error occured */
				CNLog(logLevel: .error, message: "Error: \(err.toString())", atFunction: #function, inFile: #file)
				result = false
			} else {
				/* No error */
				mRootValue.labelTable().clear()
				setDirty(at: path)
				result = true
			}
		} else {
			result = false
		}
		return result
	}

	public func append(value val: CNValue, forPath path: CNValuePath) -> Bool {
		/* Mutex lock and unlock */
		mLock.lock() ; defer { mLock.unlock() ; triggerCallbacks(path: path)}

		if let elms = normalizeValuePath(valuePath: path) {
			if let err = mRootValue.append(value: val, forPath: elms) {
				CNLog(logLevel: .error, message: "Error: \(err.toString())", atFunction: #function, inFile: #file)
				return false
			} else {
				mRootValue.labelTable().clear()
				setDirty(at: path)
				return true
			}
		} else {
			return false
		}
	}

	public func delete(forPath path: CNValuePath) -> Bool {
		/* Mutex lock and unlock */
		mLock.lock() ; defer { mLock.unlock() }

		setDirty(at: path)
		if let elms = normalizeValuePath(valuePath: path) {
			if let err = mRootValue.delete(forPath: elms) {
				CNLog(logLevel: .error, message: "Error: \(err.toString())", atFunction: #function, inFile: #file)
				return false
			} else {
				/* No error */
				mRootValue.labelTable().clear()
				return true
			}
		} else {
			return false
		}
	}

	private func normalizeValuePath(valuePath path: CNValuePath) -> Array<CNValuePath.Element>? {
		if let ident = path.identifier {
			if var topelms = mRootValue.labelTable().labelToPath(label: ident, in: mRootValue) {
				topelms.append(contentsOf: path.elements)
				return topelms
			} else {
				CNLog(logLevel: .error, message: "Failed to find label: \(ident)", atFunction: #function, inFile: #file)
			}
		}
		return path.elements
	}

	private func triggerCallbacks(path pth: CNValuePath) {
		for event in mEventFunctions.values {
			if event.path.isIncluded(in: pth) {
				event.eventFunc()
			}
		}
	}

	public func segments(traceOption trace: CNValueSegmentTraceOption) -> Array<CNMutableValueSegment> {
		return CNSegmentsInValue(value: mRootValue, traceOption: trace)
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
			let txt = val.toValue().toScript().toStrings().joined(separator: "\n")
			if file.storeContents(contents: txt + "\n") {
				val.isDirty = false
			} else {
				CNLog(logLevel: .error, message: "Failed to store storage: \(file.path)", atFunction: #function, inFile: #file)
				result = false
			}
		}
		/* save segmented values */
		let refs = CNSegmentsInValue(value: val, traceOption: .traceNonNull)
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


