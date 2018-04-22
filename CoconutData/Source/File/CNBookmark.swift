/**
 * @file	CNBookmark.swift
 * @brief	Extend CNBookmark class
 * @par Copyright
 *   Copyright (C) 2016, 2017 Steel Wheels Project
 */

import Foundation

#if os(OSX)

internal class CNBookmarks
{
	private var bookmarkDictionary : [String:Data]
	
	internal init(){
		bookmarkDictionary = [:]
	}

	internal func addBookmark(URL url: URL) {
		let path = url.path
		if let _ = bookmarkDictionary[path] {
			/* Already store */
		} else {
			let data = allocateBookmarkData(URL: url)
			bookmarkDictionary[path] = data
		}
	}

	internal func searchBookmark(pathString path: String) -> URL? {
		if let data = bookmarkDictionary[path] {
			if let url = CNBookmarks.resolveURL(bookmarkData: data) {
				return url
			} else {
				NSLog("Broken bookmark data for key \"\(path)\"")
			}
		}
		return nil
	}

	internal class func decode(dictionary dict : [String:Data]) -> CNBookmarks {
		let newbookmarks = CNBookmarks()
		newbookmarks.bookmarkDictionary = dict
		return newbookmarks
	}

	internal func encode() -> [String:Data] {
		return bookmarkDictionary
	}

	internal func clear() {
		bookmarkDictionary = [:]
	}

	internal func dump(){
		Swift.print("(CNBookmarks \(bookmarkDictionary))")
	}

	private func allocateBookmarkData(URL url: URL) -> Data {
		do {
			let data = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
			return data
		}
		catch {
			let urlstr = url.absoluteString
			fatalError("Can not allocate bookmark: \"\(urlstr)")
		}
	}

	private class func resolveURL(bookmarkData bmdata: Data) -> URL? {
		do {
			var isstale: Bool = false;
			let newurl = try URL(resolvingBookmarkData: bmdata, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isstale)
			return newurl
		}
		catch {
			NSLog("Failed to resolve bookmark")
			return nil
		}
	}
}

public class CNBookmarkPreference
{
	public static let sharedPreference = CNBookmarkPreference()
	private var mBookmarks : CNBookmarks

	private init(){
		if let pref = CNBookmarkPreference.rootPreferences() {
			mBookmarks = CNBookmarks.decode(dictionary: pref)
		} else {
			mBookmarks = CNBookmarks()
		}
	}

	public func saveToUserDefaults(URL url: URL)
	{
		mBookmarks.addBookmark(URL: url)
	}

	public func saveToUserDefaults(URLs urls: Array<URL>)
	{
		for url in urls {
			mBookmarks.addBookmark(URL: url)
		}
	}

	public func loadFromUserDefaults(path p:String) -> URL? {
		return mBookmarks.searchBookmark(pathString: p)
	}

	public func clear(){
		mBookmarks.clear()
	}

	public func synchronize() {
		let dict = mBookmarks.encode()
		let preference = UserDefaults.standard
		preference.set(dict, forKey: CNBookmarkPreference.bookmarkPreferekceKey())
		preference.synchronize()
	}

	public func dump(){
		mBookmarks.dump()
	}

	private class func rootPreferences() -> [String:Data]? {
		let preference = UserDefaults.standard
		if let pref = preference.dictionary(forKey: CNBookmarkPreference.bookmarkPreferekceKey()) {
			if let dict = pref as? [String:Data] {
				return dict
			} else {
				fatalError("Can not convert preference")
			}
		} else {
			return nil
		}
	}

	private class func bookmarkPreferekceKey() -> String {
		return "bookmarks"
	}
}

#endif /* os(OSX) */



