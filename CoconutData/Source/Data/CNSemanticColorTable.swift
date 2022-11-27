/**
 * @file	CNSemanticColorTable.m
 * @brief	Define CNSemanticColorTable class
 * @par Copyright
 *   Copyright (C) 2022  Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import Foundation

public class CNSemanticColorTable
{
	public static var foregroundTextColor: CNColor { get {
		#if os(OSX)
			return CNColor.textColor
		#else
			return CNColor.label
		#endif
	}}

	public static var backgroundTextColor: CNColor { get {
		#if os(OSX)
			return CNColor.textBackgroundColor
		#else
			return CNColor.systemBackground
		#endif
	}}
}

