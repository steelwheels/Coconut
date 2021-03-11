/*
 * @file	CNFile.swift
 * @brief	Define CNFile, CNTextFile protocols
 * @par Copyright
 *   Copyright (C) 2017, 2018 Steel Wheels Project
 */

import Foundation

public class CNFile
{
	public static let EOF: Int	= -1

	public enum Char {
		case char(Character)
		case endOfFile
		case null
	}

	public enum Line {
		case line(String)
		case endOfFile
		case null
	}

	private var mFileHandle:	FileHandle
	private var mInputBuffer:	String
	private var mInputLock:		NSLock
	private var mReadDone:		Bool

	public init(fileHandle handle: FileHandle){
		mFileHandle	= handle
		mInputBuffer	= ""
		mInputLock	= NSLock()
		mReadDone	= false

		mFileHandle.readabilityHandler = {
			[weak self] (_ hdl: FileHandle) -> Void in
			if let myself = self {
				myself.mInputLock.lock()
				let data = hdl.availableData
				if data.count > 0 {
					if let str = String(data: data, encoding: .utf8) {
						myself.mInputBuffer += str
					} else {
						NSLog("[Error] Failed to decode input at \(#function)")
					}
				} else {
					myself.mReadDone = true
					myself.mFileHandle.readabilityHandler = nil
				}
				myself.mInputLock.unlock()
			}
		}
	}

	deinit {
		mFileHandle.readabilityHandler = nil
	}

	public func close() {
		mFileHandle.closeFile()
		mReadDone = true
	}

	public var fileHandle:	FileHandle { get { return mFileHandle	}}
	public var readDone:	Bool	   { get { return mReadDone	}}

	public func getc() -> CNFile.Char {
		var result: CNFile.Char = .null
		mInputLock.lock()
		if mInputBuffer.count == 0 && mReadDone {
			result = .endOfFile
		} else if let c = mInputBuffer.first {
			mInputBuffer.removeFirst()
			result = .char(c)
		}
		mInputLock.unlock()
		return result
	}

	public func getl() -> CNFile.Line {
		var result: CNFile.Line = .null
		mInputLock.lock()
		if mInputBuffer.count == 0 && mReadDone {
			result = .endOfFile
		} else if mInputBuffer.count > 0 {
			let start = mInputBuffer.startIndex
			let end   = mInputBuffer.endIndex
			var idx   = start
			while idx < end {
				let c = mInputBuffer[idx]
				if c.isNewline {
					let next = mInputBuffer.index(after: idx)
					let head = mInputBuffer.prefix(upTo: next)
					let tail = mInputBuffer.suffix(from: next)
					mInputBuffer = String(tail)
					result = .line(String(head))
					break
				}
				idx = mInputBuffer.index(after: idx)
			}
			/* newline is not found */
			if mReadDone {
				result       = .line(String(mInputBuffer))
				mInputBuffer = ""
			}
		}
		return result
	}

	public func put(string str: String) {
		mFileHandle.write(string: str)
	}
}

/*
public class CNTextFile
{
	private var mFileHandle:	FileHandle
	private var mInputBuffer:	String

	public init(fileHandle handle: FileHandle){
		mFileHandle	= handle
		mInputBuffer	= ""
	}

	public var fileHandle: FileHandle {
		get { return mFileHandle }
	}

	public func close() {
		mFileHandle.closeFile()
	}

	public func put(string str: String) {
		mFileHandle.write(string: str)
	}

	public func getc() -> Character? {
		/* Read input into the buffer */
		updateInputBuffer()
		/* Get character from the buffer */
		if let c = mInputBuffer.first {
			mInputBuffer.removeFirst()
			return c
		} else {
			return nil
		}
	}

	/* When there are no new input, this method returns nil */
	public func getl() -> String? {
		/* Read input into the buffer */
		updateInputBuffer()
		/* Get line from the buffer */
		let start = mInputBuffer.startIndex
		let end   = mInputBuffer.endIndex
		var idx   = start
		while idx < end {
			let c = mInputBuffer[idx]
			if c.isNewline {
				let next = mInputBuffer.index(after: idx)
				let head = mInputBuffer.prefix(upTo: next)
				let tail = mInputBuffer.suffix(from: next)
				mInputBuffer = String(tail)
				return String(head)
			}
			idx = mInputBuffer.index(after: idx)
		}
		return nil
	}

	public func isRawMode() -> Bool {
		if let mode = mFileHandle.isRawMode() {
			return mode
		} else {
			return false
		}
	}

	private func updateInputBuffer() {
		if let str = String.stringFromData(data: mFileHandle.availableData) {
			mInputBuffer.append(contentsOf: str)
		} else {
			NSLog("Failed to convert data into string")
		}
	}
}

*/

