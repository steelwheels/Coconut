/**
 * @file	CNObserver.swift
 * @brief	Define CNObserver and CNObservedTable class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNObservedValueTable
{
	public typealias ListenerFunction = (Any?) -> Void	// new-value

	private var mValueTable:	NSMutableDictionary
	private var mObservers:		Dictionary<String, CNListener>

	public init(){
		mValueTable = NSMutableDictionary(capacity: 32)
		mObservers  = [:]
	}

	deinit {
		for key in mObservers.keys {
			if let observer = mObservers[key] {
				mValueTable.removeObserver(observer, forKeyPath: key)
			}
		}
	}

	public var keys: Array<String> {
		get {
			return Array(mObservers.keys)
		}
	}

	public func setValue(_ val: Any, forKey key: String){
		mValueTable.setValue(val, forKey: key)
	}

	public func value(forKey k: String) -> Any? {
		return mValueTable.value(forKey: k)
	}

	public func setBooleanValue(_ val: Bool, forKey key: String){
		let num = NSNumber(booleanLiteral: val)
		setValue(num, forKey: key)
	}

	public func booleanValue(forKey k: String) -> Bool {
		if let num = value(forKey: k) as? NSNumber {
			return num.boolValue
		} else {
			fatalError("No object at \(#function)")
		}
	}

	public func setObserver(forKey key: String, listnerFunction lfunc: @escaping CNObservedValueTable.ListenerFunction){
		if let obs = mObservers[key] {
			obs.add(listenerFunction: lfunc)
		} else {
			/* Allocate new observer */
			let newobs = CNListener()
			mObservers[key] = newobs
			newobs.add(listenerFunction: lfunc)
			/* Set the new observer to observe value table */
			mValueTable.addObserver(newobs, forKeyPath: key, options: [.new], context: nil)
		}
	}

	public func countOfObservers(forKey key: String) -> Int {
		if let listner = mObservers[key] {
			return listner.count()
		} else {
			return 0
		}
	}

	public func removeObserver(forKey key: String){
		if let obs = mObservers[key] {
			mValueTable.removeObserver(obs, forKeyPath: key)
			mObservers.removeValue(forKey: key)
		}
	}
}

private class CNListener: NSObject
{
	private var mListnerFunctions:		Array<CNObservedValueTable.ListenerFunction>

	public override init(){
		mListnerFunctions = []
	}

	public func count() -> Int {
		return mListnerFunctions.count
	}

	public func add(listenerFunction lfunc: @escaping CNObservedValueTable.ListenerFunction){
		mListnerFunctions.append(lfunc)
	}

	public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		for lfunc in mListnerFunctions {
			if let vals = change {
				lfunc(vals[.newKey])
			} else {
				lfunc(nil)
			}
		}
	}
}

