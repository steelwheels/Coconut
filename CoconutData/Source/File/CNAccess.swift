/**
 * @file	CNAccess.swift
 * @brief	Define CNAccess class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public enum CNAccessType
{
	case ReadOnlyAccess
	case WriteOnlyAccess
	case ReadWriteAccess

	public var isReadable: Bool {
		get {
			var result = false
			switch self {
			case .ReadOnlyAccess ,.ReadWriteAccess:
				result = true
			case .WriteOnlyAccess:
				result = false
			}
			return result
		}
	}

	public var isWritable: Bool {
		get {
			var result = false
			switch self {
			case .WriteOnlyAccess ,.ReadWriteAccess:
				result = true
			case .ReadOnlyAccess:
				result = false
			}
			return result
		}
	}
}

