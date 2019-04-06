/*
 * @file	CNNativeValueSelector.swift
 * @brief	Define CNNativeValueSelector class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNNativeValueSelector: CNNativeValueVisitor
{
	private var mMatcher:		CNNativeValueMatcher
	private var mResult:		CNNativeValue?

	public required init(nameExpression nexp: NSRegularExpression?, valueExpression vexp: NSRegularExpression?){
		mMatcher = CNNativeValueMatcher(nameExpression: nexp, valueExpression: vexp)
		mResult	 = nil
	}

	public func select(value val: CNNativeValue) -> CNNativeValue? {
		mResult = nil
		accept(value: val)
		return mResult
	}

	open override func visitNill(){
		mResult = nil
	}
	open override func visit(number obj: NSNumber){
		mResult = nil
	}
	open override func visit(string obj: String){
		mResult = nil
	}
	open override func visit(date obj: Date){
		mResult = nil
	}
	open override func visit(range obj: NSRange){
		mResult = nil
	}
	open override func visit(point obj: CGPoint){
		mResult = nil
	}
	open override func visit(size obj: CGSize){
		mResult = nil
	}
	open override func visit(rect obj: CGRect){
		mResult = nil
	}
	open override func visit(URL obj: URL){
		mResult = nil
	}
	open override func visit(image obj: CNImage){
		mResult = nil
	}
	open override func visit(dictionary obj: Dictionary<String, CNNativeValue>){
		let srcval = CNNativeValue.dictionaryValue(obj)
		if let _ = mMatcher.match(value: srcval) {
			mResult = srcval
		} else {
			var newdict: Dictionary<String, CNNativeValue> = [:]
			for (key, val) in obj {
				accept(value: val)
				if let res = mResult {
					newdict[key] = res
				}
			}
			mResult = newdict.count > 0 ? .dictionaryValue(newdict) : nil
		}
	}
	open override func visit(array obj: Array<CNNativeValue>){
		var newarr: Array<CNNativeValue> = []
		for val in obj {
			accept(value: val)
			if let res = mResult {
				newarr.append(res)
			}
		}
		mResult = newarr.count > 0 ? .arrayValue(newarr) : nil
	}
	open override func visit(object obj: NSObject){
		mResult = nil
	}

}

