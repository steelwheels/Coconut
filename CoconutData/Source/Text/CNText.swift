/**
 * @file	CNText.h
 * @brief	Define CNText class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation


public protocol CNText
{
	func append(string src: String)
	func prepend(string src: String)
	func toStrings(indent idt: Int) -> Array<String>
}

public extension CNText
{
	func toStrings() -> Array<String> {
		return self.toStrings(indent: 0)
	}

	func indentString(indent idt: Int) -> String {
		var str: String = ""
		for _ in 0..<idt {
			str = str + "  "
		}
		return str
	}

	func adjustString(string str: String, length len: Int) -> String {
		var newstr = str
		let rest   = len - str.utf8.count
		for _ in 0..<rest {
			newstr += " "
		}
		return newstr
	}
}

private func split(string src: String) -> Array<String> {
	let lines = src.split(separator: "\n")
	var result: Array<String> = []
	for line in lines {
		result.append(String(line))
	}
	return result
}

public class CNTextLine: CNText
{
	private var mLines:	Array<String>

	public init(){
		mLines = []
	}

	public init(string src: String){
		mLines = split(string: src)
	}

	public func set(string src: String){
		mLines = split(string: src)
	}

	public func append(string src: String){
		let lines = split(string: src)
		mLines = merge(lines0: mLines, lines1: lines)
	}

	public func prepend(string src: String){
		let lines = split(string: src)
		mLines = merge(lines0: lines, lines1: mLines)
	}

	private func merge(lines0 ln0: Array<String>, lines1 ln1: Array<String>) -> Array<String> {
		if ln0.count == 0 {
			return ln1
		} else if ln1.count == 0 {
			return ln0
		} else { // ln0.count > 0 && ln1.count > 0
			var result = ln0
			result[result.count - 1] += ln1[0]
			for i in 1..<ln1.count {
				result.append(ln1[i])
			}
			return result
		}
	}

	public func toStrings(indent idt: Int) -> Array<String> {
		let spaces = indentString(indent: idt)
		var result: Array<String> = []
		for line in mLines {
			result.append(spaces + line)
		}
		return result
	}
}

public class CNTextSection: CNText
{
	public var header: String
	public var footer: String

	private var mContents: Array<CNText>

	public init() {
		self.header	= ""
		self.footer	= ""
		self.mContents	= []
	}

	public var count: Int { get { return mContents.count }}

	public func add(text src: CNText){
		mContents.append(src)
	}

	public func insert(text src: CNText){
		mContents.insert(src, at: 0)
	}

	public func append(string src: String){
		if let last = mContents.last as? CNTextLine {
			last.append(string: src)
		} else {
			let newtxt = CNTextLine(string: src)
			self.add(text: newtxt)
		}
	}

	public func prepend(string src: String){
		if let first = mContents.first as? CNTextLine {
			first.prepend(string: src)
		} else {
			let newtxt = CNTextLine(string: src)
			self.insert(text: newtxt)
		}
	}

	public func toStrings(indent idt: Int) -> Array<String> {
		var result: Array<String> = []
		var nextidt = idt

		let spaces = indentString(indent: idt)
		if !self.header.isEmpty {
			result.append(spaces + self.header)
			nextidt += 1
		}
		for content in mContents {
			let lines = content.toStrings(indent: nextidt)
			result.append(contentsOf: lines)
		}
		if !self.footer.isEmpty {
			result.append(spaces + self.footer)
		}
		return result
	}
}

public class CNTextRecord
{
	private var mColumns: Array<Array<String>>

	public init(){
		mColumns = []
	}

	public var count: Int { get { return mColumns.count }}

	public var columns: Array<Array<String>> {
		get { return mColumns }
	}

	public func append(string src: String) {
		let lines = split(string: src)
		mColumns.append(lines)
	}

	public func prepend(string src: String) {
		let lines = split(string: src)
		mColumns.insert(lines, at: 0)
	}
}

public class CNTextTable: CNText
{
	public var mRecords: Array<CNTextRecord>

	public init(){
		mRecords = []
	}

	public var count: Int { get { return mRecords.count }}

	public var records: Array<CNTextRecord> {
		get		{ return mRecords }
		set(recs)	{ mRecords = recs }
	}

	public func add(record src: CNTextRecord) {
		mRecords.append(src)
	}

	public func insert(record src: CNTextRecord){
		mRecords.insert(src, at: 0)
	}

	public func append(string src: String) {
		if mRecords.count > 0 {
			mRecords[mRecords.count - 1].append(string: src)
		} else {
			let newrec = CNTextRecord()
			newrec.append(string: src)
			mRecords.append(newrec)
		}
	}

	public func prepend(string src: String) {
		if mRecords.count > 0 {
			mRecords[mRecords.count - 1].prepend(string: src)
		} else {
			let newrec = CNTextRecord()
			newrec.prepend(string: src)
			mRecords.append(newrec)
		}
	}

	public func toStrings(indent idt: Int) -> Array<String> {
		/* Get max column num */
		var colnum: Int = 0
		for rec in mRecords {
			colnum = max(colnum, rec.count)
		}

		/* Initialize column width */
		var width: Array<Int> = Array(repeating: 0, count: colnum)

		/* Get max width for each column */
		for rec in mRecords {
			for i in 0..<rec.count {
				for line in rec.columns[i] {
					let len = line.utf8.count
					width[i] = max(width[i], len)
				}
			}
		}

		let spaces = indentString(indent: idt)
		var results: Array<String> = []
		for rec in mRecords {
			/* Get max line numbers in the record */
			var linenum = 0
			for i in 0..<rec.count {
				linenum = max(linenum, rec.columns[i].count)
			}

			var lines: Array<String> = []
			for lidx in 0..<linenum {
				var line: String = spaces
				for col in 0..<rec.count {
					let column: String
					if lidx < rec.columns[col].count {
						column = rec.columns[col][lidx]
					} else {
						column = ""
					}
					line += adjustString(string: column, length: width[col] + 1)
				}
				lines.append(line)
			}
			results.append(contentsOf: lines)
		}
		return results
	}
}





