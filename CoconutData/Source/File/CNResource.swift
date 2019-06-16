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

	public required init(path pathstr: String){
		mPath		= pathstr
		mContent	= nil
	}

	public func fullPathURL(baseURL url: URL) -> URL? {
		return url.appendingPathComponent(mPath)
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

	public required init(loader ldr: @escaping LoaderFunc){
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

	public func fullPathURL(baseURL url: URL, identifier ident: String, index idx: Int) -> URL? {
		if let files = mFileMap[ident] {
			if idx < files.count {
				return files[idx].fullPathURL(baseURL: url)
			}
		}
		return nil
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

	public required init(baseURL url: URL) {
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

	public func fullPathURL(category cat: String, identifier ident: String, index idx: Int) -> URL? {
		if let dirres = mDirectoryResources[cat] {
			return dirres.fullPathURL(baseURL: mBaseURL, identifier: ident, index: idx)
		}
		return nil
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

