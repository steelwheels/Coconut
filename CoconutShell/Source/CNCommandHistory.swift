/*
 * @file	CNCommandHistory.swift
 * @brief	Define CNCommandHistory class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNCommandHistory {
	public static let shared	= CNCommandHistory()

	public var history: Array<String>

	public init(){
		history = []
	}
}
