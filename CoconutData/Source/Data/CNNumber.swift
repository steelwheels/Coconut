/**
 * @file	CNNumber.swift
 * @brief	Define CNNumber class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public extension NSNumber
{
	/* Reference: https://zenn.dev/t0_inoue/articles/2de0edd38f58ad */
	var hasBoolValue: Bool { get {
		let boolID = CFBooleanGetTypeID()
		let numID  = CFGetTypeID(self)
		return numID == boolID
	}}
}
