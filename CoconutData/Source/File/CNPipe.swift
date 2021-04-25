/**
 * @file	CNPipe.swift
 * @brief	Define CNPipe class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNPipe
{
	private var mPipe:	Pipe
	private var mReader:	CNFile
	private var mWriter:	CNFile

	public var pipe: Pipe     { get { return mPipe		}}
	public var reader: CNFile { get { return mReader	}}
	public var writer: CNFile { get { return mWriter	}}

	public init(){
		mPipe	= Pipe()
		mReader	= CNFile(access: .reader, pipe: mPipe)
		mWriter	= CNFile(access: .writer, pipe: mPipe)
	}
}
