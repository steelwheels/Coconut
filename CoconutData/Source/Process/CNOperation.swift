/**
 * @file	CNOperation.swift
 * @brief	Define CNOperation class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

open class CNOperation: Operation
{
	public typealias MainFunction     = () -> Void
	public typealias ListenerFunction = CNObservedValueTable.ListenerFunction

	public static let isExecutingItem	= "isExecuting"
	public static let isFinishedItem	= "isFinished"
	public static let isCanceledItem	= "isCanceled"

	public  var mainFunction	: MainFunction?
	private var mObservedValueTable	: CNObservedValueTable

	public override init() {
		mainFunction	    = nil
		mObservedValueTable = CNObservedValueTable()
		super.init()
		reset()
	}

	deinit {
		mObservedValueTable.removeObserver(forKey: CNOperation.isExecutingItem)
		mObservedValueTable.removeObserver(forKey: CNOperation.isFinishedItem)
		mObservedValueTable.removeObserver(forKey: CNOperation.isCanceledItem)
	}

	public func reset(){
		mObservedValueTable.setBooleanValue(false, forKey: CNOperation.isExecutingItem)
		mObservedValueTable.setBooleanValue(false, forKey: CNOperation.isFinishedItem)
		mObservedValueTable.setBooleanValue(false, forKey: CNOperation.isCanceledItem)
	}

	open override var isExecuting: Bool {
		get {
			return mObservedValueTable.booleanValue(forKey: CNOperation.isExecutingItem)
		}
		set(val) {
			mObservedValueTable.setBooleanValue(val, forKey: CNOperation.isExecutingItem)
		}
	}

	open override var isFinished: Bool {
		get {
			return mObservedValueTable.booleanValue(forKey: CNOperation.isFinishedItem)
		}
		set(val) {
			mObservedValueTable.setBooleanValue(val, forKey: CNOperation.isFinishedItem)
		}
	}

	open override var isCancelled: Bool {
		get {
			return mObservedValueTable.booleanValue(forKey: CNOperation.isCanceledItem)
		}
		set(val){
			mObservedValueTable.setBooleanValue(val, forKey: CNOperation.isCanceledItem)
		}
	}

	open override func main() {
		isExecuting	= true
		isFinished	= false

		if !isCancelled {
			if let mainfunc = mainFunction {
				mainfunc()
			}
		}

		isExecuting	= false
		isFinished	= true
	}

	open override func cancel() {
		isCancelled = true
		super.cancel()
	}

	public func addIsExecutingListener(listnerFunction lfunc: @escaping CNObservedValueTable.ListenerFunction) {
		mObservedValueTable.setObserver(forKey: CNOperation.isExecutingItem, listnerFunction: lfunc)
	}

	public func addIsFinishedListener(listnerFunction lfunc: @escaping CNObservedValueTable.ListenerFunction) {
		mObservedValueTable.setObserver(forKey: CNOperation.isFinishedItem, listnerFunction: lfunc)
	}

	public func addIsCanceledListener(listnerFunction lfunc: @escaping CNObservedValueTable.ListenerFunction) {
		mObservedValueTable.setObserver(forKey: CNOperation.isCanceledItem, listnerFunction: lfunc)
	}
}

