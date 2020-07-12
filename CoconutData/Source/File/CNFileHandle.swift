/*
 * @file	CNFileHandle.swift
 * @brief	Define CNFileHandle class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation
import Darwin.POSIX.termios
import Darwin

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

extension FileHandle
{
	public func write(string str: String) {
		if let data = str.data(using: .utf8) {
			self.write(data)
		} else {
			NSLog("Failed convert at \(#file):\(#line)")
		}
	}

	public var availableString: String {
		get {
			let data = self.availableData
			if let str = String.stringFromData(data: data) {
				return str
			} else {
				NSLog("Failed convert at \(#file):\(#line)")
				return ""
			}
		}
	}

	public struct LocalMode {
		public var	icannon:	Bool
		public var	echo:		Bool

		public init(){
			icannon		= false
			echo		= false
		}

		public var description: String {
			get {
				return "{icannon:\(self.icannon), echo:\(self.echo)}"
			}
		}
	}

	public var localMode: LocalMode? {
		get {
			var raw = Darwin.termios()
			if Darwin.tcgetattr(self.fileDescriptor, &raw) == 0 {
				let lflag  = raw.c_lflag
				var result = LocalMode()
				result.icannon	= (lflag & UInt(ICANON)) != 0
				result.echo	= (lflag & UInt(ECHO)) != 0
				return result
			} else {
				return nil
			}
		}
	}

	public func isRawMode() -> Bool? {
		if let mode = self.localMode {
			return !mode.icannon
		} else {
			return nil
		}
	}

	public func setRawMode(enable enbl: Bool) -> Int32 {
		var raw = Darwin.termios()
		if Darwin.tcgetattr(self.fileDescriptor, &raw) == 0 {
			if enbl {
				raw.c_lflag &= ~UInt(ECHO | ICANON)
			} else {
				raw.c_lflag |=  UInt(ECHO | ICANON)
			}
			return tcsetattr(self.fileDescriptor, TCSAFLUSH, &raw)
		} else {
			return -1
		}
	}

	public func isAtty() -> Bool {
		return Darwin.isatty(self.fileDescriptor) != 0
	}
}

