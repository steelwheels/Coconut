/*
 * @file	CNJSON.swift
 * @brief	Define CNJSON class
 * @par Copyright
 *   Copyright (C) 2017-2018 Steel Wheels Project
 */

import Foundation

public enum CNJSONObject
{
	case Dictionary(dictionary: NSDictionary)
	case Array(array: NSArray)

	public init(dictionary dict: NSDictionary){
		self = .Dictionary(dictionary: dict)
	}

	public init(array arr: NSArray){
		self = .Array(array: arr)
	}

	public func toObject() -> NSObject {
		let result: NSObject
		switch self {
		case .Array(let array):		result = array
		case .Dictionary(let dict):	result = dict
		}
		return result
	}

	public var description: String {
		get {
			let result: String
			switch self {
			case .Array(let arr):		result = arr.description
			case .Dictionary(let dict):	result = dict.description
			}
			return result
		}
	}
}
