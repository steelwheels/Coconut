/**
 * @file	CNSort.swift
 * @brief	Type definition of sorting
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public enum CNSortOrder: Int {
	case none		=  0	// No sort
	case increasing		= -1	// smaller first
	case decreasing		=  1	// bigger first

	public var description: String { get {
		let result: String
		switch self {
		case .none:		result = "none"
		case .increasing:	result = "increasing"
		case .decreasing:	result = "decreasing"
		}
		return result
	}}
}

