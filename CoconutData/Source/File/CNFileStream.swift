/*
 * @file	CNFileStream.swift
 * @brief	Define CNFileStream class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public enum CNFileStream
{
	case null
	case fileHandle(FileHandle)
	case pipe(Pipe)

	public func isRawMode() -> Bool? {
		let result: Bool?
		switch self {
		case .null:
			result = nil
		case .fileHandle(let hdl):
			result = hdl.isRawMode()
		case .pipe(let pipe):
			result = pipe.fileHandleForReading.isRawMode()
		}
		return result
	}

	public func setRawMode(enable enbl: Bool) -> Int32 {
		let result: Int32
		switch self {
		case .null:
			result = 0
		case .fileHandle(let hdl):
			result = hdl.setRawMode(enable: enbl)
		case .pipe(let pipe):
			result = pipe.fileHandleForReading.setRawMode(enable: enbl)
		}
		return result
	}

	public static func streamToFileHandle(stream strm: CNFileStream, forInside inside: Bool, isInput input: Bool) -> FileHandle {
		let result: FileHandle
		switch strm {
		case .null:
			result = FileHandle.nullDevice
		case .fileHandle(let hdl):
			result = hdl
		case .pipe(let pipe):
			if inside {
				if input {
					result = pipe.fileHandleForReading
				} else {
					result = pipe.fileHandleForWriting
				}
			} else {
				if input {
					result = pipe.fileHandleForWriting
				} else {
					result = pipe.fileHandleForReading
				}
			}
		}
		return result
	}

	public static func streamToAny(stream strm: CNFileStream) -> Any {
		let result: Any
		switch strm {
		case .null:			result = FileHandle.nullDevice
		case .fileHandle(let hdl):	result = hdl
		case .pipe(let pipe):		result = pipe
		}
		return result
	}
}

