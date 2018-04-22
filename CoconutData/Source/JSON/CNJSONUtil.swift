/*
 * @file	CNJSONUtil.swift
 * @brief	Define CNJSONUtil class
 * @par Copyright
 *   Copyright (C) 2017-2018 Steel Wheels Project
 */

import Foundation

public class CNJSONUtil
{
	public class func merge(destination dst: inout CNJSONObject, source src: CNJSONObject){
		switch dst {
		case .Array(let dstarr):
			switch src {
			case .Array(let srcarr):
				var newarr = NSMutableArray(array: dstarr)
				merge(destinationArray: &newarr, sourceArray: srcarr)
				dst = CNJSONObject(array: newarr)
			case .Dictionary(_):
				NSLog("Invalid combination")
			}
		case .Dictionary(let dstdict):
			switch src {
			case .Array(_):
				NSLog("Invalid combination")
			case .Dictionary(let srcdict):
				var newdict = NSMutableDictionary(dictionary: dstdict)
				merge(destinationDictionary: &newdict, sourceDictionary: srcdict)
				dst = CNJSONObject(dictionary: newdict)
			}
		}
	}

	private class func merge(destinationDictionary dst: inout NSMutableDictionary, sourceDictionary src: NSDictionary){
		for srckey in src.allKeys {
			if let keystr = srckey as? String {
				if let srcval = src.value(forKey: keystr) {
					merge(destinationDictionary: &dst, sourceKey: keystr, sourceValue: srcval)
				} else {
					NSLog("Internal error: key \(keystr)")
				}
			} else {
				NSLog("Internal error: key \(srckey)")
			}
		}
	}

	private class func merge(destinationDictionary dst: inout NSMutableDictionary, sourceKey srckey: String, sourceValue srcval: Any){
		if let dstval = dst[srckey] {
			if var dstinfo = dstval as? NSMutableDictionary, let srcinfo = srcval as? NSDictionary {
				/* merge children */
				merge(destinationDictionary: &dstinfo, sourceDictionary: srcinfo)
			} else if var dstarr = dstval as? Array<Any>, let srcarr = srcval as? Array<Any> {
				/* merge array */
				dstarr.append(contentsOf: srcarr)
			} else {
				/* Replace value */
				dst[srckey] = srcval
			}
		} else {
			/* add as new value */
			dst[srckey] = srcval
		}
	}

	private class func merge(destinationArray dst: inout NSMutableArray, sourceArray src: NSArray){
		for srcelm in src {
			dst.add(srcelm)
		}
	}
}

