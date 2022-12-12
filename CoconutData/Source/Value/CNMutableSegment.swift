/*
 * @file	CNMutableSegmentValue.swift
 * @brief	Define CNMutableSegmentValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNMutableValueSegment: CNMutableValue
{
	private var mSegmentValue: 	CNValueSegment
	private var mContext:		CNMutableValue?

	public init(value val: CNValueSegment, sourceDirectory srcdir: URL, cacheDirectory cachedir: URL){
		mSegmentValue 		= val

		mContext		= nil
		super.init(type: .segment, sourceDirectory: srcdir, cacheDirectory: cachedir)
	}

	public var context: CNMutableValue? { get { return mContext         }}

	public var sourceFile: URL { get {
		return self.sourceDirectory.appendingPathComponent(mSegmentValue.filePath)
	}}
	public var cacheFile: URL { get {
		return self.cacheDirectory.appendingPathComponent(mSegmentValue.filePath)
	}}
	public var script: String { get {
		return self.toValue().script
	}}

	public override func _value(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> Result<CNMutableValue?, NSError> {
		let result: Result<CNMutableValue?, NSError>
		switch load() {
		case .success(let mval):
			result = mval._value(forPath: path, in: root)
		case .failure(let err):
			result = .failure(err)
		}
		return result
	}

	public override func _set(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		let result: NSError?
		switch load() {
		case .success(let mval):
			result = mval._set(value: val, forPath: path, in: root)
		case .failure(let err):
			result = err
		}
		return result
	}

	public override func _append(value val: CNValue, forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		let result: NSError?
		switch load() {
		case .success(let mval):
			result = mval._append(value: val, forPath: path, in: root)
		case .failure(let err):
			result = err
		}
		return result
	}

	public override func _delete(forPath path: Array<CNValuePath.Element>, in root: CNMutableValue) -> NSError? {
		let result: NSError?
		switch load() {
		case .success(let mval):
			result = mval._delete(forPath: path, in: root)
		case .failure(let err):
			result = err
		}
		return result
	}

	public func load() -> Result<CNMutableValue, NSError> {
		let result: Result<CNMutableValue, NSError>
		if let ctxt = mContext {
			result = .success(ctxt)
		} else {
			if let src = mSegmentValue.load(fromSourceDirectory: self.sourceDirectory, cacheDirectory: self.cacheDirectory) {
				let ctxt = toMutableValue(from: src)
				mContext = ctxt
				result = .success(ctxt)
			} else {
				result = .failure(NSError.parseError(message: "Failed to load: source=\(self.sourceFile.path) cache=\(self.cacheFile.path)"))
			}
		}
		return result
	}

	public override func _search(name nm: String, value val: String, in root: CNMutableValue) -> Result<Array<CNValuePath.Element>?, NSError> {
		let result: Result<Array<CNValuePath.Element>?, NSError>
		switch load() {
		case .success(let mval):
			result = mval._search(name: nm, value: val, in: root)
		case .failure(let err):
			result = .failure(err)
		}
		return result
	}

	public override func _makeLabelTable(property name: String, path pth: Array<CNValuePath.Element>) -> Dictionary<String, Array<CNValuePath.Element>> {
		switch load() {
		case .success(let mval):
			return mval._makeLabelTable(property: name, path: pth)
		case .failure(let err):
			CNLog(logLevel: .error, message: "Error: \(err.toString())", atFunction: #function, inFile: #file)
			return [:]
		}
	}

	public override func clone() -> CNMutableValue {
		return CNMutableValueSegment(value: mSegmentValue, sourceDirectory: self.sourceDirectory, cacheDirectory: self.cacheDirectory)
	}

	public override func toValue() -> CNValue {
		return .dictionaryValue(mSegmentValue.toValue())
	}
}

