/**
 * @file	CNDatabase.swift
 * @brief	Define CNDatabase class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

open class CNDatabase
{
	private var mDictionary		: Dictionary<String, CNNativeValue>

	public init(){
		mDictionary	= [:]
	}

	public func keys() -> Array<String> {
		return Array(mDictionary.keys)
	}
	
	public func values() -> Array<CNNativeValue> {
		return Array(mDictionary.values)
	}

	open func create(identifier ident: String, value val: CNNativeValue) -> Bool {
		mDictionary[ident] = val
		return true
	}

	open func read(identifier ident: String) -> CNNativeValue? {
		if let val = mDictionary[ident] {
			return val
		} else {
			return nil
		}
	}

	open func write(identifier ident: String, value val: CNNativeValue) -> Bool {
		if let _ = mDictionary[ident] {
			mDictionary[ident] = val
			return true
		}
		return false
	}

	open func delete(identifier ident: String) -> CNNativeValue? {
		if let val = mDictionary[ident] {
			mDictionary.removeValue(forKey: ident)
			return val
		} else {
			return nil
		}
	}

	open func commit() {
	}
}


