/**
 * @file	CNOperationContext.swift
 * @brief	Define CNOperationContext class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

@objc open class CNOperationContext: NSObject
{
	public static let isExecutingItem	= "isExecuting"
	public static let isFinishedItem	= "isFinished"
	public static let isCanceledItem	= "isCanceled"

	private var mObservedValueTable:	CNObservedValueTable
	private var mParameters:		Dictionary<String, CNNativeValue>
	private var mConsole:			CNFileConsole

	public weak var ownerExecutor: 		CNOperationExecutor?

	public var console:    CNFileConsole		{ get { return mConsole 		}}

	public var 	executionCount:		Int
	public var	totalExecutionTime:	TimeInterval	/* [ms] */

	public init(input ifile: CNFile, output ofile: CNFile, error efile: CNFile) {
		mObservedValueTable = CNObservedValueTable()
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

	public func reset(){
		mObservedValueTable.setBooleanValue(false, forKey: CNOperationContext.isExecutingItem)
		mObservedValueTable.setBooleanValue(false, forKey: CNOperationContext.isFinishedItem)
		mObservedValueTable.setBooleanValue(false, forKey: CNOperationContext.isCanceledItem)
	}

	public func addIsExecutingListener(listnerFunction lfunc: @escaping CNObservedValueTable.ListenerFunction) {
		mObservedValueTable.addObserver(forKey: CNOperationContext.isExecutingItem, listnerFunction: lfunc)
	}

	public func addIsFinishedListener(listnerFunction lfunc: @escaping CNObservedValueTable.ListenerFunction) {
		mObservedValueTable.addObserver(forKey: CNOperationContext.isFinishedItem, listnerFunction: lfunc)
	}

	public func addIsCanceledListener(listnerFunction lfunc: @escaping CNObservedValueTable.ListenerFunction) {
		mObservedValueTable.addObserver(forKey: CNOperationContext.isCanceledItem, listnerFunction: lfunc)
	}

	open var isExecuting: Bool {
		get {
			if let val = mObservedValueTable.booleanValue(forKey: CNOperationContext.isExecutingItem) {
				return val
			} else {
				mConsole.error(string: "No isExecuting property")
				return false
			}
		}
		set(val) {
			mObservedValueTable.setBooleanValue(val, forKey: CNOperationContext.isExecutingItem)
		}
	}

	open var isFinished: Bool {
		get {
			if let val = mObservedValueTable.booleanValue(forKey: CNOperationContext.isFinishedItem) {
				return val
			} else {
				mConsole.error(string: "No isFinished property")
				return false
			}
		}
		set(val) {
			mObservedValueTable.setBooleanValue(val, forKey: CNOperationContext.isFinishedItem)
		}
	}

	open var isCancelled: Bool {
		get {
			if let val = mObservedValueTable.booleanValue(forKey: CNOperationContext.isCanceledItem) {
				return val
			} else {
				mConsole.error(string: "No isCancelled property")
				return false
			}
		}
		set(val){
			mObservedValueTable.setBooleanValue(val, forKey: CNOperationContext.isCanceledItem)
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

