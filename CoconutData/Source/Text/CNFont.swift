/**
 * @file	CNFont.swift
 * @brief	Define CNFont class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
	public typealias CNFont = NSFont
#else
	import UIKit
	public typealias CNFont = UIFont
#endif

