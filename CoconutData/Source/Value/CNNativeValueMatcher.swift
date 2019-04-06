/*
 * @file	CNNativeValueMatcher.swift
 * @brief	Define CNNativeValueMatcher class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public class CNNativeValueMatcher: CNNativeValueVisitor
{
	private var mNameExpression:	NSRegularExpression?
	private var mValueExpression:	NSRegularExpression?
	private var mValueString:	String?

	public required init(nameExpression nexp: NSRegularExpression?, valueExpression vexp: NSRegularExpression?){
		mNameExpression		= nexp
		mValueExpression	= vexp
		mValueString		= nil
	}

	public func match(value val: CNNativeValue) -> (String, String)? {
		if let dict = val.toDictionary() {
			for (key, value) in dict {
				mValueString = nil
				if doesMatch(regularExpression: mNameExpression, string: key) {
					self.accept(value: value)
					if let valstr = mValueString {
						if doesMatch(regularExpression: mValueExpression, string: valstr) {
							return (key, valstr)
						}
					}
				}
			}
		}
		return nil
	}

	private func doesMatch(regularExpression regexp: NSRegularExpression?, string str: String) -> Bool {
		if let rexp = regexp {
			let strrange = NSMakeRange(0, str.count)
			let matches  = rexp.matches(in: str, options: [], range: strrange)
			return matches.count > 0
		} else {
			return true
		}
	}

	open override func visitNill(){
		mValueString = nil
	}
	open override func visit(number obj: NSNumber){
		mValueString = obj.description(withLocale: nil)
	}
	open override func visit(string obj: String){
		mValueString = obj
	}
	open override func visit(date obj: Date){
		mValueString = obj.description
	}
	open override func visit(range obj: NSRange){
		mValueString = nil
	}
	open override func visit(point obj: CGPoint){
		mValueString = nil
	}
	open override func visit(size obj: CGSize){
		mValueString = nil
	}
	open override func visit(rect obj: CGRect){
		mValueString = nil
	}
	open override func visit(dictionary obj: Dictionary<String, CNNativeValue>){
		mValueString = nil
	}
	open override func visit(array obj: Array<CNNativeValue>){
		mValueString = nil
	}
	open override func visit(URL obj: URL) {
		mValueString = obj.absoluteString
	}
	open override func visit(image obj: CNImage) {
		mValueString = "\(obj.description)"
	}
	open override func visit(object obj: NSObject){
		mValueString = nil
	}
}



