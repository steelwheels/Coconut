/**
 * @file	CNText.h
 * @brief	Define CNText class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public class CNText
{
	public var dummy: Int

	public init(){
		dummy = 1
	}

	public func indentString(indent idt: Int) -> String {
		var str: String = ""
		for _ in 0..<idt {
			str = str + "  "
		}
		return str
	}

	open func append(string src: String){
		fatalError("Must be override")
	}

	public final func append(text src: CNTextLine){
		append(string: src.string)
	}

	open func prepend(string src: String){
		fatalError("Must be override")
	}

	public func toStrings() -> Array<String> {
		return self.toStrings(indent: 0, terminal: "")
	}

	open func toStrings(indent idt: Int, terminal tc: String) -> Array<String> {
		fatalError("Must be override")
	}
}

public class CNTextLine: CNText
{
	private var mString: String

	public required init(string str: String){
		mString = str
	}

	public var string: String {
		get { return mString }
	}

	public override func append(string src: String){
		mString += src
	}

	open override func prepend(string src: String){
		mString  = src + mString
	}

	public override func toStrings(indent idt: Int, terminal tc: String) -> Array<String> {
		let str = indentString(indent: idt) + mString + tc
		return [str]
	}
}

public class CNTextSection: CNText
{
	public var header: String	= ""
	public var footer: String	= ""

	private var mContents: Array<CNText> = []

	public var count: Int { get{ return mContents.count }}

	public func add(text txt: CNText){
		mContents.append(txt)
	}

	public func add(multiText txt: Array<CNText>) {
		mContents.append(contentsOf: txt)
	}

	public func add(string str: String){
		let newline = CNTextLine(string: str)
		mContents.append(newline)
	}

	public func add(strings strs: Array<String>){
		for s in strs {
			add(string: s)
		}
	}

	public func addMultiLines(string str: String) {
		let stmts = str.components(separatedBy: "\n")
		add(strings: stmts)
	}

	public override func append(string str: String){
		let count = mContents.count
		if count > 0 {
			mContents[count-1].append(string: str)
		} else {
			add(string: str)
		}
	}

	open override func prepend(string src: String){
		if mContents.count > 0 {
			mContents[0].prepend(string: src)
		} else {
			add(string: src)
		}
	}

	public override func toStrings(indent idt: Int, terminal tc: String) -> Array<String> {
		let spaces = indentString(indent: idt)
		var result: Array<String> = []
		if header != "" {
			result.append(spaces + header)
		}
		let nextidt = idt + 1
		for idx in 0..<mContents.count {
			let text  = mContents[idx]
			let delim = idx<mContents.count - 1 ? ", " : ""
			let strs = text.toStrings(indent: nextidt, terminal: delim)
			result.append(contentsOf: strs)
		}
		if footer != "" || tc != "" {
			result.append(spaces + footer + tc)
		}
		return result
	}
}

/*
public func CNAddStringToText(text txt:CNText, string str: String) -> CNTextSection
{
	if let line = txt as? CNTextLine {
		let section = CNTextSection()
		section.add(text: line)
		section.add(string: str)
		return section
	} else if let section = txt as? CNTextSection {
		section.add(string: str)
		return section
	} else {
		fatalError("Unknown object")
	}
}

public func CNAddStringsToText(text txt:CNText, strings strs: Array<String>) -> CNText
{
	let count = strs.count
	if count > 0 {
		let section = CNAddStringToText(text: txt, string: strs[0])
		let rests   = strs[1..<count]
		for str in rests {
			section.add(string: str)
		}
		return section
	} else {
		return txt
	}
}
*/



