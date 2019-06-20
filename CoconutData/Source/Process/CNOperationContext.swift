/**
 * @file	CNOperationContext.swift
 * @brief	Define CNOperationContext class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

@objc open class CNOperationContext: NSObject, CNLogging
{
	public static let isExecutingItem	= "isExecuting"
	public static let isFinishedItem	= "isFinished"
	public static let isCanceledItem	= "isCanceled"

	private var mObservedValueTable:	CNObservedValueTable
	private var mParameters:		Dictionary<String, CNNativeValue>
	private var mConsole:			CNConsole

	public weak var ownerExecutor: 		CNOperationExecutor?

	public init(console cons: CNConsole) {
		mObservedValueTable = CNObservedValueTable()
		mParameters	    = [:]
		mConsole	    = cons
		ownerExecutor	    = nil
		super.init()
		reset()
	}

	deinit {
		ownerExecutor = nil
		mObservedValueTable.removeObserver(forKey: CNOperationContext.isExecutingItem)
		mObservedValueTable.removeObserver(forKey: CNOperationContext.isFinishedItem)
		mObservedValueTable.removeObserver(forKey: CNOperationContext.isCanceledItem)
	}

	public func parameterNames() -> Array<String> {
		return Array(mParameters.keys)
	}

	open func setParameter(name nm: String, value val: CNNativeValue){
		mParameters[nm] = val
	}

	open func parameter(name nm: String) -> CNNativeValue? {
		return mParameters[nm]
	}

	public var console: CNConsole? {
		get {
			return mConsole
		}
		set(newcons){
			if let cons = newcons {
				mConsole = cons
			}
		}
	}

	public func reset(){
		mObservedValueTable.setBooleanValue(false, forKey: CNOperationContext.isExecutingItem)
		mObservedValueTable.setBooleanValue(false, forKey: CNOperationContext.isFinishedItem)
		mObservedValueTable.setBooleanValue(false, forKey: CNOperationContext.isCanceledItem)
	}

	public func addIsExecutingListener(listnerFunction lfunc: @escaping CNObservedValueTable.ListenerFunction) {
		mObservedValueTable.setObserver(forKey: CNOperationContext.isExecutingItem, listnerFunction: lfunc)
	}

	public func addIsFinishedListener(listnerFunction lfunc: @escaping CNObservedValueTable.ListenerFunction) {
		mObservedValueTable.setObserver(forKey: CNOperationContext.isFinishedItem, listnerFunction: lfunc)
	}

	public func addIsCanceledListener(listnerFunction lfunc: @escaping CNObservedValueTable.ListenerFunction) {
		mObservedValueTable.setObserver(forKey: CNOperationContext.isCanceledItem, listnerFunction: lfunc)
	}

	open var isExecuting: Bool {
		get {
			return mObservedValueTable.booleanValue(forKey: CNOperationContext.isExecutingItem)
		}
		set(val) {
			mObservedValueTable.setBooleanValue(val, forKey: CNOperationContext.isExecutingItem)
		}
	}

	open var isFinished: Bool {
		get {
			return mObservedValueTable.booleanValue(forKey: CNOperationContext.isFinishedItem)
		}
		set(val) {
			mObservedValueTable.setBooleanValue(val, forKey: CNOperationContext.isFinishedItem)
		}
	}

	open var isCancelled: Bool {
		get {
			return mObservedValueTable.booleanValue(forKey: CNOperationContext.isCanceledItem)
		}
		set(val){
			mObservedValueTable.setBooleanValue(val, forKey: CNOperationContext.isCanceledItem)
		}
	}

	open func main() {
	}

	public func cancel() {
		if let exec = ownerExecutor {
			exec.cancel()
		}
	}
}

