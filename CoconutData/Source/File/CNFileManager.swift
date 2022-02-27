/*
 * @file	CNFileManager.swift
 * @brief	Extend FileManager class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNFileType: Int32 {
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

public enum CNFileAccessType: Int32 {
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

	func createFile(atURL url: URL, contents data: Data?, attributes attr: [FileAttributeKey:Any]?) -> Bool {
		return createFile(atPath: url.absoluteString, contents: data, attributes: attr)
	}

	enum Result {
		case ok
		case error(NSError)
	}

	func createDirectories(directory dir: URL) -> Result {
		guard dir.pathComponents.count > 0 else {
			return .error(NSError.parseError(message: "No directory is contained"))
		}
		do {
			try createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
			return .ok
		} catch let err as NSError {
			return .error(err)
		} catch {
			return .error(NSError.unknownError())
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

	func openFile(URL url: URL, accessType acctyp: CNFileAccessType) -> CNFileOpenResult {
		do {
			var file: CNFile
			switch acctyp {
			case .ReadAccess:
				let handle = try FileHandle(forReadingFrom: url)
				file = CNFile(access: .reader, fileHandle: handle)
			case .WriteAccess:
				let handle = try FileHandle(forReadingFrom: url)
				file = CNFile(access: .writer, fileHandle: handle)
			case .AppendAccess:
				let handle = try FileHandle(forWritingTo: url)
				file = CNFile(access: .writer, fileHandle: handle)
			}
			return .ok(file)
		} catch let err as NSError {
			return .error(err)
		} catch {
			let err = NSError.fileError(message: "Failed to open URL \"\(url.absoluteString)\"")
			return .error(err)
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

	func copyFileIfItIsNotExist(sourceFile srcurl: URL, destinationFile dsturl: URL) -> Bool {
		let fmanager = FileManager.default

		guard fmanager.fileExists(atURL: srcurl) else {
			CNLog(logLevel: .error, message: "Source file \(srcurl.path) is NOT exist", atFunction: #function, inFile: #file)
			return false
		}
		if fmanager.fileExists(atURL: dsturl){
			/* Already exist */
			CNLog(logLevel: .debug, message: "Destination file \(dsturl.path) is already exist", atFunction: #function, inFile: #file)
		} else {
			do {
				if dsturl.isFileURL {
					let dstdir = dsturl.deletingLastPathComponent()
					if !self.fileExists(atPath: dstdir.path) {
						CNLog(logLevel: .debug, message: "Create Directory: \(dstdir.path)", atFunction: #function, inFile: #file)
						try fmanager.createDirectory(at: dstdir, withIntermediateDirectories: false, attributes: nil)
					}
				}
				try fmanager.copyItem(at: srcurl, to: dsturl)
			} catch let err as NSError {
				CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
				return false
			} catch {
				CNLog(logLevel: .error, message: "Failed to copy file: \(srcurl.path) -> \(dsturl.path)", atFunction: #function, inFile: #file)
				return false
			}
		}
		return true
	}
	
	var usersHomeDirectory: URL {
		get {
			#if os(OSX)
			/* https://developer.apple.com/forums/thread/107593 */
			if let pw = getpwuid(getuid()) {
				let url = URL(fileURLWithFileSystemRepresentation: pw.pointee.pw_dir, isDirectory: true, relativeTo: nil)
				if isAccessible(pathString: url.path, accessType: .ReadAccess) {
					return url
				}
			}
			return URL(fileURLWithPath: NSHomeDirectory())
			#else
				return URL(fileURLWithPath: NSHomeDirectory())
			#endif

		}
	}
}

