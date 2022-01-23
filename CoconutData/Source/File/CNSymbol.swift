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

	public enum SymbolType {
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
		case oval(Bool)			// (doFill)
		case paintbrush
		case pencil(Bool)		// (doFill)
		case rectangle(Bool, Bool)	// (doFill, rounded)
		case questionmark

		public var name: String {
			let result: String
			switch self {
			case .characterA:	result = "character-a"
			case .chevronBackward:	result = "chevron-backward"
			case .chevronDown:	result = "chevron-down"
			case .chevronForward:	result = "chevron-forward"
			case .chevronUp:	result = "chevron-up"
			case .handPointUp:	result = "hand-point-up"
			case .handRaised:	result = "hand-raised"
			case .line1P:		result = "line-1p"
			case .line2P:		result = "line-2p"
			case .line4P:		result = "line-4p"
			case .line8P:		result = "line-8p"
			case .line16P:		result = "line-16p"
			case .oval(let dofill):
				if dofill {
					result = "oval-filled"
				} else {
					result = "oval"
				}
			case .paintbrush:	result = "paintbrush"
			case .pencil(let dofill):
				if dofill {
					result = "pencil-circule"
				} else {
					result = "pencil"
				}
			case .rectangle(let dofill, let isrounded):
				if dofill {
					if isrounded {
						result = "rectangle-filled-rounded"
					} else {
						result = "rectangle-filled"
					}
				} else {
					if isrounded {
						result = "rectangle-rounded"
					} else {
						result = "rectangle"
					}
				}
			case .questionmark:	result = "questionmark"
			}
			return result
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

