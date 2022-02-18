/**
 * @file	CNOperationContext.swift
 * @brief	Define CNOperationContext class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

@objc open class CNOperationContext: NSObject
{
	public typealias ListnerHolder		= CNObserverDictionary.ListnerHolder

	public static let isExecutingItem	= "isExecuting"
	public static let isFinishedItem	= "isFinished"
	public static let isCanceledItem	= "isCanceled"

	private var mObserverDictionary:	CNObserverDictionary
	private var mObserverHolder:		Array<ListnerHolder>

	private var mParameters:		Dictionary<String, CNValue>
	private var mConsole:			CNFileConsole

	public weak var ownerExecutor: 		CNOperationExecutor?

	public var console:    CNFileConsole		{ get { return mConsole 		}}

	public var 	executionCount:		Int
	public var	totalExecutionTime:	TimeInterval	/* [ms] */

	public init(input ifile: CNFile, output ofile: CNFile, error efile: CNFile) {
		mObserverDictionary = CNObserverDictionary()
		mObserverHolder	    = []
		mParameters	    = [:]
		mConsole	    = CNFileConsole(input: ifile, output: ofile, error: efile)
		ownerExecutor	    = nil
		executionCount	    = 0
		totalExecutionTime  = 0.0
		super.init()
		reset()
	}

	deinit {
		ownerExecutor = nil
		for holder in mObserverHolder {
			mObserverDictionary.removeObserver(listnerHolder: holder)
		}
	}

	public func parameterNames() -> Array<String> {
		return Array(mParameters.keys)
	}

	open func setParameter(name nm: String, value val: CNValue){
		mParameters[nm] = val
	}

	open func parameter(name nm: String) -> CNValue? {
		return mParameters[nm]
	}

	public func reset(){
		mObserverDictionary.setBooleanValue(false, forKey: CNOperationContext.isExecutingItem)
		mObserverDictionary.setBooleanValue(false, forKey: CNOperationContext.isFinishedItem)
		mObserverDictionary.setBooleanValue(false, forKey: CNOperationContext.isCanceledItem)
	}

	public func addIsExecutingListener(listnerFunction lfunc: @escaping CNObserverDictionary.ListenerFunction) {
		let holder = mObserverDictionary.addObserver(forKey: CNOperationContext.isExecutingItem, listnerFunction: lfunc)
		mObserverHolder.append(holder)
	}

	public func addIsFinishedListener(listnerFunction lfunc: @escaping CNObserverDictionary.ListenerFunction) {
		let holder = mObserverDictionary.addObserver(forKey: CNOperationContext.isFinishedItem, listnerFunction: lfunc)
		mObserverHolder.append(holder)
	}

	public func addIsCanceledListener(listnerFunction lfunc: @escaping CNObserverDictionary.ListenerFunction) {
		let holder = mObserverDictionary.addObserver(forKey: CNOperationContext.isCanceledItem, listnerFunction: lfunc)
		mObserverHolder.append(holder)
	}

	open var isExecuting: Bool {
		get {
			if let val = mObserverDictionary.booleanValue(forKey: CNOperationContext.isExecutingItem) {
				return val
			} else {
				mConsole.error(string: "No isExecuting property")
				return false
			}
		}
		set(val) {
			mObserverDictionary.setBooleanValue(val, forKey: CNOperationContext.isExecutingItem)
		}
	}

	open var isFinished: Bool {
		get {
			if let val = mObserverDictionary.booleanValue(forKey: CNOperationContext.isFinishedItem) {
				return val
			} else {
				mConsole.error(string: "No isFinished property")
				return false
			}
		}
		set(val) {
			mObserverDictionary.setBooleanValue(val, forKey: CNOperationContext.isFinishedItem)
		}
	}

	open var isCancelled: Bool {
		get {
			if let val = mObserverDictionary.booleanValue(forKey: CNOperationContext.isCanceledItem) {
				return val
			} else {
				mConsole.error(string: "No isCancelled property")
				return false
			}
		}
		set(val){
			mObserverDictionary.setBooleanValue(val, forKey: CNOperationContext.isCanceledItem)
		}
	}

	open func main() {
		/* Execute user defined operation at the sub class */
	}

	public func cancel() {
		if let exec = ownerExecutor {
			exec.cancel()
		}
	}

	public func set(console cons: CNFileConsole) {
		mConsole	= cons
	}
}

