/*
 * @file	CNJSONGrep.swift
 * @brief	Define CNJSONGrep class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

open class CNJSONGrep
{
	private var mKeyExpression:	NSRegularExpression?
	private var mValueExpression:	NSRegularExpression?

	public init(keyExpression kexp: NSRegularExpression?, valueExpression vexp: NSRegularExpression?){
		mKeyExpression		= kexp
		mValueExpression	= vexp
	}

	public func execute(JSONObject obj: CNJSONObject) -> CNJSONObject? {
		switch obj {
		case .Array(let srcarr):
			if let newarr = execute(array: srcarr) {
				return CNJSONObject(array: newarr)
			} else {
				return nil
			}
		case .Dictionary(let srcdict):
			if let newdict = execute(dictionary: srcdict) {
				return CNJSONObject(dictionary: newdict)
			} else {
				return nil
			}
		}
	}

	private func execute(array arr: NSArray) -> NSArray? {
		let newarray = NSMutableArray(capacity: 8)
		for elm in arr {
			if let elmobj = elm as? NSObject {
				if let newelm = execute(object: elmobj) {
					newarray.add(newelm)
				}
			} else {
				NSLog("Unacceptable object")
			}
		}
		if newarray.count > 0 {
			return newarray
		} else {
			return nil
		}
	}

	private func execute(dictionary dict: NSDictionary) -> NSDictionary? {
		let newdict = NSMutableDictionary(capacity: 8)
		var matched = false
		for (key, val) in dict {
			if let keystr = key as? NSString, let valobj = val as? NSObject {
				let (newkey, newval) = execute(key: keystr, value: valobj)
				if let nkey = newkey, let nval = newval {
					newdict.setValue(nval, forKey: nkey as String)
					matched = true
				} else {
					newdict.setValue(val, forKey: keystr as String)
				}
			} else {
				NSLog("Unacceptable object")
			}
		}
		if matched {
			return newdict
		} else {
			return nil
		}
	}

	private func execute(object obj: NSObject) -> NSObject? {
		if let arr = obj as? NSArray {
			return execute(array: arr)
		} else if let dict = obj as? NSDictionary {
			return execute(dictionary: dict)
		} else {
			NSLog("Unacceptable object")
			return nil
		}
	}

	private func execute(key keystr: NSString, value val: NSObject) -> (NSString?, NSObject?) {
		if let arrval = val as? NSArray {
			if let newarr = execute(array: arrval) {
				return (keystr, newarr)
			}
		} else if let dictval = val as? NSDictionary {
			if let newdict = execute(dictionary: dictval) {
				return (keystr, newdict)
			}
		} else {
			let matcher = CNJSONMatcher(nameExpression: mKeyExpression, valueExpression: mValueExpression)
			if matcher.match(name: keystr, anyObject: val) {
				return (keystr, val)
			}
		}
		return (nil, nil)
	}
}

