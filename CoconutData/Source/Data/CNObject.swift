/**
 * @file	CNObject.swift
 * @brief	Define CNObject class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

@objc open class CNObject: NSObject
{
	private var mProperties:	NSMutableDictionary

	public override init() {
		mProperties = NSMutableDictionary(capacity: 32)
	}

	public override func value(forKey key: String) -> Any? {
		return mProperties.value(forKey: key)
	}

	public override func value(forKeyPath keyPath: String) -> Any? {
		return mProperties.value(forKeyPath: keyPath)
	}

	public override func dictionaryWithValues(forKeys keys: [String]) -> [String : Any] {
		return mProperties.dictionaryWithValues(forKeys: keys)
	}

	public override func value(forUndefinedKey key: String) -> Any? {
		return mProperties.value(forUndefinedKey: key)
	}

	public override func mutableArrayValue(forKey key: String) -> NSMutableArray {
		return mProperties.mutableArrayValue(forKey: key)
	}

	public override func mutableSetValue(forKey key: String) -> NSMutableSet {
		return mProperties.mutableSetValue(forKey: key)
	}

	public override func mutableSetValue(forKeyPath keyPath: String) -> NSMutableSet {
		return mProperties.mutableSetValue(forKeyPath: keyPath)
	}

	public override func mutableOrderedSetValue(forKey key: String) -> NSMutableOrderedSet {
		return mProperties.mutableOrderedSetValue(forKey: key)
	}

	public override func setValue(_ value: Any?, forKeyPath keyPath: String) {
		return mProperties.setValue(value, forKeyPath: keyPath)
	}

	public override func setValue(_ value: Any?, forKey key: String) {
		return mProperties.setValue(value, forKey: key)
	}

	public override func setValuesForKeys(_ keyedValues: [String : Any]) {
		return mProperties.setValuesForKeys(keyedValues)
	}

	public override func setNilValueForKey(_ key: String) {
		return mProperties.setNilValueForKey(key)
	}

	public override func setValue(_ value: Any?, forUndefinedKey key: String) {
		return mProperties.setValue(value, forUndefinedKey: key)
	}

	public override func validateValue(_ ioValue: AutoreleasingUnsafeMutablePointer<AnyObject?>, forKey inKey: String) throws {
		return try mProperties.validateValue(ioValue, forKey: inKey)
	}

	public override func validateValue(_ ioValue: AutoreleasingUnsafeMutablePointer<AnyObject?>, forKeyPath inKeyPath: String) throws {
		return try mProperties.validateValue(ioValue, forKeyPath: inKeyPath)
	}
}
