/**
 * @file	CNFilePath.swift
 * @brief	Define CNFilePath class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

import Foundation

/**
 * Define methods to operate the file URL
 */
public class CNFilePath
{
	public enum FilePathError {
		case ok(_ url: URL)
		case error(_ error: NSError)
	}

	public class func URLForHomeDirectory() -> URL {
		let homedir = NSHomeDirectory()
		return URL(fileURLWithPath: homedir, isDirectory: true)
	}
	
	public class func URLForBundleFile(bundleName bname: String?, fileName fname: String?, ofType type: String?) -> FilePathError {
		let mainbundle = Bundle.main
		if let bundlepath = mainbundle.path(forResource: bname, ofType: "bundle") {
			if let resourcebundle = Bundle(path: bundlepath) {
				if let resourcepath = resourcebundle.path(forResource: fname, ofType: type){
					if let url = URL(string: "file://" + resourcepath) {
						return .ok(url)
					}
				}
				return .error(NSError.fileError(message: "File \"\(name(fname))\" of type \"\(name(type))\" is not found"))
			} else {
				return .error(NSError.fileError(message: "Failed to allocate bundle \"\(bundlepath)\""))
			}
		} else {
			return .error(NSError.fileError(message: "\(name(bname)).bundle is not found"))
		}
	}

	public class func URLForResourceFile(fileName fname: String, fileExtension fext: String) -> URL? {
		return Bundle.main.url(forResource: fname, withExtension: fext)
	}

	public class func URLForResourceFile(fileName fname: String, fileExtension fext: String, subdirectory subdir: String) -> URL? {
		return Bundle.main.url(forResource: fname, withExtension: fext, subdirectory: subdir)
	}

	public class func URLForResourceFile(fileName fname: String, fileExtension fext: String, forClass fclass: AnyClass) -> URL? {
        	let bundle = Bundle(for: fclass)
        	return bundle.url(forResource: fname, withExtension: fext)
    	}

	public class func URLForResourceFile(fileName fname: String, fileExtension fext: String, subdirectory subdir: String, forClass fclass: AnyClass) -> URL? {
		let bundle = Bundle(for: fclass)
		return bundle.url(forResource: fname, withExtension: fext, subdirectory: subdir)
	}

	/* reference: https://qiita.com/masakihori/items/8d4af538b040c65a8871 */
	public class func UTIForFile(URL url: URL) -> String? {
		guard let r = try? url.resourceValues(forKeys: [.typeIdentifierKey]) else {
			return nil
		}
		return r.typeIdentifier
	}

	private class func name(_ name: String?) -> String {
		if let str = name {
			return str
		} else {
			return "<unknown>"
		}
	}

	public class func schemeInString(string str: String) -> String? {
		if let lastidx = str.firstIndex(of: ":") {
			var i:String.Index = str.startIndex
			var result: String = ""
			while i < lastidx {
				let c = str[i]
				if c.isAlphaOrNum() || c == "." || c == "_" {
					result.append(c)
				} else {
					return nil
				}
				i = str.index(after: i)
			}
			return result
		} else {
			return nil
		}
	}
}

