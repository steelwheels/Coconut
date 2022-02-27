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

	public enum FilePathsError {
		case ok(_ urls: [URL])
		case error(_ error: NSError)
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

	public class func URLForResourceFile(fileName fname: String, fileExtension fext: String, subdirectory subdir: String?, forClass fclass: AnyClass?) -> URL? {
		let bundle: Bundle
		if let cls = fclass {
			bundle = Bundle(for: cls)
		} else {
			bundle = Bundle.main
		}
		if let dir = subdir {
			return bundle.url(forResource: fname, withExtension: fext, subdirectory: dir)
		} else {
			return bundle.url(forResource: fname, withExtension: fext)
		}
	}

	public class func URLForResourceDirectory(directoryName dname: String, subdirectory subdir: String?, forClass fclass: AnyClass?) -> URL? {
		let bundle: Bundle
		if let cls = fclass {
			bundle = Bundle(for: cls)
		} else {
			bundle = Bundle.main
		}
		if let dir = subdir {
			return bundle.url(forResource: dname, withExtension: nil, subdirectory: dir)
		} else {
			return bundle.url(forResource: dname, withExtension: nil)
		}
	}

	public class func URLsForResourceFiles(fileExtension fext: String, subdirectory subdir: String?, forClass fclass: AnyClass?) -> FilePathsError {
		let bundle: Bundle
		if let cls = fclass {
			bundle = Bundle(for: cls)
		} else {
			bundle = Bundle.main
		}
		if let result = bundle.urls(forResourcesWithExtension: fext, subdirectory: subdir) {
			return .ok(result)
		} else {
			let err: NSError
			if let dir = subdir {
				err = NSError.fileError(message: "Failed to read bundle for ext \(fext) in subdir \(dir)")
			} else {
				err = NSError.fileError(message: "Failed to read bundle for ext \(fext)")
			}
			return .error(err)
		}
	}

	public class func URLsForResourceFiles(fileExtension fext: String, subdirectory subdir: String?, bundleName bname: String) -> FilePathsError {
		let mainbundle = Bundle.main
		if let bundlepath = mainbundle.path(forResource: bname, ofType: "bundle") {
			if let bundle = Bundle(path: bundlepath) {
				if let result = bundle.urls(forResourcesWithExtension: fext, subdirectory: subdir) {
					return .ok(result)
				} else {
					let err: NSError
					if let dir = subdir {
						err = NSError.fileError(message: "Failed to read bundle \(bname) for ext \(fext) in subdir \(dir)")
					} else {
						err = NSError.fileError(message: "Failed to read bundle \(bname) for ext \(fext)")
					}
					return .error(err)
				}
			}
		}
		return .error(NSError.fileError(message: "Failed to find bundle \(bname)"))
	}

	public class func URLforApplicationSupportDirectory(subDirectory subdir: String?) -> URL {
		let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
		var dir: String
		if path.count > 0 {
			dir = path[0]
		} else {
			dir = NSHomeDirectory() + "/Application Support"
		}
		if let sub = subdir {
			dir += "/" + sub
		}
		return URL(fileURLWithPath: dir, isDirectory: true)
	}

	public class func URLForApplicationSupportFile(fileName fname: String, fileExtension fext: String, subdirectory subdir: String?) -> URL {
		var baseurl = URLforApplicationSupportDirectory(subDirectory: subdir)
		baseurl.appendPathComponent(fname + "." + fext)
		return baseurl
	}

	public class func URLforTempDirectory() -> URL {
		return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
	}

	/* reference: https://qiita.com/masakihori/items/8d4af538b040c65a8871 */
	public class func UTIForFile(URL url: URL) -> String? {
		guard let r = try? url.resourceValues(forKeys: [.typeIdentifierKey]) else {
			return nil
		}
		return r.typeIdentifier
	}

	public class func relativePathUnderBaseURL(fullPath fpath: URL, basePath bpath: URL) -> String? {
		let fcomp = fpath.pathComponents
		let bcomp = bpath.pathComponents

		if bcomp.count < fcomp.count {
			/* Check they have same path */
			for i in 0..<bcomp.count {
				if fcomp[i] != bcomp[i] {
					CNLog(logLevel: .error, message: "Not matched path (0): \(fpath.path) <-> \(bpath.path)", atFunction: #function, inFile: #file)
					return nil
				}
			}
			/* Make relative comp */
			var newcomp: Array<String> = []
			for i in bcomp.count ..< fcomp.count {
				newcomp.append(fcomp[i])
			}
			let newpath = newcomp.joined(separator: "/")
			return newpath
		} else {
			CNLog(logLevel: .error, message: "Not matched path (1): \(fpath.path) <-> \(bpath.path)", atFunction: #function, inFile: #file)
			return nil
		}
	}

	private class func name(_ name: String?) -> String {
		if let str = name {
			return str
		} else {
			return "<unknown>"
		}
	}
}

