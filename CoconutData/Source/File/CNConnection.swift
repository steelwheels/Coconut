/**
 * @file	CNPort.h
 * @brief	Define CNPort class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public class CNConnection
{
	public weak var sender: 	AnyObject?
	public weak var receiver: 	AnyObject?

	public init(){
		sender   = nil
		receiver = nil
	}
}

