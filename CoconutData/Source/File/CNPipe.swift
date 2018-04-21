/*
 * @file	CNPipe.swift
 * @brief	Define CNPipe class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNPipe
{
	private var mPipe		: Pipe
	private var mInputFile		: CNTextFile
	private var mOutputFile		: CNTextFile

	public init(){
		mPipe		= Pipe()
		mInputFile	= CNOpenFile(fileHandle: mPipe.fileHandleForWriting)
		mOutputFile	= CNOpenFile(fileHandle: mPipe.fileHandleForReading)
	}

	public var pipe: Pipe 		  { get { return mPipe       }}
	public var inputFile: CNTextFile  { get { return mInputFile  }}
	public var outputFile: CNTextFile { get { return mOutputFile }}
}
