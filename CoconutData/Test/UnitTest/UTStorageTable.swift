/**
 * @file	UTStorageTable.swift
 * @brief	Test function for CNStorageTable
 * @par Copyright
 *   Copyright (C) 2022  Steel Wheels Project
 */

import CoconutData
import Foundation

public func testStorageTable(console cons: CNConsole) -> Bool
{
	let storage = CNStorageTable.loadDummyTable()
	let rcnt    = storage.recordCount
	cons.print(string: "recordCount = \(rcnt)\n")
	return true
}

