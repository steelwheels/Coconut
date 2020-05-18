/**
 * @file  CNScriptThread.swift
 * @brief Define CNScriptThread class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

open class CNScriptThread: CNThread
{
	private var mTerminalInfo:	CNTerminalInfo
	private var mInputFileStream:	CNFileStream
	private var mRepeaterPipe:	Pipe

	public override init(processManager mgr: CNProcessManager, queue disque: DispatchQueue, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNEnvironment)
	{
		/* Setup terminal info */
		mTerminalInfo    = CNTerminalInfo(width: 80, height: 25)
		mInputFileStream = instrm
		let _ = mInputFileStream.setRawMode(enable: true)

		/* Assign input pipe */
		mRepeaterPipe = Pipe()
		super.init(processManager: mgr, queue: disque, input: .pipe(mRepeaterPipe), output: outstrm, error: errstrm, environment: env)

		/* Get input handler */
		let input: FileHandle
		switch instrm {
		case .null:			input = .nullDevice
		case .fileHandle(let hdl):	input = hdl
		case .pipe(let pipe):		input = pipe.fileHandleForReading
		}

		/* Get error handler */
		let error: FileHandle
		switch errstrm {
		case .null:			error = .nullDevice
		case .fileHandle(let hdl):	error = hdl
		case .pipe(let pipe):		error = pipe.fileHandleForWriting
		}

		/* Insert pipe */
		connectInput(input: input, output: mRepeaterPipe.fileHandleForWriting, error: error)
	}

	deinit {
		let _ = mInputFileStream.setRawMode(enable: false)
	}

	public func setup() {
		/* Request screen size */
		let reqsz  = CNEscapeCode.requestScreenSize
		self.console.print(string: reqsz.encode())
	}

	private func connectInput(input inhdl: FileHandle, output outhdl: FileHandle, error errhdl: FileHandle) {
		inhdl.readabilityHandler = {
			(_ hdl: FileHandle) -> Void in
			if let str = String(data: hdl.availableData, encoding: .utf8) {
				switch CNEscapeCode.decode(string: str) {
				case .ok(let codes):
					for code in codes {
						self.write(escapeCode: code, output: outhdl)
					}
				case .error(let err):
					let msg = "[Error] " + err.description() + "\n"
					errhdl.write(string: msg)
				}
			}
		}
	}

	private func write(escapeCode code: CNEscapeCode, output outhdl: FileHandle) {
		var doskip = false
		switch code {
		case .screenSize(let width, let height):
			//console.error(string: "screenSize \(width) x \(height)")
			mTerminalInfo.width  = width
			mTerminalInfo.height = height
			doskip = true
		default:
			break
		}
		if !doskip {
			outhdl.write(string: code.encode())
		}
	}
}

