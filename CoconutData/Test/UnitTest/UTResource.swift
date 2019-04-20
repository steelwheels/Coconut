/**
 * @file	UTResource.swift
 * @brief	Test function for CNResource class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testResource(console cons: CNConsole) -> Bool
{
	let baseurl  = URL(fileURLWithPath: "/tmp")
	let resource = CNResource(baseURL: baseurl)

	resource.allocate(category: "Number", loader: {
		(_ url: URL) -> Any? in
		cons.print(string: "Load resource for \(url.absoluteString)\n")
		return NSNumber(value: 1.23)
	})
	resource.add(category: "Number", identifier: "number0", path: "a.num")

	var result = true
	if let res: NSNumber = resource.load(category: "Number", identifier: "number0", index: 0) {
		cons.print(string: "[OK] Loaded => \(res.doubleValue)\n")
	} else {
		cons.print(string: "[Error] Can not load resource0\n")
		result = false
	}

	return result
}
