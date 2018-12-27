/*
 * @file	CNResource.swift
 * @brief	Define CNResource class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNResource {
	public typealias LoaderFunc = (_ url: URL) -> AnyObject?

	private class Item {
		var 	localPath:	String
		var 	content:	AnyObject?

		public init(localPath path: String){
			localPath = path
			content   = nil
		}
	}

	private var mBaseURL:		URL
	private var mLoaders:		Dictionary<String, LoaderFunc>
	private var mResourceTable:	Dictionary<String, Dictionary<String, Item>>

	public init(baseURL url: URL){
		mBaseURL	= url
		mLoaders	= [:]
		mResourceTable	= [:]
	}

	public func set(resourceName name: String, loader load: @escaping LoaderFunc) {
		mLoaders[name] = load
	}

	public func set(resourceName name: String, identifier ident: String, localPath path: String){
		guard let _ = mLoaders[name] else {
			NSLog("No allocator at \(#function)")
			return
		}
		/* Add new item */
		let newitem = Item(localPath: path)
		if var table = mResourceTable[name] {
			table[ident] = newitem
		} else {
			mResourceTable[name] = [ident:newitem]
		}
	}

	public func load(resourceName name: String, identifier ident: String) -> AnyObject? {
		guard let loader = mLoaders[name] else {
			NSLog("No loader for resource \"\(name)\" at \(#function)")
			return nil
		}
		guard let table = mResourceTable[name] else {
			NSLog("Unknown resource \"\(name)\" at \(#function)")
			return nil
		}
		guard let item = table[ident] else {
			NSLog("No resource named \"\(ident)\" at \(#function)")
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
				NSLog("Failed to load \"\(ident)\" at \(#function)")
				return nil
			}
		}
	}
}

