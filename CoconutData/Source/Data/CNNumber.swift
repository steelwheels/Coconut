/**
 * @file	CNNumber.swift
 * @brief	Extend NSNumber class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

extension NSNumber
{
	/* Reference: https://zenn.dev/t0_inoue/articles/2de0edd38f58ad */
	public var isBoolean: Bool { get {
		let boolID = CFBooleanGetTypeID()
		let numID = CFGetTypeID(self)
		return numID == boolID
	}}
}
