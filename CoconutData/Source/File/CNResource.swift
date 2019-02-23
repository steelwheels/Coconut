/*
 * @file	CNResource.swift
 * @brief	Define CNResource class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

private class CNFileResource
{
	public typealias LoaderFunc = (_ url: URL) -> Any?

	private var	mBaseURL:	URL
	private var	mLoader:	LoaderFunc
	private var	mFileMap:	Dictionary<String, String> 	// Identifier, FilePath
	private var	mContents:	Dictionary<String, Any>		// Identifier, Data

	public init(baseURL url: URL, fileMap fmap: Dictionary<String, String>, loader ldr: @escaping LoaderFunc){
		mBaseURL	= url
		mFileMap	= fmap
		mLoader		= ldr
		mContents	= [:]
	}

	public func load(identifier ident: String) -> Any? {
		if let data = mContents[ident] {
			return data
		} else {
			if let url = fullPath(identifier: ident) {
				if let newdata = mLoader(url) {
					mContents[ident] = newdata
					return newdata
				}
			}
			return nil
		}
	}

	private func fullPath(identifier ident: String) -> URL? {
		if let path = mFileMap[ident] {
			return mBaseURL.appendingPathComponent(path)
		}
		return nil
	}

	public func add(fileMap fmap: Dictionary<String, String>) {
		for (key, value) in fmap {
			mFileMap[key] = value
		}
	}

	public func identifiers() -> Array<String> {
		return Array(mFileMap.keys)
	}

	public func toText() -> CNTextSection {
		let section = CNTextSection()
		section.header = "{" ; section.footer = "}"

		for (ident, path) in mFileMap {
			let member = CNTextLine(string: "\(ident): \(path)")
			section.add(text: member)
		}

		return section
	}
}

public class CNResource
{
	public typealias LoaderFunc =  (_ url: URL) -> Any?

	private var	mBaseURL:		URL
	private var 	mConsole:		CNConsole
	private var	mFileResources:		Dictionary<String, CNFileResource>

	public var baseURL: URL 	{ get { return mBaseURL 	}}
	
	public init(baseURL url: URL, console cons: CNConsole){
		mBaseURL	= url
		mConsole	= cons
		mFileResources	= [:]
	}

	public func set(category cat: String, baseURL url: URL, fileMap fmap: Dictionary<String, String>, loader ldr: @escaping LoaderFunc){
		let fileres = CNFileResource(baseURL: url, fileMap: fmap, loader: ldr)
		mFileResources[cat] = fileres
	}

	public func add(category cat: String, fileMap fmap: Dictionary<String, String>) {
		if let res = mFileResources[cat] {
			res.add(fileMap: fmap)
		} else {
			CNLog(type: .Error, message: "Category \"\(cat)\" is not found", file: #file, line: #line, function: #function)
		}
	}

	public func load<T>(category cat: String, identifier ident: String) -> T? {
		if let res = mFileResources[cat] {
			if let val = res.load(identifier: ident) {
				if let retval = val as? T {
					return retval
				} else {
					CNLog(type: .Error, message: "Unmatched data type", file: #file, line: #line, function: #function)
				}
			}
		}
		return nil
	}

	public func identifiers(category cat: String) -> Array<String>? {
		if let res = mFileResources[cat] {
			return res.identifiers()
		}
		return nil
	}

	public func toText() -> CNTextSection {
		let section = CNTextSection()
		section.header = "{" ; section.footer = "}"

		for (key, res) in mFileResources {
			let subsec = res.toText()
			subsec.header = "\(key): {"
			subsec.footer = "}"
			section.add(text: subsec)
		}

		return section
	}
}

