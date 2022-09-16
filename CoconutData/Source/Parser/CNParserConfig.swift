/**
 * @file	CNParser.swift
 * @brief	Define CNParser class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public struct CNParserConfig
{
	private var mAllowIdentiferHasPeriod	: Bool

	public init(allowIdentiferHasPeriod allowp: Bool){
		mAllowIdentiferHasPeriod = allowp
	}

	public init(){
		self.init(allowIdentiferHasPeriod: false)
	}

	public var allowIdentiferHasPeriod: Bool { get { return mAllowIdentiferHasPeriod	}}
}
