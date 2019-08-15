/*
 * @file	CNConnector.swift
 * @brief	Define CNConnector class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNConnection
{
	public typealias ReceiverFunc = (_ str: String) -> Void

	private var mPipe: 		Pipe
	private var mReceiverFunc:	ReceiverFunc?

	public init(){
		mPipe     	= Pipe()
		mReceiverFunc 	= nil
		mPipe.fileHandleForReading.readabilityHandler = {
			[weak self] (_ handle: FileHandle) -> Void in
			if let str = String(data: handle.availableData, encoding: String.Encoding.utf8) {
				if let myself = self {
					if let recv = myself.mReceiverFunc {
						recv(str)
					}
				}
			} else {
				NSLog("Error decoding data: \(handle.availableData)")
			}
		}
	}

	deinit {
		mPipe.fileHandleForReading.readabilityHandler = nil
	}

	public var receiverFunction: ReceiverFunc? {
		get 		{ return mReceiverFunc }
		set(newfunc)	{ mReceiverFunc = newfunc }
	}

	public func send(string str: String){
		if let data = str.data(using: .utf8) {
			mPipe.fileHandleForWriting.write(data)
		} else {
			NSLog("Failed to convert data")
		}
	}
}

