/**
 * @file	CNSymbol.swift
 * @brief	Define CNSymbol class
 * @par Copyright
 *   Copyright (C) 2021, 2022 Steel Wheels Project
 */

import Foundation

public class CNSymbol
{
	public static var shared = CNSymbol()

	public enum SymbolType: Int, CaseIterable {
		case characterA
		case chevronBackward
		case chevronDown
		case chevronForward
		case chevronUp
		case handPointUp
		case handRaised
		case line1P
		case line2P
		case line4P
		case line8P
		case line16P
		case moonStars
		case ovalLine
		case ovalFilled
		case paintbrush
		case pencil
		case pencilCircle
		case questionmark
		case rectangleFilled
		case rectangleFilledRounded
		case rectangleLine
		case rectangleLineRounded
		case sunMax
		case sunMin
		case sunMoon

		/* The return value must matched with the image file name */
		public var name: String {
			let result: String
			switch self {
			case .characterA:		result = "character_a"
			case .chevronBackward:		result = "chevron_backward"
			case .chevronDown:		result = "chevron_down"
			case .chevronForward:		result = "chevron_forward"
			case .chevronUp:		result = "chevron_up"
			case .handPointUp:		result = "hand_point_up"
			case .handRaised:		result = "hand_raised"
			case .line1P:			result = "line_1p"
			case .line2P:			result = "line_2p"
			case .line4P:			result = "line_4p"
			case .line8P:			result = "line_8p"
			case .line16P:			result = "line_16p"
			case .moonStars:		result = "moon_stars"
			case .ovalLine:			result = "oval_line"
			case .ovalFilled:		result = "oval_filled"
			case .paintbrush:		result = "paintbrush"
			case .pencil:			result = "pencil"
			case .pencilCircle:		result = "pencil_circule"
			case .questionmark:		result = "questionmark"
			case .rectangleFilled:		result = "rectangle_filled"
			case .rectangleFilledRounded:	result = "rectangle_filled_rounded"
			case .rectangleLine:		result = "rectangle_line"
			case .rectangleLineRounded:	result = "rectangle_line_rounded"
			case .sunMax:			result = "sun_max"
			case .sunMin:			result = "sun_min"
			case .sunMoon:			result = "sun_moon"
			}
			return result
		}

		public static func line(width wdt: Int) -> SymbolType {
			let result: SymbolType
			switch wdt {
			case  1: result = .line1P
			case  2: result = .line2P
			case  4: result = .line4P
			case  8: result = .line8P
			case 16: result = .line16P
			default:
				CNLog(logLevel: .error, message: "Unsupported line size: \(wdt)", atFunction: #function, inFile: #file)
				result  = .line1P
			}
			return result
		}

		public static func oval(doFill df: Bool) -> SymbolType {
			return df ? .ovalFilled : .ovalLine
		}

		public static func pencil(doFill df: Bool) -> SymbolType {
			return df ? .pencilCircle : .pencil
		}

		public static func rect(doFill df: Bool, doRound dr: Bool) -> SymbolType {
			return df ? (dr ? .rectangleFilledRounded : .rectangleFilled)
				:   (dr ? .rectangleLineRounded   : .rectangleLine  )
		}

		public static func decode(string str: String) -> SymbolType? {
			for symtyp in self.allCases {
				if symtyp.name == str {
					return symtyp
				}
			}
			return nil
		}
	}

	private init(){
	}

	public func URLOfSymbol(type sym: SymbolType) -> URL {
		if let url = CNFilePath.URLForResourceFile(fileName: sym.name, fileExtension: "png", subdirectory: "Images", forClass: CNSymbol.self){
			return url
		} else {
			CNLog(logLevel: .error, message: "Failed to get URL: \(sym.name)", atFunction: #function, inFile: #file)
			fatalError("failed to continue")
		}
	}

	public func loadImage(type sym: SymbolType) -> CNImage {
		let url = URLOfSymbol(type: sym)
		if let img = CNImage(contentsOf: url) {
			return img
		} else {
			CNLog(logLevel: .error, message: "Failed to get load image: \(sym.name)", atFunction: #function, inFile: #file)
			fatalError("failed to continue")
		}
	}
}

