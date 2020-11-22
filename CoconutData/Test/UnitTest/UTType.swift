/**
 * @file	UTType.swift
 * @brief	Test function for CNThread class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation
import Cocoa

public func testType(console cons: CNFileConsole) -> Bool
{
	cons.print(string: "NSLayoutConstraint.Priority:\n")
	cons.print(string: " required:                   \(NSLayoutConstraint.Priority.required)\n")
	cons.print(string: " defaultHigh:                \(NSLayoutConstraint.Priority.defaultHigh)\n")
	cons.print(string: " dragThatCanResizeWindow:    \(NSLayoutConstraint.Priority.dragThatCanResizeWindow)\n")
	cons.print(string: " windowSizeStayPut:          \(NSLayoutConstraint.Priority.windowSizeStayPut)\n")
	cons.print(string: " dragThatCannotResizeWindow: \(NSLayoutConstraint.Priority.dragThatCannotResizeWindow)\n")
	cons.print(string: " defaultLow:                 \(NSLayoutConstraint.Priority.defaultLow)\n")
	cons.print(string: " fittingSizeCompression):    \(NSLayoutConstraint.Priority.fittingSizeCompression)\n")

	let result =    (NSLayoutConstraint.Priority.required.rawValue                   == 1000)
		     && (NSLayoutConstraint.Priority.defaultHigh.rawValue                ==  750)
		     && (NSLayoutConstraint.Priority.dragThatCanResizeWindow.rawValue    ==  510)
		     && (NSLayoutConstraint.Priority.windowSizeStayPut.rawValue          ==  500)
		     && (NSLayoutConstraint.Priority.dragThatCannotResizeWindow.rawValue ==  490)
		     && (NSLayoutConstraint.Priority.defaultLow.rawValue                 ==  250)
		     && (NSLayoutConstraint.Priority.fittingSizeCompression.rawValue     ==   50)

	return result
}

