/**
 * @file	CNShellProcess.swift
 * @brief	Define CNShellProcess class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

#if os(OSX)

open class CNShellProcess: CNProcess
{
	private var mEnvironment:	CNShellEnvironment
	private var mConfig:		CNConfig

	public init(input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNShellEnvironment, config conf: CNConfig, terminationHander termhdlr: CNProcess.TerminationHandler?) {
		mEnvironment	= env
		mConfig		= conf
		super.init(input: instrm, output: outstrm, error: errstrm, terminationHander: termhdlr)
	}

	public var environment: CNShellEnvironment	{ get { return mEnvironment	}}
	public var config: CNConfig			{ get { return mConfig		}}
}

#endif // os(OSX)

