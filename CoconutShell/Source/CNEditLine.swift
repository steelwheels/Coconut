/*
 * @file	CNEditLine.h
 * @brief	Define CNEditLine class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation
import CNEditLineCore

public class CNEditLine
{
	private var mEditLineCore:	CNEditLineCore

	public init(){
		mEditLineCore = CNEditLineCore()
	}

	public func setup(programName name: String, console cons: CNFileConsole){
		mEditLineCore.setup(name, withInput: cons.inputHandle, withOutput: cons.outputHandle, withError: cons.errorHandle)
	}

	public var doBuffering: Bool {
		get { return mEditLineCore.bufferedMode() }
		set(val) { mEditLineCore.setBufferedMode(val) }
	}

	public func finalize(){
		mEditLineCore.finalize()
	}

	public func gets() -> String? {
		return mEditLineCore.gets()
	}
}
