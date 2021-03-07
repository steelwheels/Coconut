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

