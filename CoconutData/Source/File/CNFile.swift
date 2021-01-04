/*
 * @file	CNFile.swift
 * @brief	Define CNFile, CNTextFile protocols
 * @par Copyright
 *   Copyright (C) 2017, 2018 Steel Wheels Project
 */

import Foundation

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

