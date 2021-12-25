/*
 * @file	CNValueCache.swift
 * @brief	Define CNValueCache class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public class CNValueCache
{
	public typealias Result = CNValueParser.Result

	private var mRootURL:		URL
	private var mRootValue:		CNValue
	private var mParentCache:	CNValueCache?

	public init(root rooturl: URL, parentCache pc: CNValueCache?) {
		mRootURL	= rooturl
		mRootValue	= .nullValue
		mParentCache	= pc
	}

	public func load(relativePath rpath: String) -> Result {
		let url = mRootURL.appendingPathComponent(rpath, isDirectory: false)
		guard let ctxt = url.loadContents() else {
			let err = NSError.fileError(message: "Failed to read file from \(url.path)")
			return .error(err)
		}
		let parser = CNValueParser()
		let result: Result
		switch parser.parse(source: ctxt as String) {
		case .ok(let val):
			result = load(value: val)
		case .error(let err):
			result = .error(err)
		}
		return result
	}

	public func load(value val: CNValue) -> Result {
		mRootValue = val
		return .ok(val)
	}

	public func value(forPath path: Array<String>) -> CNValue? {
		return value(forPath: path, in: mRootValue, fullPath: path)
	}

	private func value(forPath path: Array<String>, in source: CNValue, fullPath fpath: Array<String>) -> CNValue? {
		guard path.count > 0 else {
			return nil
		}
		if path.count > 1 {
			if let nxtval = value(forProperty: path[0], in: source, fullPath: fpath) {
				let nxtpath: Array<String> = Array(path.dropFirst())
				return value(forPath: nxtpath, in: nxtval, fullPath: fpath)
			} else {
				return nil
			}
		} else {
			return value(forProperty: path[0], in: source, fullPath: fpath)
		}
	}

	private func value(forProperty property: String, in source: CNValue, fullPath fpath: Array<String>) -> CNValue? {
		if let dict = source.toDictionary() {
			if let prop = dict[property] {
				switch prop {
				case .reference(let refval):
					if let val = refval.load(from: mRootURL) {
						return val
					} else {
						return nil
					}
				case .nullValue, .boolValue(_), .numberValue(_), .stringValue(_),
				     .dateValue(_), .rangeValue(_), .pointValue(_), .sizeValue(_), .rectValue(_),
				     .enumValue(_), .dictionaryValue(_), .arrayValue(_), .URLValue(_), .colorValue(_),
				     .imageValue(_), .objectValue(_):
					return prop
				}
			} else {
				if let parent = mParentCache {
					return parent.value(forPath: fpath)
				} else {
					return nil
				}
			}
		} else {
			return nil
		}
	}
}


