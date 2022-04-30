/**
 * @file	CNRecord.swift
 * @brief	Define CNRecord protocol
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public protocol CNRecord
{
	var fieldCount: Int		{ get }
	var fieldNames: Array<String>	{ get }
	var index: Int			{ get }

	func value(ofField name: String) -> CNValue?
	func setValue(value val: CNValue, forField name: String) -> Bool

	func toValue() -> Dictionary<String, CNValue>

	func compare(forField name: String, with rec: CNRecord) -> ComparisonResult
}

