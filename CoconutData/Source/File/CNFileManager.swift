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
	case 	ok(_ file: CNTextFile)
	case	error(_ error: NSError)
}

public enum CNFileAccessType {
	case ReadAccess
	case WriteAccess
	case AppendAccess
}

public extension FileManager
{
	/* If you give full path to "relpath", "base" directory will be ignored */
	func fullPathURL(relativePath relpath: String, baseDirectory base: String) -> URL {
		let baseurl = URL(fileURLWithPath: base, isDirectory: true)
		return URL(fileURLWithPath: relpath, relativeTo: baseurl)
	}

	func fileExists(atURL url: URL) -> Bool {
		return fileExists(atPath: url.path)
	}

	func createFile(atURL url: URL, contents data: Data?, attributes attr: [FileAttributeKey:Any]?) -> Bool {
		return createFile(atPath: url.absoluteString, contents: data, attributes: attr)
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
			var file: CNTextFile
			switch acctyp {
			case .ReadAccess:
				let handle = try FileHandle(forReadingFrom: url)
				file = CNTextFile(fileHandle: handle)
			case .WriteAccess:
				let handle = try FileHandle(forReadingFrom: url)
				file = CNTextFile(fileHandle: handle)
			case .AppendAccess:
				let handle = try FileHandle(forWritingTo: url)
				file = CNTextFile(fileHandle: handle)
			}
			return .ok(file)
		} catch let err as NSError {
			return .error(err)
		} catch {
			let err = NSError.fileError(message: "Failed to open URL \"\(url.absoluteString)\"")
			return .error(err)
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
		let pathstr = NSString(string: path)
		for mode in modes {
			if access(pathstr.fileSystemRepresentation, mode) != 0 {
				return false
			}
		}
		return true
	}
}

