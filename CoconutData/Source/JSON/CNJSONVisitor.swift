/*
 * @file	CNJSONTraverser.swift
 * @brief	Define CNJSONTraverser class
 * @par Copyright
 *   Copyright (C) 2017-2018 Steel Wheels Project
 */

import Foundation

open class CNJSONVisitor
{
	public func accept(name nm: NSString, anyObject obj: Any?){
		if let array = obj as? NSArray {
			visit(name: nm, array: array)
		} else if let dict = obj as? NSDictionary {
			visit(name: nm, dictionary: dict)
		} else if let num = obj as? NSNumber {
			visit(name: nm, number: num)
		} else if let str = obj as? NSString {
			visit(name: nm, string: str)
		} else if let null = obj as? NSNull {
			visit(name: nm, null: null)
		} else {
			NSLog("Unacceptacble object: \(String(describing: obj))")
		}
	}

	open func visit(name nm: NSString, array arr: NSArray){
	}

	open func visit(name nm: NSString, dictionary dict: NSDictionary){
	}

	open func visit(name nm: NSString, number num: NSNumber){
	}

	open func visit(name nm: NSString, string str: NSString){
	}

	open func visit(name nm: NSString, null nul: NSNull){
	}
}

