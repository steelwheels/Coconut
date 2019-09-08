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

public enum CNStandardFileType {
	case input
	case output
	case error
}

public class CNDataFileObject: CNDataFile
{
	private var mFileHandle:	FileHandle
	private var mDidClosed:		Bool

	public required init(fileHandle handle: FileHandle){
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

public class CNTextFileObject: CNDataFileObject, CNTextFile
{
	public static let 		CHUNK_SIZE = 512
	private var mLineBuffer:	CNLineBuffer

	public required init(fileHandle handle: FileHandle) {
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
