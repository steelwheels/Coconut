/**
 * @file	CNStringUtil.swift
 * @brief	Define CNStringUtil class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNStringUtil
{
	public class func divideByQuote(sourceString src: String, quote qchar: Character) -> Array<String>
	{
		var result: Array<String> = []
		var curstr: String        = ""
		var inquote: Bool 	  = false

		let stream = CNStringStream(string: src)
		while let c = stream.getc() {
			if c == "\\" {
				if let n = stream.getc() {
					if n == qchar {
						curstr.append(n)
					} else {
						curstr.append(c)
						curstr.append(n)
					}
				} else {
					curstr.append(c)
				}
			} else if c == qchar {
				let substrs = divideBySpace(inQuote: inquote, string: curstr)
				result.append(contentsOf: substrs)
				inquote = !inquote
				curstr = ""
			} else {
				curstr.append(c)
			}
		}
		let substrs = divideBySpace(inQuote: inquote, string: curstr)
		result.append(contentsOf: substrs)
		curstr = ""
		return result
	}

	public class func divideBySpaces(string src: String) -> Array<String> {
		var result: Array<String> = []
		var headidx = src.startIndex
		var curidx  = headidx
		let endidx  = src.endIndex
		while curidx < endidx {
			let c = src[curidx]
			if c.isWhitespace {
				/* flush current word */
				if headidx < curidx {
					let word = src[headidx..<curidx]
					result.append(String(word))
				}
				headidx = src.index(after: curidx)
				curidx  = headidx
			} else {
				curidx  = src.index(after: curidx)
			}
		}
		/* flush current word */
		if headidx < curidx {
			let word = src[headidx..<curidx]
			result.append(String(word))
			headidx = curidx
		}
		return result
	}

	private class func divideBySpace(inQuote inquote: Bool, string src: String) -> Array<String> {
		if src == "" {
			return []
		} else if inquote {
			return [src]
		} else {
			return src.components(separatedBy: CharacterSet.whitespaces).filter{ $0.lengthOfBytes(using: .utf8) > 0 }
		}
	}

	public class func spacePrefix(string str: String) -> String {
		var spaces: String = ""
		let start = str.startIndex
		let end   = str.endIndex
		var idx   = start
		while idx < end {
			let c = str[idx]
			if c==" " || c=="\t" {
				spaces.append(c)
			} else {
				break
			}
			idx = str.index(after: idx)
		}
		return spaces
	}

	public class func traceForward(string str: String, pointer ptr: String.Index, doSkipFunc skip: (Character) -> Bool) -> String.Index {
		let end   = str.endIndex
		var idx   = ptr
		while idx < end {
			if skip(str[idx]) {
				idx = str.index(after: idx)
			} else {
				break
			}
		}
		return idx
	}

	public class func traceBackward(string str: String, pointer ptr: String.Index, doSkipFunc skip: (Character) -> Bool) -> String.Index {
		let start   = str.startIndex
		var curidx  = ptr
		if start < curidx {
			var previdx = str.index(before: curidx)
			while start < previdx {
				if skip(str[previdx]) {
					curidx  = previdx
					previdx = str.index(before: curidx)
				} else {
					break
				}
			}
		}
		return curidx
	}
}
