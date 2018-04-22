/*
 * @file	CNJSONMatcher.swift
 * @brief	Define CNJSONMatcher class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNJSONMatcher: CNJSONVisitor
{
	private var mNameExpression:	NSRegularExpression?
	private var mValueExpression:	NSRegularExpression?
	private var mResult:		Bool

	public init(nameExpression nexp: NSRegularExpression?, valueExpression vexp: NSRegularExpression?){
		mNameExpression		= nexp
		mValueExpression	= vexp
		mResult			= false
	}

	public func match(name nm: NSString, anyObject obj: Any?) -> Bool {
		super.accept(name: nm, anyObject: obj)
		return mResult
	}

	open override func visit(name nm: NSString, array arr: NSArray){
		if mValueExpression == nil {
			tryMatch(name: nm, string: nil)
		} else {
			/* Never match */
			mResult = false
		}
	}

	open override func visit(name nm: NSString, dictionary dict: NSDictionary){
		if mValueExpression == nil {
			tryMatch(name: nm, string: nil)
		} else {
			/* Never match */
			mResult = false
		}
	}

	open override func visit(name nm: NSString, number num: NSNumber){
		tryMatch(name: nm, string: NSString(string: num.description))
	}

	open override func visit(name nm: NSString, string str: NSString){
		tryMatch(name: nm, string: str)
	}

	open override func visit(name nm: NSString, null nul: NSNull){
		tryMatch(name: nm, string: nil)
	}

	private func tryMatch(name nm: NSString, string str: NSString?){
		if let nexp = mNameExpression {
			if !doesMatch(regularExpression: nexp, string: nm) {
				mResult = false
				return
			}
		}
		if let vexp = mValueExpression, let strval = str {
			if !doesMatch(regularExpression: vexp, string: strval) {
				mResult = false
				return
			}
		}
		mResult = true
	}

	private func doesMatch(regularExpression regexp: NSRegularExpression, string str: NSString) -> Bool {
		let strrange = NSMakeRange(0, str.length)
		let matches  = regexp.matches(in: str as String, options: [], range: strrange)
		return matches.count > 0
	}
}

