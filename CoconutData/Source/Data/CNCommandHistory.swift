/**
 * @file	CNCommandHistory.swift
 * @brief	Define CNCommandHistory class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public class CNCommandHistory
{
	public static var shared = CNCommandHistory()

	private var mHistory:	Array<String>

	public var history: Array<String> { get { return mHistory }}

	private init(){
		mHistory = []
	}

	public func set(history src: Array<String>){
		mHistory = src
	}
}
