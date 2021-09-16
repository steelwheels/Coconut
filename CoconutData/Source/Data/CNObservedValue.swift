/**
 * @file	CNObserver.swift
 * @brief	Define CNObserver and CNObservedTable class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNObserverDictionary
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
			if let result = Array(mValueTable.allKeys) as? Array<String> {
				return result
			} else {
				CNLog(logLevel: .error, message: "", atFunction: #function, inFile: #file)
				return []
			}
		}
	}

	public func setValue(_ val: NSObject, forKey key: String){
		mValueTable.setValue(val, forKey: key)
	}

	public func value(forKey k: String) -> NSObject? {
		if let obj =  mValueTable.value(forKey: k) as? NSObject {
			return obj
		} else {
			return nil
		}
	}

	public func setBooleanValue(_ bval: Bool, forKey key: String){
		let bobj = NSNumber(booleanLiteral: bval)
		setValue(bobj, forKey: key)
	}

	public func booleanValue(forKey key: String) -> Bool? {
		if let obj = value(forKey: key) as? NSNumber {
			return obj.boolValue
		} else {
			return nil
		}
	}

	public func addObserver(forKey key: String, listnerFunction lfunc: @escaping ListenerFunction){
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

public class CNObserverArray
{
	public typealias ListenerFunction = (Any?) -> Void	// new-value

	private var mValueTable:	NSMutableDictionary
	private var mObservers:		Dictionary<String, CNListener>

	public init(){
		mValueTable	= NSMutableDictionary(capacity: 32)
		mObservers 	= [:]
	}

	deinit {
		for key in mObservers.keys {
			if let observer = mObservers[key] {
				mValueTable.removeObserver(observer, forKeyPath: key)
			}
		}
	}

	private func indexToKey(index idx: Int) -> String {
		return "\(idx)"
	}

	public var count: Int {
		get { return mValueTable.count }
	}

	public func setValue(_ val: NSObject, forIndex idx: Int){
		let key = indexToKey(index: idx)
		mValueTable.setValue(val, forKey: key)
	}

	public func value(forIndex idx: Int) -> NSObject? {
		let key = indexToKey(index: idx)
		if let obj =  mValueTable.value(forKey: key) as? NSObject {
			return obj
		} else {
			return nil
		}
	}

	public func setBooleanValue(_ bval: Bool, forIndex idx: Int){
		let bobj = NSNumber(booleanLiteral: bval)
		setValue(bobj, forIndex: idx)
	}

	public func booleanValue(forIndex idx: Int) -> Bool? {
		if let obj = value(forIndex: idx) as? NSNumber {
			return obj.boolValue
		} else {
			return nil
		}
	}

	public func addObserver(forIndex idx: Int, listnerFunction lfunc: @escaping ListenerFunction){
		let key = indexToKey(index: idx)
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

	public func countOfObservers(forIndex idx: Int) -> Int {
		let key = indexToKey(index: idx)
		if let listner = mObservers[key] {
			return listner.count()
		} else {
			return 0
		}
	}

	public func removeObserver(forIndex idx: Int){
		let key = indexToKey(index: idx)
		if let obs = mObservers[key] {
			mValueTable.removeObserver(obs, forKeyPath: key)
			mObservers.removeValue(forKey: key)
		}
	}
}


private class CNListener: NSObject
{
	public typealias ListenerFunction = (Any?) -> Void	// new-value

	private var mListnerFunctions:		Array<ListenerFunction>

	public override init(){
		mListnerFunctions = []
	}

	public func count() -> Int {
		return mListnerFunctions.count
	}

	public func add(listenerFunction lfunc: @escaping ListenerFunction){
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

