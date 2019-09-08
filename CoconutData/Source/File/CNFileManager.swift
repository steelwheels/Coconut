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

public extension FileManager
{
	func fileExists(atURL url: URL) -> Bool {
		return fileExists(atPath: url.absoluteString)
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
}

public enum CNFileAccessType {
	case ReadAccess
	case WriteAccess
	case AppendAccess
}

public func CNOpenFile(filePath path: String, accessType acctyp: CNFileAccessType) -> (CNTextFile?, NSError?)
{
	do {
		var file: CNTextFile
		switch acctyp {
		case .ReadAccess:
			let fileurl = pathToURL(filePath: path)
			let handle = try FileHandle(forReadingFrom: fileurl)
			file = CNTextFileObject(fileHandle: handle)
		case .WriteAccess:
			let handle = try fileHandleToWrite(filePath: path, withAppend: false)
			file = CNTextFileObject(fileHandle: handle)
		case .AppendAccess:
			let handle = try fileHandleToWrite(filePath: path, withAppend: true)
			file = CNTextFileObject(fileHandle: handle)
		}
		return (file, nil)
	} catch let err as NSError {
		return (nil, err)
	} catch {
		let err = NSError.fileError(message: "Failed to open file \"\(path)\"")
		return (nil, err)
	}
}

public func CNOpenFile(URL url: URL, accessType acctyp: CNFileAccessType) -> (CNTextFile?, NSError?)
{
	do {
		var file: CNTextFile
		switch acctyp {
		case .ReadAccess:
			let handle = try FileHandle(forReadingFrom: url)
			file = CNTextFileObject(fileHandle: handle)
		case .WriteAccess:
			let handle = try fileHandleToWrite(URL: url, withAppend: false)
			file = CNTextFileObject(fileHandle: handle)
		case .AppendAccess:
			let handle = try fileHandleToWrite(URL: url, withAppend: true)
			file = CNTextFileObject(fileHandle: handle)
		}
		return (file, nil)
	} catch let err as NSError {
		return (nil, err)
	} catch {
		let path = url.absoluteString
		let err  = NSError.fileError(message: "Failed to open file \"\(path)\"")
		return (nil, err)
	}
}

public func CNOpenFile(fileHandle handle: FileHandle) -> CNTextFile
{
	return CNTextFileObject(fileHandle: handle)
}

private func pathToURL(filePath path: String) -> URL {
	let curdir = FileManager.default.currentDirectoryPath
	let cururl = URL(fileURLWithPath: curdir, isDirectory: true)
	return URL(fileURLWithPath: path, relativeTo: cururl)
}

private func fileHandleToWrite(filePath path: String, withAppend doappend: Bool) throws -> FileHandle
{
	let fmanager = FileManager.default
	if !fmanager.fileExists(atPath: path) {
		if !fmanager.createFile(atPath: path, contents: nil, attributes: nil) {
			throw NSError.fileError(message: "Can not create file: \(path)")
		}
	}
	let url = pathToURL(filePath: path)
	let handle = try FileHandle(forWritingTo: url)
	if doappend {
		handle.seekToEndOfFile()
	}
	return handle
}

private func fileHandleToWrite(URL url: URL, withAppend doappend: Bool) throws -> FileHandle
{
	let fmanager = FileManager.default
	if !fmanager.fileExists(atURL: url) {
		if !fmanager.createFile(atURL: url, contents: nil, attributes: nil) {
			throw NSError.fileError(message: "Can not create file: \(url.absoluteString)")
		}
	}
	let handle = try FileHandle(forWritingTo: url)
	if doappend {
		handle.seekToEndOfFile()
	}
	return handle
}

