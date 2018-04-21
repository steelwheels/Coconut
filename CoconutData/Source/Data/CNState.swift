/*
 * @file	CNState.h
 * @brief	Define CNState class
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
 */

import Foundation

/**
   The data object to present the state of the object
 */
open class CNState : NSObject
{
	/** Parent state  */
	public weak var parentState: CNState? = nil

	/** The updated count */
	@objc private dynamic var mStateId = 0
	/** Lock to single access for mStateId */
	private var mStateIdLock = NSLock()
	/** The factor update this state */
	public var factorValue: Int = 0

	/**
	  Add observer object of this state
	  - Parameter observer: Observer object
	 */
	public func add(stateObserver obs: NSObject){
		self.addObserver(obs, forKeyPath: CNState.stateKey, options: .new, context: nil)
	}
	
	/**
	  Stop the object to observe this state
	  - Parameter observer: Object to stop observing this state
	 */
	public func remove(stateObserver obs: NSObject){
		self.removeObserver(obs, forKeyPath: CNState.stateKey)
	}
	
	/**
	  Increment the update count. This method will be called 
	 */
	public func updateState(factorValue fv: Int) -> Void {
		mStateIdLock.lock()
			factorValue = fv
			self.mStateId += 1
		mStateIdLock.unlock()
	}
	
	public static var stateKey: String {
		get{ return "mStateId" }
	}
}
