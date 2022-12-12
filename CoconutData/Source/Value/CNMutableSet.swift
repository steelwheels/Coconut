/*
 * @file	CNMutableSetValue.swift
 * @brief	Define CNMutableSetValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNMutableSetValue: CNMutableArrayValue
{
	public override func _append(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		if let _ = path.first {
			return super._append(value: val, forPath: path, in: root)
		} else {
			let curvals = super.values
			let mval    = toMutableValue(from: val)
			let count   = curvals.count
			var added   = false
			loop: for i in 0..<count {
				let curval = curvals[i]
				switch CNCompareMutableValue(value0: mval, value1: curval) {
				case .orderedAscending:		// src < curvals[i]
					super.insert(value: mval, at: i)
					root.isDirty = true
					added = true
					break loop
				case .orderedSame:		// src == curvals[i]
					added = true
					break loop
				case .orderedDescending:	// src > curvals[i]
					break // continue
				}
			}
			if !added {
				super.append(value: mval)
				root.isDirty = true
			}
			return nil
		}
	}

	public override func clone() -> CNMutableValue {
		let result = CNMutableSetValue(sourceDirectory: self.sourceDirectory, cacheDirectory: self.cacheDirectory)
		for elm in super.values {
			result.append(value: elm.clone())
		}
		return result
	}

	public override func toValue() -> CNValue {
		var vals: Array<CNValue> = []
		for mval in self.values {
			vals.append(mval.toValue())
		}
		return .setValue(vals)
	}
}

