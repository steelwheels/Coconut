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
	let resource = CNResource(baseURL: baseurl, console: cons)

	resource.set(resourceName: "number", loader: {
		(_ url: URL) -> AnyObject? in
		cons.print(string: "Load resource for \(url.absoluteString)\n")
		return NSNumber(value: 1.23)
	})

	resource.set(resourceName: "number", identifier: "ident0", localPath: "a.num")

	var result = true
	if let res = resource.load(resourceName: "number", identifier: "ident0") as? NSNumber {
		console.print(string: "[OK] Loaded => \(res.doubleValue)\n")
	} else {
		console.print(string: "[Error] Can not load resource0\n")
		result = false
	}

	return result
}
