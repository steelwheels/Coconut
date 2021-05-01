/*
 * @file	CNFile.swift
 * @brief	Define CNFile, CNTextFile protocols
 * @par Copyright
 *   Copyright (C) 2017-2021 Steel Wheels Project
 */

import Foundation

public class CNFile
{
	public static let EOF: Int32	= -1

	public enum Access {
		case reader
		case writer
	}

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

	public enum Str {
		case str(String)
		case endOfFile
		case null
	}

	private enum Stream {
		case handle(FileHandle)
		case pipe(Pipe)
	}

	private var mAccess:		Access
	private var mFile:		Stream
	private var mInputBuffer:	String
	private var mInputLock:		NSLock
	private var mReadDone:		Bool

	public init(access acc: Access, fileHandle handle: FileHandle){
		mAccess		= acc
		mFile		= .handle(handle)
		mInputBuffer	= ""
		mInputLock	= NSLock()
		mReadDone	= false

		switch acc {
		case .reader:
			setupCallback(fileHandle: handle)
		case .writer:
			break
		}
	}

	public init(access acc: Access, pipe pip: Pipe){
		mAccess		= acc
		mFile		= .pipe(pip)
		mInputBuffer	= ""
		mInputLock	= NSLock()
		mReadDone	= false

		switch acc {
		case .reader:
			setupCallback(fileHandle: pip.fileHandleForReading)
		case .writer:
			break
		}
	}

	private func setupCallback(fileHandle hdl: FileHandle) {
		hdl.readabilityHandler = {
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
					myself.fileHandle.readabilityHandler = nil
				}
				myself.mInputLock.unlock()
			}
		}
	}

	deinit {
		switch mAccess {
		case .reader:
			fileHandle.readabilityHandler = nil
		case .writer:
			break
		}
	}

	public func close() {
		switch mAccess {
		case .reader:
			mReadDone = true
			switch mFile {
			case .handle(let hdl):
				hdl.closeFile()
			case .pipe(let pipe):
				pipe.fileHandleForReading.closeFile()
			}
		case .writer:
			switch mFile {
			case .handle(let hdl):
				hdl.closeFile()
			case .pipe(let pipe):
				pipe.fileHandleForWriting.closeFile()
			}
		}
	}

	public func closeWritePipe(){
		switch mFile {
		case .handle(_):
			break
		case .pipe(let pipe):
			switch mAccess {
			case .reader:
				break
			case .writer:
				pipe.fileHandleForWriting.closeFile()
			}
		}
	}

	public func activateReaderHandler(enable en: Bool) {
		switch mAccess {
		case .reader:
			switch mFile {
			case .handle(let hdl):
				if en {
					setupCallback(fileHandle: hdl)
				} else {
					hdl.readabilityHandler = nil
				}
			case .pipe(let pipe):
				if en {
					setupCallback(fileHandle: pipe.fileHandleForReading)
				} else {
					pipe.fileHandleForReading.readabilityHandler = nil
				}
			}
		case .writer:
			break
		}
	}

	public var fileHandle: FileHandle { get {
		let result: FileHandle
		switch mFile {
		case .handle(let hdl):	result = hdl
		case .pipe(let pipe):
			switch mAccess {
			case .reader:
				result = pipe.fileHandleForReading
			case .writer:
				result = pipe.fileHandleForWriting
			}
		}
		return result
	}}

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

	public func gets() -> CNFile.Str {
		var result: CNFile.Str = .null
		mInputLock.lock()
		if mInputBuffer.count == 0 && mReadDone {
			result       = .endOfFile
		} else if mInputBuffer.count > 0 {
			result       = .str(mInputBuffer)
			mInputBuffer = ""
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
		mInputLock.unlock()
		return result
	}

	public func put(string str: String) {
		if let data = str.data(using: .utf8) {
			fileHandle.write(data)
		}
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

