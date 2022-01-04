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

	public var pathString: String { get { return mPath }}

	public func fullPathURL(packageDirectory url: URL) -> URL? {
		return url.appendingPathComponent(mPath)
	}

	public func load<T>(packageDirectory url: URL, loader ldr: LoaderFunc) -> T? {
		if let content = mContent {
			return content as? T
		} else {
			let pathurl = url.appendingPathComponent(mPath)
			mContent = ldr(pathurl)
			return mContent as? T
		}
	}

	public func store(content cnt: Any) {
		mContent = cnt
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

	public func add(identifier ident: String, path pathstr: String) {
		if let _ = mFileMap[ident] {
			mFileMap[ident]?.append(CNFileResource(path: pathstr))
		} else {
			mFileMap[ident] = [CNFileResource(path: pathstr)]
		}
	}

	public func set(identifier ident: String, path pathstr: String) {
		mFileMap[ident] = [CNFileResource(path: pathstr)]
	}

	public func store(identifier ident: String, index idx: Int, content cnt: Any){
		if let fmap = mFileMap[ident] {
			fmap[idx].store(content: cnt)
		}
	}

	public func pathString(identifier ident: String, index idx: Int) -> String? {
		if let files = mFileMap[ident] {
			if idx < files.count {
				return files[idx].pathString
			}
		}
		return nil
	}

	public func fullPathURL(packageDirectory url: URL, identifier ident: String, index idx: Int) -> URL? {
		if let files = mFileMap[ident] {
			if idx < files.count {
				return files[idx].fullPathURL(packageDirectory: url)
			}
		}
		return nil
	}

	public func load<T>(packageDirectory url: URL, identifier ident: String, index idx: Int) -> T? {
		if let files = mFileMap[ident] {
			if idx < files.count {
				let contents:T? = files[idx].load(packageDirectory: url, loader: mLoader)
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

open class CNResource
{
	public typealias LoaderFunc = (_ url: URL) -> Any?

	private var mPackageDirectory		: URL
	private var mDirectoryResources		: Dictionary<String, CNDirectoryResource>	// category, directory-resource

	public var packageDirectory: URL { get { return mPackageDirectory }}

	public init(packageDirectory url: URL) {
		mPackageDirectory	= url
		mDirectoryResources	= [:]
	}

	public func allocate(category cat: String, loader ldr: @escaping LoaderFunc) {
		mDirectoryResources[cat] = CNDirectoryResource(loader: ldr)
	}

	public func add(category cat: String, identifier ident: String, path pathstr: String) {
		mDirectoryResources[cat]?.add(identifier: ident, path: pathstr)
	}

	public func set(category cat: String, identifier ident: String, path pathstr: String) {
		mDirectoryResources[cat]?.set(identifier: ident, path: pathstr)
	}

	public func store(category cat: String, identifier ident: String, index idx: Int, content cnt: Any){
		if let res = mDirectoryResources[cat] {
			res.store(identifier: ident, index: idx, content: cnt)
		}
	}

	public func count(category cat: String, identifier ident: String) -> Int? {
		return mDirectoryResources[cat]?.count(identifier: ident)
	}

	public func pathString(category cat: String, identifier ident: String, index idx: Int) -> String? {
		if let dirres = mDirectoryResources[cat] {
			return dirres.pathString(identifier: ident, index: idx)
		}
		return nil
	}

	public func fullPathURL(category cat: String, identifier ident: String, index idx: Int) -> URL? {
		if let dirres = mDirectoryResources[cat] {
			return dirres.fullPathURL(packageDirectory: mPackageDirectory, identifier: ident, index: idx)
		}
		return nil
	}

	public func load<T>(category cat: String, identifier ident: String, index idx: Int) -> T? {
		let result:T? = mDirectoryResources[cat]?.load(packageDirectory: mPackageDirectory, identifier: ident, index: idx)
		return result
	}

	public func identifiers(category cat: String) -> Array<String>? {
		if let resource = mDirectoryResources[cat] {
			return resource.identifiers()
		} else {
			return nil
		}
	}

	public func copy(destination dres: CNResource, category cat: String) {
		if let dir = mDirectoryResources[cat] {
			dres.mDirectoryResources[cat] = dir
		}
	}

	public func toText() -> CNTextSection {
		let section = CNTextSection()
		section.header = "{" ; section.footer = "}"

		let urltxt = CNTextLine(string: "URL: \(mPackageDirectory.relativeString)")
		section.add(text: urltxt)

		let categories = mDirectoryResources.keys.sorted()
		for category in categories {
			if let dirres = mDirectoryResources[category] {
				let subsec = dirres.toText(category: category)
				section.add(text: subsec)
			} else {
				fatalError("Can not happen")
			}
		}
		return section
	}
}

