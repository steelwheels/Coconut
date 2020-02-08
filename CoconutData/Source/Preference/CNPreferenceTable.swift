/**
 * @file	CNPrefereceParameter.swift
 * @brief	Define CNPreferenceParameterTable class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNPreferenceListner: NSObject
{
	public typealias CallbackFunction = (_ value: Any) -> Void

	private var		mKey:		String
	private var		mCallbackFunc:	CallbackFunction

	public var key: String { get { return mKey }}

	public init(forKey key: String, callback cbfunc: @escaping CallbackFunction) {
		mKey		= key
		mCallbackFunc	= cbfunc
	}

	public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if let vals = change {
			if let val = vals[.newKey] {
				mCallbackFunc(val)
			}
		}
	}
}

open class CNPreferenceTable
{
	public typealias CallbackFunction = CNPreferenceListner.CallbackFunction

	private var mParameterTable:	NSMutableDictionary

	public init(){
		mParameterTable = NSMutableDictionary(capacity: 32)
	}

	public func set(anyValue val: Any, forKey key: String) {
		mParameterTable.setValue(val, forKey: key)
	}

	public func anyValue(forKey key: String) -> Any? {
		return mParameterTable.value(forKey: key)
	}

	public func set(intValue val: Int, forKey key: String) {
		let num = NSNumber(integerLiteral: val)
		mParameterTable.setValue(num, forKey: key)
	}

	public func intValue(forKey key: String) -> Int? {
		if let num = mParameterTable.value(forKey: key) as? NSNumber {
			return num.intValue
		} else {
			return nil
		}
	}

	public func addObserver(forKey key: String, callback cbfunc: @escaping CallbackFunction) -> CNPreferenceListner {
		let listner = CNPreferenceListner(forKey: key, callback: cbfunc)
		mParameterTable.addObserver(listner, forKeyPath: key, options: [.new], context: nil)
		return listner
	}

	public func removeObserver(listner dst: CNPreferenceListner) {
		mParameterTable.removeObserver(dst, forKeyPath: dst.key)
	}
}

