/**
 * @file	CNColor.swift
 * @brief	Define CNColor class
 * @par Copyright
 *   Copyright (C) 2015-2021 Steel Wheels Project
 */

import Foundation

#if os(OSX)
import Cocoa
public typealias CNColor = NSColor
//import Darwin.ncurses
#else
import UIKit
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
			CNLog(logLevel: .error, message: "Invalid escape color code: \(code)")
			result = nil
		}
		return result
	}

	convenience init?(value val: Dictionary<String, CNValue>) {
		if let rval = val["r"], let gval = val["g"], let bval = val["b"], let aval = val["a"] {
			if let rnum = rval.toNumber(), let gnum = gval.toNumber(), let bnum = bval.toNumber(), let anum = aval.toNumber() {
				let r : CGFloat = CGFloat(rnum.floatValue)
				let g : CGFloat = CGFloat(gnum.floatValue)
				let b : CGFloat = CGFloat(bnum.floatValue)
				let a : CGFloat = CGFloat(anum.floatValue)
				#if os(OSX)
				self.init(calibratedRed: r, green: g, blue: b, alpha: a)
				#else
				self.init(red: r, green: g, blue: b, alpha: a)
				#endif
			}
		}
		return nil
	}

	var isClear: Bool {
		get { return self.alphaComponent == 0.0 }
	}

	func escapeCode() -> Int32 {
		let (red, green, blue, _) = self.toRGBA()
		let rbit : Int32 = red   >= 0.5 ? 1 : 0
		let gbit : Int32 = green >= 0.5 ? 1 : 0
		let bbit : Int32 = blue  >= 0.5 ? 1 : 0
		let rgb  : Int32 = (bbit << 2) | (gbit << 1) | rbit
		return rgb
	}

	#if os(iOS)
	var redComponent: CGFloat {
		get {
			let (red, _, _, _) = self.toRGBA()
			return red
		}
	}
	var greenComponent: CGFloat {
		get {
			let (_, green, _, _) = self.toRGBA()
			return green
		}
	}
	var blueComponent: CGFloat {
		get {
			let (_, _, blue, _) = self.toRGBA()
			return blue
		}
	}
	var alphaComponent: CGFloat {
		get {
			let (_, _, _, alpha) = self.toRGBA()
			return alpha
		}
	}
	#endif

	func toRGBA() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
		var red 	: CGFloat = 0.0
		var green	: CGFloat = 0.0
		var blue	: CGFloat = 0.0
		var alpha	: CGFloat = 0.0
		#if os(OSX)
			if let color = self.usingColorSpace(.deviceRGB) {
				color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
			} else {
				CNLog(logLevel: .error, message: "Failed to convert to rgb")
			}
		#else
			self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		#endif
		return (red, green, blue, alpha)
	}

	func toValue() -> Dictionary<String, CNValue> {
		let (r, g, b, a) = self.toRGBA()
		let result: Dictionary<String, CNValue> = [
			"r":	CNValue.numberValue(NSNumber(floatLiteral: Double(r))),
			"g":	CNValue.numberValue(NSNumber(floatLiteral: Double(g))),
			"b":	CNValue.numberValue(NSNumber(floatLiteral: Double(b))),
			"a":	CNValue.numberValue(NSNumber(floatLiteral: Double(a)))
		]
		return result
	}

	func toData() -> Data? {
		do {
			return try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
		}
		catch let err as NSError {
			CNLog(logLevel: .error, message: "\(#file): \(err.description)")
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
			CNLog(logLevel: .error, message: "\(#file): \(err.description)")
		}
		return nil
	}

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

