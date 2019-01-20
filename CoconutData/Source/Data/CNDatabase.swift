/**
 * @file	CNDatabase.swift
 * @brief	Define CNDatabase class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public protocol CNDatabaseProtocol
{
	func stateId() -> UInt64
	func read(identifier ident: String) -> CNNativeValue?
	func write(identifier ident: String, value val: CNNativeValue)
	func delete(identifier ident: String)
	func commit()
	func toText() -> CNTextSection
}

private class CNDatabaseStorage
{
	private var mDictionary		: Dictionary<String, CNNativeValue>

	public init(){
		mDictionary = [:]
	}

	fileprivate var contents: Dictionary<String, CNNativeValue> {
		get { return mDictionary }
	}

	public var keys: Dictionary<String, CNNativeValue>.Keys {
		get { return mDictionary.keys }
	}

	public func read(identifier ident: String) -> CNNativeValue? {
		return mDictionary[ident]
	}

	public func write(identifier ident: String, value val: CNNativeValue) {
		mDictionary[ident] = val
	}

	public func delete(identifier ident: String)  {
		mDictionary.removeValue(forKey: ident)
	}

	public func clean(){
		mDictionary = [:]
	}

	public func toText() -> CNTextSection {
		let section = CNTextSection()
		for ident in mDictionary.keys.sorted() {
			if let value = mDictionary[ident] {
				let valtxt = value.toText()
				let newtxt: CNText
				if let valline = valtxt as? CNTextLine {
					let newline = CNTextLine(string: ident + " : ")
					newline.append(text: valline)
					newtxt = newline
				} else {
					let newsect = CNTextSection()
					newsect.header = ident + " : {"
					newsect.footer = "}"
					newsect.add(text: valtxt)
					newtxt = newsect
				}
				section.add(text: newtxt)
			} else {
				CNLog(type: .Error, message: "Can not happen", place: #function)
			}
		}
		return section
	}
}

open class CNBaseDatabase: CNDatabaseProtocol
{
	private var mLocalId:		UInt64
	private var mWriteCache:	CNDatabaseStorage
	private var mReadCache:		CNDatabaseStorage
	private var mDeleted:		Set<String>

	public init(){
		mLocalId	= 0
		mWriteCache	= CNDatabaseStorage()
		mReadCache	= CNDatabaseStorage()
		mDeleted	= []
	}

	open func stateId() -> UInt64 {
		CNLog(type: .Error, message: "Must be override", place: #file)
		return 0
	}

	open func read(identifier ident: String) -> CNNativeValue? {
		/* Check state */
		let mainid = stateId()
		if mLocalId != mainid {
			mReadCache.clean()
			mLocalId = mainid
		}

		if let data = mReadCache.read(identifier: ident) {
			return data
		} else {
			if let newdata = readUncached(identifier: ident) {
				let _ = mReadCache.write(identifier: ident, value: newdata)
				return newdata
			} else {
				return nil
			}
		}
	}

	open func write(identifier ident: String, value val: CNNativeValue) {
		mWriteCache.write(identifier: ident, value: val)
	}

	open func delete(identifier ident: String) {
		/* Check already deleted */
		guard !mDeleted.contains(ident) else {
			return
		}
		/* Delete from cache */
		mReadCache.delete(identifier: ident)
		mWriteCache.delete(identifier: ident)
		/* Add to delete target list */
		mDeleted.insert(ident)
	}

	open func commit() {
		/* Flush the cache */
		updateUncached(cache: mWriteCache.contents, deletedItems: mDeleted)
		/* Clear the cache */
		mWriteCache.clean()
		mDeleted = []
	}

	open func readUncached(identifier ident: String) -> CNNativeValue? {
		return nil
	}

	open func updateUncached(cache cdata: Dictionary<String, CNNativeValue>, deletedItems deleted: Set<String>){
		/* Do nothing */
	}

	open func toText() ->  CNTextSection {
		let rcache = mReadCache.toText()
		rcache.header = "read_cache: {" ; rcache.footer = "}"
		let wcache = mWriteCache.toText()
		wcache.header = "write_cache: {" ; wcache.footer = "}"

		let section = CNTextSection()
		section.add(text: rcache)
		section.add(text: wcache)
		return section
	}
}

open class CNMainDatabase: CNBaseDatabase
{
	private var mStateId:	UInt64
	private var mStorage:	CNDatabaseStorage
	private var mLock:	NSLock

	public override init(){
		mStateId = 0
		mStorage = CNDatabaseStorage()
		mLock    = NSLock()
	}

	open override func stateId() -> UInt64 {
		return mStateId
	}

	open override func readUncached(identifier ident: String) -> CNNativeValue? {
		return mStorage.read(identifier: ident)
	}

	open override func updateUncached(cache cdata: Dictionary<String, CNNativeValue>, deletedItems deleted: Set<String>){
		mLock.lock()
		/* Write data */
		for ident in cdata.keys {
			if let value = cdata[ident] {
				let _ = mStorage.write(identifier: ident, value: value)
			} else {
				fatalError("Can not happen at \(#function)")
			}
		}
		/* Delete */
		for ident in deleted {
			let _ = mStorage.delete(identifier: ident)
		}
		/* Update state id */
		mStateId += 1
		mLock.unlock()
	}

	open override func toText() ->  CNTextSection {
		let mainsec = CNTextSection()
		mainsec.header = "main_database: {" ; mainsec.footer = "}"
		mainsec.add(text: mStorage.toText())

		let result = super.toText()
		result.add(text: mainsec)

		return result
	}
}

open class CNRemoteDatabase: CNBaseDatabase
{
	private var mRemoteDatabase: CNDatabaseProtocol?

	public override init() {
		mRemoteDatabase = nil
	}

	public func bind(mainDatabase db: CNMainDatabase){
		mRemoteDatabase = db
	}

	open override func stateId() -> UInt64 {
		if let db = mRemoteDatabase {
			return db.stateId()
		} else {
			CNLog(type: .Error, message: "No state id", place: #file)
			return 0
		}
	}

	open override func readUncached(identifier ident: String) -> CNNativeValue? {
		if let db = mRemoteDatabase {
			return db.read(identifier: ident)
		} else {
			return nil
		}
	}

	open override func updateUncached(cache cdata: Dictionary<String, CNNativeValue>, deletedItems deleted: Set<String>){
		if let db = mRemoteDatabase {
			/* Write data */
			for ident in cdata.keys {
				if let value = cdata[ident] {
					let _ = db.write(identifier: ident, value: value)
				} else {
					fatalError("Can not happen at \(#function)")
				}
			}
			/* Delete */
			for ident in deleted {
				let _ = db.delete(identifier: ident)
			}
			/* Commit */
			db.commit()
		} else {
			CNLog(type: .Error, message: "No remove database", place: #file)
		}
	}
}




