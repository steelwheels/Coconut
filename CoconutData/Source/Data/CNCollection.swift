/**
 * @file	CNCollection.swift
 * @brief	Define CNCollection class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNCollection
{
	public enum Item {
		case image(URL)

		public var description: String { get {
			let result: String
			switch self {
			case .image(let url):
				result = "resource(\(url.path))"
			}
			return result
		}}
	}

	private struct Section {
		var header: String
		var footer: String
		var items: Array<Item>

		public init(header hdr: String, footer ftr: String, items itms: Array<Item>){
			header	= hdr
			footer	= ftr
			items   = itms
		}
	}

	private var mSections: Array<Section>

	public init(){
		mSections = []
	}

	public var sectionCount: Int { get { return mSections.count }}

	public func itemCount(inSection sec: Int) -> Int {
		if 0<=sec && sec<mSections.count {
			return mSections[sec].items.count
		} else {
			return 0
		}
	}

	public func header(ofSection sec: Int) -> String {
		if 0<=sec && sec<mSections.count {
			return mSections[sec].header
		} else {
			return ""
		}
	}

	public func footer(ofSection sec: Int) -> String {
		if 0<=sec && sec<mSections.count {
			return mSections[sec].footer
		} else {
			return ""
		}
	}

	public func value(section sec: Int, item itm: Int) -> Item? {
		if 0<=sec && sec<mSections.count {
			let sect = mSections[sec]
			if 0<=itm && itm<sect.items.count {
				return sect.items[itm]
			}
		}
		return nil
	}

	public func add(header hdr: String, footer ftr: String, items itms: Array<Item>) {
		let newsect = Section(header: hdr, footer: ftr, items: itms)
		mSections.append(newsect)
	}

	public func toText() -> CNText {
		let sect = CNTextSection()
		for subsec in mSections {
			let newsec = CNTextSection()
			newsec.header = "{ " + subsec.header
			newsec.footer = "} // " + subsec.footer
			sect.add(text: newsec)

			let newarr = CNTextSection()
			newarr.header = "["
			newarr.footer = "]"
			for item in subsec.items {
				switch item {
				case .image(let url):
					let line = CNTextLine(string: "image(\(url.path))")
					newarr.add(text: line)
				}
			}
			newsec.add(text: newarr)
		}
		return sect
	}

}


