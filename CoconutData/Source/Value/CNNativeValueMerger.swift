/*
 * @file	CNNativeValueMerger.swift
 * @brief	Define CNNativeValueMerger class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public class CNNativeValueMerger
{
	public func merge(_ s0: CNNativeValue, _ s1: CNNativeValue) -> CNNativeValue? {
		if let dict0 = s0.toDictionary(), let dict1 = s1.toDictionary() {
			return mergeDictionary(dict0, dict1)
		} else if let arr0 = s0.toArray(), let arr1 = s1.toArray() {
			return mergeArray(arr0, arr1)
		} else {
			return nil
		}
	}

	private func mergeDictionary(_ s0: Dictionary<String, CNNativeValue>, _ s1: Dictionary<String, CNNativeValue>) -> CNNativeValue? {
		var newdict = s0
		for key in s1.keys {
			if let elm0 = s0[key], let elm1 = s1[key] {
				if let newelm = merge(elm0, elm1) {
					newdict[key] = newelm
				} else {
					newdict[key] = elm1
				}
			} else {
				newdict[key] = s1[key]
			}
		}
		return CNNativeValue.dictionaryValue(newdict)
	}

	private func mergeArray(_ s0: Array<CNNativeValue>, _ s1: Array<CNNativeValue>) -> CNNativeValue? {
		var newarr = s0
		newarr.append(contentsOf: s1)
		return CNNativeValue.arrayValue(newarr)
	}
}

