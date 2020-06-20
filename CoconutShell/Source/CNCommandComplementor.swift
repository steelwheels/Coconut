/*
 * @file	CNCommandComplementer.swift
 * @brief	Define CNCommandComplementer class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public class CNCommandComplementor
{
	private var mIsComplementing:		Bool

	public var isComplementing: Bool { get { return mIsComplementing }}

	public init() {
		mIsComplementing = false
	}

	public func beginComplement(commandLine cmdline: String) {
		mIsComplementing = true
	}

	public func endComplement() {
		mIsComplementing = false
	}
}

