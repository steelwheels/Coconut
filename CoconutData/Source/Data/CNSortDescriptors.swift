/**
 * @file	CNSortDescriptors.swift
 * @brief	Define CNSortDescriptors class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNSortDescriptors
{
	public struct SortDescriptor {
		public var key:	String
		public var ascending:	Bool

		public init(key kstr: String, ascending asc: Bool){
			key	  = kstr
			ascending = asc
		}
	}

	private var mSortDescriptors: Array<SortDescriptor>

	public var descriptors: Array<SortDescriptor> {
		get { return mSortDescriptors }
	}

	public init(){
		mSortDescriptors = []
	}

	public func add(key kstr: String, ascending asc: Bool) {
		/* Copy current descriptors */
		var newdescs: Array<SortDescriptor> = []
		for desc in mSortDescriptors {
			if desc.key != kstr {
				newdescs.append(desc)
			}
		}
		newdescs.append(SortDescriptor(key: kstr, ascending: asc))
		/* Replace current descriptor */
		mSortDescriptors = newdescs
	}

	public func ascending(for key: String) -> Bool? {
		for desc in mSortDescriptors {
			if desc.key == key {
				return desc.ascending
			}
		}
		return nil
	}

	public func sort<T>(source src: Array<T>, comparator comp: (_ s0: T, _ s1: T, _ key: String) -> ComparisonResult) -> Array<T> {
		var arr = src
		for desc in mSortDescriptors {
			arr = arr.sorted(by: {
				(_ s0: T, _ s1: T) -> Bool in
				let result: Bool
				switch comp(s0, s1, desc.key) {
				case .orderedAscending:	 result =  desc.ascending
				case .orderedDescending: result = !desc.ascending
				case .orderedSame:       result = false
				}
				return result
			})
		}
		return arr
	}

	public func toText() -> CNTextSection {
		let sect = CNTextSection()
		sect.header = "sort-descriptors: {"
		sect.footer = "}"
		for desc in mSortDescriptors {
			let line = CNTextLine(string: "{key: \(desc.key), ascend:\(desc.ascending)}")
			sect.add(text: line)
		}
		return sect
	}

}

