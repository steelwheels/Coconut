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

	public func getl() -> String? {
		/* Read input into the buffer */
		updateInputBuffer()
		/* Get line from the buffer */
		let start = mInputBuffer.startIndex
		let end   = mInputBuffer.endIndex
		var idx   = start
		while idx < end {
			let c = mInputBuffer[idx]
			if c == "\n" {
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

	private func updateInputBuffer() {
		if let str = String(data: mFileHandle.availableData, encoding: .utf8) {
			mInputBuffer.append(contentsOf: str)
		} else {
			NSLog("Failed to convert data into string")
		}
	}
}

