/*
 * @file	CNFileManager.swift
 * @brief	Extend FileManager class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNFileType: Int {
	case NotExist		= 0
	case File		= 1
	case Directory		= 2

	public var description: String {
		get {
			var result: String
			switch self {
			case .NotExist:		result = "Not exist"
			case .File:		result = "File"
			case .Directory:	result = "Directory"
			}
			return result
		}
	}
}

public enum CNFileOpenResult {
	case 	ok(_ file: CNFile)
	case	error(_ error: NSError)
}

public enum CNFileAccessType: Int {
	case ReadAccess		= 0
	case WriteAccess	= 1
	case AppendAccess	= 2
}

public extension FileManager
{
	/* If you give full path to "relpath", "base" directory will be ignored */
	func fullPath(pathString path: String, baseURL base: URL) -> URL {
		let fullpath: String
		if self.isAbsolutePath(pathString: path) {
			fullpath   = path
		} else {
			let newurl = URL(fileURLWithPath: path, relativeTo: base)
			fullpath   = newurl.path
		}
		if let url = CNPreference.shared.bookmarkPreference.search(pathString: fullpath) {
			return url
		} else {
			return URL(fileURLWithPath: fullpath)
		}
	}

	func fileExists(atURL url: URL) -> Bool {
		return fileExists(atPath: url.path)
	}

	func isReadableFile(atURL url: URL) -> Bool {
		return isReadableFile(atPath: url.path)
	}

	func isWritableFile(atURL url: URL) -> Bool {
		return isWritableFile(atPath: url.path)
	}

	func isDeletableFile(atURL url: URL) -> Bool {
		return isDeletableFile(atPath: url.path)
	}

	func createFile(atURL url: URL, contents data: Data?, attributes attr: [FileAttributeKey:Any]?) -> Bool {
		return createFile(atPath: url.absoluteString, contents: data, attributes: attr)
	}

	func removeFile(atURL url: URL) -> NSError? {
		do {
			try self.removeItem(at: url)
			return nil
		} catch  {
			return (error as NSError)
		}
	}

	func createDirectories(directory dir: URL) -> NSError? {
		guard dir.pathComponents.count > 0 else {
			return NSError.parseError(message: "No directory is contained")
		}
		do {
			try createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
			return nil
		} catch {
			return (error as NSError)
		}
	}

	func checkFileType(pathString pathstr: String) -> CNFileType {
		var isdir    = ObjCBool(false)
		if fileExists(atPath: pathstr, isDirectory: &isdir) {
			if isdir.boolValue {
				return .Directory
			} else {
				return .File
			}
		} else {
			return .NotExist
		}
	}

	func openFile(URL url: URL, accessType acctyp: CNFileAccessType) -> Result<CNFile, NSError> {
		switch acctyp {
		case .ReadAccess:
			return openFile(forReadingFrom: url)
		case .WriteAccess:
			return openFile(forWritingFrom: url)
		case .AppendAccess:
			return openFile(forAppendingFrom: url)
		}
	}

	func openFile(forReadingFrom url: URL) -> Result<CNFile, NSError> {
		do {
			let handle = try FileHandle(forReadingFrom: url)
			let file   = CNFile(access: .reader, fileHandle: handle)
			return .success(file)
		} catch {
			return .failure(error as NSError)
		}
	}

	func openFile(forWritingFrom url: URL) -> Result<CNFile, NSError> {
		let filemgr = FileManager.default
		if !fileExists(atURL: url) {
			filemgr.createFile(atPath: url.path, contents: nil, attributes: nil)
		}
		do {
			let handle = try FileHandle(forWritingTo: url)
			let file = CNFile(access: .writer, fileHandle: handle)
			return .success(file)
		} catch {
			return .failure(error as NSError)
		}
	}

	func openFile(forAppendingFrom url: URL) -> Result<CNFile, NSError> {
		do {
			let handle = try FileHandle(forUpdating: url)
			let file = CNFile(access: .writer, fileHandle: handle)
			return .success(file)
		} catch {
			return .failure(error as NSError)
		}
	}

	func schemeInPath(pathString str: String) -> String? {
		if let lastidx = str.firstIndex(of: ":") {
			var i:String.Index = str.startIndex
			var result: String = ""
			while i < lastidx {
				let c = str[i]
				if c.isLetterOrNumber || c == "." || c == "_" {
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

	/* The absolute path is
	 *  1. Started by '/'
	 *  2. Started by scheme, such as file:
	 */
	func isAbsolutePath(pathString path: String) -> Bool {
		if let c = path.first {
			if c == "/" || schemeInPath(pathString: path) != nil {
				return true
			} else {
				return false
			}
		} else {
			return false
		}
	}

	/* Reference: https://stackoverflow.com/questions/10512920/mac-sandbox-testing-whether-a-file-is-accessible*/
	func isAccessible(pathString path: String, accessType type: CNFileAccessType) -> Bool {
		let modes: Array<Int32>
		switch type {
		case .ReadAccess:	modes = [R_OK]
		case .WriteAccess:	modes = [W_OK]
		case .AppendAccess:	modes = [R_OK, W_OK]
		}

		let result: Bool
		let pref = CNPreference.shared.bookmarkPreference
		if let url = pref.search(pathString: path) {
			let issecure = url.startAccessingSecurityScopedResource()
			result = isAccessible(pathString: url.path, accessModes: modes)
			if issecure {
				url.stopAccessingSecurityScopedResource()
			}
		} else {
			result = isAccessible(pathString: path, accessModes: modes)
		}
		return result
	}

	private func isAccessible(pathString path: String, accessModes modes: Array<Int32>) -> Bool {
		for mode in modes {
			if access(path, mode) != 0 {
				return false
			}
		}
		return true
	}

	func copyFile(sourceFile srcurl: URL, destinationFile dsturl: URL, doReplace dorep: Bool) -> Bool {
		guard self.fileExists(atURL: srcurl) else {
			CNLog(logLevel: .error, message: "Source file \(srcurl.path) is NOT exist", atFunction: #function, inFile: #file)
			return false
		}
		var result = true
		do {
			/* Make directory */
			let dstdir: URL
			if dsturl.isFileURL {
				dstdir = dsturl.deletingLastPathComponent()
			} else {
				dstdir = dsturl
			}
			if !self.fileExists(atPath: dstdir.path) {
				CNLog(logLevel: .detail, message: "Create Directory: \(dstdir.path)", atFunction: #function, inFile: #file)
				try self.createDirectory(at: dstdir, withIntermediateDirectories: true, attributes: nil)
			}
			if dorep {
				/* Remove current file */
				if self.fileExists(atURL: dsturl){
					try self.removeItem(at: dsturl)
				}
				/* Copy the file */
				try self.copyItem(at: srcurl, to: dsturl)
			} else {
				if self.fileExists(atURL: dsturl){
					/* Skip to copy */
				} else {
					/* Copy the file */
					try self.copyItem(at: srcurl, to: dsturl)
				}
			}
		} catch {
			let err = error as NSError
			CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
			result = false
		}
		return result
	}

	var documentDirectory: URL { get {
		let urls = self.urls(for: .documentDirectory, in: .userDomainMask)
		if let url = urls.first {
			return url
		} else {
			CNLog(logLevel: .error, message: "Can not find document directory path", atFunction: #function, inFile: #file)
			let dir = NSHomeDirectory() + "/Document"
			return URL(filePath: dir)
		}
	}}

	var libraryDirectory: URL { get {
		let urls = self.urls(for: .libraryDirectory, in: .userDomainMask)
		if let url = urls.first {
			return url
		} else {
			CNLog(logLevel: .error, message: "Can not find library directory path", atFunction: #function, inFile: #file)
			let dir = NSHomeDirectory() + "/Library"
			return URL(filePath: dir)
		}
	}}
}

