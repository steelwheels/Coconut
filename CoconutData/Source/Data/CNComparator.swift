/**
 * @file	CNColmparator.swift
 * @brief	Define CNComparator class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public func CNCompare<T: Comparable>(_ s0: T, _ s1: T) -> ComparisonResult {
	if s0 < s1 {
		return .orderedAscending
	} else if s1 < s0 {
		return .orderedDescending
	} else {
		return .orderedSame
	}
}
