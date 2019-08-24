/**
 * @file	CNShellEnvironment.swift
 * @brief	Define CNShellEnvironment class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNShellEnvironment
{
	private var mEnvironment:	Dictionary<String, CNNativeValue>

	public init(){
		mEnvironment = [:]
	}

	public func set(name nm: String, value val: CNNativeValue){
		mEnvironment[nm] = val
	}

	public func get(name nm: String) -> CNNativeValue? {
		return mEnvironment[nm]
	}
}

