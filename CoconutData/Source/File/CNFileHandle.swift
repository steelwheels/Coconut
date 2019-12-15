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
			if let str = String(data: data, encoding: .utf8) {
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
}

/*
//
//  Termios.swift
//  Termios
//
//  Created by Neil Pankey on 3/20/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import ErrNo
import Result

/// Swift wrapper around the raw C `termios` structure.
public struct Termios {
    // MARK: Constructors
    /// Constructs an empty `Termios` structure.
    public init() {
        self.init(termios())
    }

    /// Constructs a `Termios` structure from a given file descriptor `fd`.
    public static func fetch(fd: Int32) -> Result<Termios, ErrNo> {
        var raw = termios()
        return tryMap(tcgetattr(fd, &raw)) { _ in Termios(raw) }
    }

    // MARK: Properties
    /// Input flags
    public var inputFlags: InputFlags {
        get { return InputFlags(raw.c_iflag) }
        set { raw.c_iflag = newValue.rawValue }
    }

    /// Output flags
    public var outputFlags: OutputFlags {
        get { return OutputFlags(raw.c_oflag) }
        set { raw.c_oflag = newValue.rawValue }
    }

    /// Control flags
    public var controlFlags: ControlFlags {
        get { return ControlFlags(raw.c_cflag) }
        set { raw.c_cflag = newValue.rawValue }
    }

    /// Local flags
    public var localFlags: LocalFlags {
        get { return LocalFlags(raw.c_lflag) }
        set { raw.c_lflag = newValue.rawValue }
    }

    /// Input speed
    public var inputSpeed: UInt {
        return raw.c_ispeed
    }

    /// Output speed
    public var outputSpeed: UInt {
        return raw.c_ispeed
    }

    // MARK: Operations
    /// Updates the file descriptor's `Termios` structure.
    public mutating func update(fd: Int32) -> Result<(), ErrNo> {
        return try(tcsetattr(fd, TCSANOW, &raw))
    }

    /// Set the input speed.
    public mutating func setInputSpeed(baud: UInt) -> Result<(), ErrNo> {
        return try(cfsetispeed(&raw, baud))
    }

    /// Set the output speed.
    public mutating func setOutputSpeed(baud: UInt) -> Result<(), ErrNo> {
        return try(cfsetospeed(&raw, baud))
    }

    /// Set both input and output speed.
    public mutating func setSpeed(baud: UInt) -> Result<(), ErrNo> {
        return try(cfsetspeed(&raw, baud))
    }

    // MARK: Private
    /// Wraps the `termios` structure.
    private init(_ termios: Darwin.termios) {
        raw = termios
    }

    /// The wrapped termios struct.
    private var raw: termios
}
*/
