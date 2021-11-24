/**
 * @file	CNType.swift
 * @brief	Define class and types
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif
import Foundation

#if os(OSX)
public typealias CNEdgeInsets		= NSEdgeInsets
public typealias CNImage		= NSImage
#else
public typealias CNEdgeInsets		= UIEdgeInsets
public typealias CNImage		= UIImage
#endif

