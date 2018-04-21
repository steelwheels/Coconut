/*
 * @file	CNFile.swift
 * @brief	Define CNFile, CNTextFile protocols
 * @par Copyright
 *   Copyright (C) 2017, 2018 Steel Wheels Project
 */

import Foundation

public protocol CNFile
{
	func close()
	func isClosed() -> Bool

	func getData() -> Data
	func put(data d: Data)
}

public protocol CNDataFile: CNFile
{	var  fileHandle: FileHandle { get }

}

public protocol CNTextFile: CNDataFile
{
	func getChar() -> Character?
	func getLine() -> String?
	func getAll() -> String?

	func put(char c: Character)
	func put(string s: String)
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
		fmanager.createFile(atPath: path, contents: nil, attributes: nil)
	}
	let url = pathToURL(filePath: path)
	let handle = try FileHandle(forWritingTo: url)
	if doappend {
		handle.seekToEndOfFile()
	}
	return handle
}

public enum CNStandardFileType {
	case input
	case output
	case error
}

private class CNStandardFileObject
{
	static let shared: CNStandardFileObject = CNStandardFileObject()

	public var input:	CNTextFileObject
	public var output:	CNTextFileObject
	public var error:	CNTextFileObject

	private init(){
		input  = CNTextFileObject(fileHandle: FileHandle.standardInput)
		output = CNTextFileObject(fileHandle: FileHandle.standardOutput)
		error  = CNTextFileObject(fileHandle: FileHandle.standardError)
	}
}

public func CNStandardFile(type t: CNStandardFileType) -> CNTextFile
{
	var file: CNTextFile
	switch t {
	case .input:	file = CNStandardFileObject.shared.input
	case .output:	file = CNStandardFileObject.shared.output
	case .error:	file = CNStandardFileObject.shared.error
	}
	return file
}

private class CNDataFileObject: CNDataFile
{
	private var mFileHandle:	FileHandle
	private var mDidClosed:		Bool

	public init(fileHandle handle: FileHandle){
		mFileHandle = handle
		mDidClosed  = false
	}

	deinit {
		close()
	}

	public var fileHandle: FileHandle {
		get { return mFileHandle }
	}

	public func close() {
		if !mDidClosed {
			mFileHandle.closeFile()
			mDidClosed = true
		}
	}

	public func isClosed() -> Bool {
		return mDidClosed
	}

	public func getData() -> Data {
		return mFileHandle.availableData
	}

	public func getData(ofLength len: Int) -> Data {
		return mFileHandle.readData(ofLength: len)
	}

	public func getAllData() -> Data {
		return mFileHandle.readDataToEndOfFile()
	}

	public func put(data d: Data) {
		mFileHandle.write(d)
	}
}

private class CNTextFileObject: CNDataFileObject, CNTextFile
{
	public static let 		CHUNK_SIZE = 512
	private var mLineBuffer:	CNLineBuffer

	public override init(fileHandle handle: FileHandle) {
		mLineBuffer = CNLineBuffer()
		super.init(fileHandle: handle)
	}

	public func getChar() -> Character? {
		while !isClosed() {
			if let c = mLineBuffer.getChar() {
				return c
			} else {
				let newdata = getData(ofLength: CNLineBuffer.CHUNK_SIZE)
				if newdata.count == 0 {
					/* end of file */
					close()
				} else {
					mLineBuffer.appendData(data: newdata)
				}
			}
		}
		return nil
	}

	public func getLine() -> String? {
		var result: String?	= nil
		while true {
			if let c = getChar() {
				var newres: String
				if let str = result {
					newres = str
				} else {
					newres = ""
				}
				newres.append(c)
				if c == "\n" {
					return newres
				}
				result = newres
			} else {
				return result
			}
		}
	}

	public func getAll() -> String? {
		return String(data: getAllData(), encoding: .utf8)
	}

	public func put(char c: Character) {
		let str  = String(c)
		if let data = str.data(using: .utf8) {
			put(data: data)
		} else {
			NSLog("Failed to put")
		}
	}

	public func put(string s: String) {
		if let data = s.data(using: .utf8) {
			put(data: data)
		} else {
			NSLog("Failed to put")
		}
	}
}

private class CNLineBuffer
{
	public static let 	CHUNK_SIZE = 512
	private var 		mBuffer: 	Array<Character>
	private var		mCurrentIndex:	Int
	private var		mLastIndex:	Int

	public init(){
		mBuffer		= []
		mCurrentIndex	= 0
		mLastIndex	= 0
	}

	public func appendData(data d: Data) {
		if let str = String(data: d, encoding: .utf8) {
			let count = mBuffer.count
			for c in str {
				if mLastIndex < count {
					mBuffer[mLastIndex] = c
				} else {
					mBuffer.append(c)
				}
				mLastIndex += 1
			}

		} else {
			NSLog("Failed to append")
		}
	}

	public func getChar() -> Character? {
		let result: Character?
		if mCurrentIndex < mLastIndex {
			result = mBuffer[mCurrentIndex]
			mCurrentIndex += 1
			if mCurrentIndex > 512 {
				let rmnum = mCurrentIndex
				mBuffer.removeSubrange(0..<rmnum)
				mCurrentIndex	-= rmnum
				mLastIndex	-= rmnum
			}
		} else {
			result = nil
		}
		return result
	}
}


