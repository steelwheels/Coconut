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

	private var	mPath:		String
	private var 	mContent:	Any?

	public init(path pathstr: String){
		mPath		= pathstr
		mContent	= nil
	}

	public func load<T>(baseURL url: URL, loader ldr: LoaderFunc) -> T? {
		if let content = mContent {
			return content as? T
		} else {
			let pathurl = url.appendingPathComponent(mPath)
			mContent = ldr(pathurl)
			return mContent as? T
		}
	}

	public func toText() -> CNTextLine {
		return CNTextLine(string: "\"\(mPath)\"")
	}
}

private class CNDirectoryResource
{
	public typealias LoaderFunc = CNFileResource.LoaderFunc

	private var mFileMap:	Dictionary<String, Array<CNFileResource>>	// Identifier, Array of file resource
	private var mLoader:	LoaderFunc

	public init(loader ldr: @escaping LoaderFunc){
		mFileMap	= [:]
		mLoader		= ldr
	}

	public func count(identifier ident: String) -> Int? {
		if let files = mFileMap[ident] {
			return files.count
		}
		return nil
	}

	public func set(identifier ident: String, path pathstr: String) {
		mFileMap[ident] = [CNFileResource(path: pathstr)]
	}

	public func add(identifier ident: String, path pathstr: String) {
		if let _ = mFileMap[ident] {
			mFileMap[ident]?.append(CNFileResource(path: pathstr))
		} else {
			mFileMap[ident] = [CNFileResource(path: pathstr)]
		}
	}
	
	public func load<T>(baseURL url: URL, identifier ident: String, index idx: Int) -> T? {
		if let files = mFileMap[ident] {
			if idx < files.count {
				let contents:T? = files[idx].load(baseURL: url, loader: mLoader)
				return contents
			}
		}
		return nil
	}

	public func identifiers() -> Array<String> {
		var result: Array<String> = []
		for (ident, _) in mFileMap {
			result.append(ident)
		}
		return result
	}

	public func toText(category cat: String) -> CNTextSection {
		let section = CNTextSection()
		section.header = "\(cat): {" ; section.footer = "}"

		for (ident, resources) in mFileMap {
			let subsec = CNTextSection()
			subsec.header = "\(ident): {" ; subsec.footer = "}"
			for resource in resources {
				let restxt = resource.toText()
				subsec.add(text: restxt)
			}
			section.add(text: subsec)
		}

		return section
	}
}

public class CNResource
{
	public typealias LoaderFunc = (_ url: URL) -> Any?

	private var mBaseURL			: URL
	private var mDirectoryResources		: Dictionary<String, CNDirectoryResource>	// category, directory-resource

	public var baseURL: URL { get { return mBaseURL }}

	public init(baseURL url: URL) {
		mBaseURL		= url
		mDirectoryResources	= [:]
	}

	public func allocate(category cat: String, loader ldr: @escaping LoaderFunc) {
		mDirectoryResources[cat] = CNDirectoryResource(loader: ldr)
	}

	public func set(category cat: String, identifier ident: String, path pathstr: String) {
		mDirectoryResources[cat]?.set(identifier: ident, path: pathstr)
	}

	public func add(category cat: String, identifier ident: String, path pathstr: String) {
		mDirectoryResources[cat]?.add(identifier: ident, path: pathstr)
	}

	public func count(category cat: String, identifier ident: String) -> Int? {
		return mDirectoryResources[cat]?.count(identifier: ident)
	}

	public func load<T>(category cat: String, identifier ident: String, index idx: Int) -> T? {
		let result:T? = mDirectoryResources[cat]?.load(baseURL: mBaseURL, identifier: ident, index: idx)
		return result
	}

	public func identifiers(category cat: String) -> Array<String>? {
		if let resource = mDirectoryResources[cat] {
			return resource.identifiers()
		} else {
			return nil
		}
	}

	public func toText() -> CNTextSection {
		let section = CNTextSection()
		section.header = "{" ; section.footer = "}"

		let urltxt = CNTextLine(string: "URL: \(mBaseURL.absoluteString)")
		section.add(text: urltxt)

		for (category, resource) in mDirectoryResources {
			let subsec = resource.toText(category: category)
			section.add(text: subsec)
		}
		return section
	}
}


/*
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
*/

