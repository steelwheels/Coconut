/**
 * @file	CNSymbol.swift
 * @brief	Define CNSymbol class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNSymbol
{
	public static var shared = CNSymbol()

	public enum SymbolType {
		case characterA
		case chevronBackward
		case chevronForward
		case handRaised
		case paintbrush
		case pencil
		case questionmark

		public var name: String {
			let result: String
			switch self {
			case .characterA:	result = "character-a"
			case .chevronBackward:	result = "chevron-backward"
			case .chevronForward:	result = "chevron-forward"
			case .handRaised:	result = "hand-raised"
			case .paintbrush:	result = "paintbrush"
			case .pencil:		result = "pencil"
			case .questionmark:	result = "questionmark"
			}
			return result
		}
	}

	private init(){
	}

	public func load(symbol sym: SymbolType) -> CNImage {
		if let url = CNFilePath.URLForResourceFile(fileName: sym.name, fileExtension: "png", subdirectory: "Images", forClass: CNSymbol.self){
			if let img = CNImage(contentsOf: url) {
				return img
			} else {
				CNLog(logLevel: .error, message: "Failed load image: \(sym.name)", atFunction: #function, inFile: #file)
			}
		} else {
			CNLog(logLevel: .error, message: "Failed to get URL: \(sym.name)", atFunction: #function, inFile: #file)
		}
		return CNImage() // empty image
	}
}

