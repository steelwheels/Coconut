/**
 * @file	CNColor.swift
 * @brief	Define CNColor class
 * @par Copyright
 *   Copyright (C) 2015-2016 Steel Wheels Project
 */

import Foundation

#if os(OSX)
public typealias CNColor = NSColor
import Darwin.ncurses
#else
public typealias CNColor = UIColor
#endif

public extension CNColor
{
	static func color(withEscapeCode code: Int32) -> CNColor? {
		let result: CNColor?
		switch code {
		case 0:		result = CNColor.black
		case 1:		result = CNColor.red
		case 2:		result = CNColor.green
		case 3:		result = CNColor.yellow
		case 4:		result = CNColor.blue
		case 5:		result = CNColor.magenta
		case 6:		result = CNColor.cyan
		case 7:		result = CNColor.white
		default:
			NSLog("Invalid escape color code: \(code)")
			result = nil
		}
		return result
	}

	func escapeCode() -> Int32 {
		let (red, green, blue, _) = self.toRGBA()
		let rbit : Int32 = red   >= 0.5 ? 1 : 0
		let gbit : Int32 = green >= 0.5 ? 1 : 0
		let bbit : Int32 = blue  >= 0.5 ? 1 : 0
		let rgb  : Int32 = (bbit << 2) | (gbit << 1) | rbit
		return rgb
	}

	func toRGBA() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
		var red 	: CGFloat = 0.0
		var green	: CGFloat = 0.0
		var blue	: CGFloat = 0.0
		var alpha	: CGFloat = 0.0
		#if os(OSX)
			if let color = self.usingColorSpace(.deviceRGB) {
				color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
			} else {
				NSLog("Failed to convert to rgb")
			}
		#else
			self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		#endif
		return (red, green, blue, alpha)
	}

	func toData() -> Data? {
		do {
			return try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
		}
		catch let err as NSError {
			NSLog("\(#file): \(err.description)")
		}
		return nil
	}

	static func decode(fromData data: Data) -> CNColor? {
		do {
			if let color = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [CNColor.self], from: data) as? CNColor {
				return color
			}
		}
		catch let err as NSError {
			NSLog("\(#file): \(err.description)")
		}
		return nil
	}

	#if os(OSX)
	/* See CoconutScript.sdef for OSTy ep definition */
	func toOSType() -> OSType {
		let result: OSType
		switch self.escapeCode() {
		case 0:		result = CNStringToFourCharCode("blak")
		case 1:		result = CNStringToFourCharCode("red ")
		case 2:		result = CNStringToFourCharCode("gren")
		case 3:		result = CNStringToFourCharCode("yell")
		case 4:		result = CNStringToFourCharCode("blue")
		case 5:		result = CNStringToFourCharCode("mgnt")
		case 6:		result = CNStringToFourCharCode("cyan")
		case 7:		result = CNStringToFourCharCode("whte")
		default:	result = CNStringToFourCharCode("blak")		// Never chosen
		}
		return result
	}

	static func decode(fromOSType type: OSType) -> CNColor? {
		for i:Int32 in 0..<8 {
			if let col = CNColor.color(withEscapeCode: i) {
				if col.toOSType() == type {
					return col
				}
			}
		}
		return nil
	}

	func toDarwinColor() -> Int32 {
		var result: Int32
		let code = self.escapeCode()
		switch code {
		case 0:	result = Darwin.COLOR_BLACK
		case 1:	result = Darwin.COLOR_RED
		case 2:	result = Darwin.COLOR_GREEN
		case 3:	result = Darwin.COLOR_YELLOW
		case 4:	result = Darwin.COLOR_BLUE
		case 5:	result = Darwin.COLOR_MAGENTA
		case 6:	result = Darwin.COLOR_CYAN
		case 7:	result = Darwin.COLOR_WHITE
		default:
			NSLog("Invalid escape color code: \(code)")
			result = Darwin.COLOR_BLACK
		}
		return result
	}
	#endif

	var rgbName: String {
		get {
			let result: String
			switch self.escapeCode() {
			case 0:		result = "black"
			case 1:		result = "red"
			case 2:		result = "green"
			case 3:		result = "yellow"
			case 4:		result = "blue"
			case 5:		result = "magenta"
			case 6:		result = "cyan"
			case 7:		result = "white"
			default:	result = "<UNKNOWN>"
			}
			return result
		}
	}
}

