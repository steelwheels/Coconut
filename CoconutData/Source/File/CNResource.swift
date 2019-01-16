/*
 * @file	CNResource.swift
 * @brief	Define CNResource class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNResource {
	public typealias LoaderFunc = (_ url: URL) -> Any?

	private class Item {
		var 	localPath:	String
		var 	content:	Any?

		public init(localPath path: String){
			localPath = path
			content   = nil
		}

		public func toString() -> String {
			return localPath
		}
	}

	private var mBaseURL:		URL
	private var mLoaders:		Dictionary<String, LoaderFunc>
	private var mResourceTable:	Dictionary<String, Dictionary<String, Item>>
	private var mConsole:		CNConsole

	public init(baseURL url: URL, console cons: CNConsole){
		mBaseURL	= url
		mLoaders	= [:]
		mResourceTable	= [:]
		mConsole	= cons
	}

	public var baseURL: URL { get { return mBaseURL }}

	public func propertyNames(for resname: String) -> Array<String> {
		if let dict = mResourceTable[resname] {
			return Array(dict.keys)
		} else {
			return []
		}
	}

	public func set(resourceName name: String, loader load: @escaping LoaderFunc) {
		mLoaders[name] = load
	}

	public func set(resourceName name: String, identifier ident: String, localPath path: String){
		guard let _ = mLoaders[name] else {
			mConsole.error(string: "No allocator for \"\(name)\" at \(#function)\n")
			return
		}
		/* Add new item */
		let newitem = Item(localPath: path)
		if let _ = mResourceTable[name] {
			/* Update the instance itself (Avoid modification of copied resource) */
			mResourceTable[name]![ident] = newitem
		} else {
			mResourceTable[name] = [ident:newitem]
		}
	}

	public func load(resourceName name: String, identifier ident: String) -> Any? {
		guard let loader = mLoaders[name] else {
			mConsole.error(string: "No loader for resource \"\(name)\" at \(#function)")
			return nil
		}
		guard let table = mResourceTable[name] else {
			mConsole.error(string: "Unknown resource \"\(name)\" at \(#function)")
			return nil
		}
		guard let item = table[ident] else {
			mConsole.error(string: "No resource named \"\(ident)\" at \(#function)")
			return nil
		}
		if let data = item.content {
			return data
		} else {
			let url = mBaseURL.appendingPathComponent(item.localPath)
			if let newdata = loader(url) {
				item.content = newdata
				return newdata
			} else {
				mConsole.error(string: "Failed to load \"\(ident)\" at \(#function)")
				return nil
			}
		}
	}

	public func toText() -> CNTextSection {
		let section = CNTextSection()
		section.header = "{" ; section.footer = "}"

		for (name, table) in mResourceTable {
			let subsec = CNTextSection()
			subsec.header = "\(name): " ; subsec.footer = "}"
			let content = encodeToExt(table: table)
			subsec.add(text: content)
			section.add(text: subsec)
		}

		return section
	}

	private func encodeToExt(table tab: Dictionary<String, Item>) -> CNTextSection {
		let section = CNTextSection()
		section.header = "{" ; section.footer = "}"

		for (name, item) in tab {
			let line = "\(name): " + item.toString()
			let text = CNTextLine(string: line)
			section.add(text: text)
		}

		return section
	}
}

