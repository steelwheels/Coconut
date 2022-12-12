/**
 * @file	CNComparison.swift
 * @brief	Define CNComparison class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNComparator
{
	public static func compare(bool0 s0: Bool, bool1 s1: Bool) -> ComparisonResult {
		let result: ComparisonResult
		if s0 == s1 {
			result = .orderedSame
		} else if s0 { // s0:true,  s1: false
			result = .orderedDescending
		} else {       // s0:false, s1: true
			result = .orderedAscending
		}
		return result
	}

	public static func compare(int0 s0: Int, int1 s1: Int) -> ComparisonResult {
		let result: ComparisonResult
		if s0 > s1 {
			result = .orderedDescending
		} else if s0 < s1 {
			result = .orderedAscending
		} else {
			result = .orderedSame
		}
		return result
	}

	public static func compare(float0 s0: CGFloat, float1 s1: CGFloat) -> ComparisonResult {
		let result: ComparisonResult
		if s0 > s1 {
			result = .orderedDescending
		} else if s0 < s1 {
			result = .orderedAscending
		} else {
			result = .orderedSame
		}
		return result
	}

	public static func compare(string0 s0: String, string1 s1: String) -> ComparisonResult {
		let result: ComparisonResult
		if s0 > s1 {
			result = .orderedDescending
		} else if s0 < s1 {
			result = .orderedAscending
		} else {
			result = .orderedSame
		}
		return result
	}
}

