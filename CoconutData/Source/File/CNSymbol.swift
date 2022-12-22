/**
 * @file	CNSymbol.swift
 * @brief	Define CNSymbol class
 * @par Copyright
 *   Copyright (C) 2021, 2022 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import Foundation

public enum CNSymbolSize: Int
{
	public static  let typeName = "SymbolSize"

	case small	= 128
	case regular	= 256
	case large	= 384

	public func toPointSize() -> CGFloat {
		return CGFloat(self.rawValue)
	}

	public func toSize() -> CGSize {
		let ptsize = CGFloat(self.rawValue)
		return CGSize(width: ptsize, height: ptsize)
	}

	public func size(fitIn targsize: CGSize) -> CGSize {
		let dolarge, doregular: Bool
		switch self {
		case .large:	dolarge = true  ; doregular = true
		case .regular:	dolarge = false ; doregular = true
		case .small:	dolarge = false ; doregular = false
		}
		let targpoint = min(targsize.width, targsize.height)

		let result: CGFloat
		if dolarge && targpoint >= CGFloat(CNSymbolSize.large.rawValue) {
			result = CGFloat(CNSymbolSize.large.rawValue)
		} else if doregular && targpoint >= CGFloat(CNSymbolSize.regular.rawValue) {
			result = CGFloat(CNSymbolSize.regular.rawValue)
		} else if targpoint >= CGFloat(CNSymbolSize.small.rawValue) {
			result = CGFloat(CNSymbolSize.small.rawValue)
		} else {
			result = targpoint
		}
		return CGSize(width: result, height: result)
	}
}

private let imagesInResource: Dictionary<String, String> = [ // (name, filename)
	/* Custom images */
	"line.1p"		: "line_1p.png",
	"line.2p"		: "line_2p.png",
	"line.4p"		: "line_4p.png",
	"line.8p"		: "line_8p.png",
	"line.16p"		: "line_16p.png",

	/* Following items are built-in at BigSur */
	"character"		: "character.png",
	"chevron.backward"	: "chevron_backward.png",
	"chevron.down"		: "chevron_down.png",
	"chevron.forward"	: "chevron_forward.png",
	"chevron.up"		: "chevron_up.png",
	"gearshape"		: "gearshape.png",
	"hand.point.up"		: "hand_point_up.png",
	"hand.raised"		: "hand_raised.png",
	"line.diagonal"		: "line_diagonal.png",
	"moon.stars"		: "moon_stars.png",
	"oval"			: "oval.png",
	"oval.fill"		: "oval_fill.png",
	"paintbrush"		: "paintbrush.png",
	"pencil"		: "pencil.png",
	"pencil.circle"		: "pencil_circle.png",
	"pencil.circle.fill"	: "pencil_circle_fill.png",
	"play"			: "play.png",
	"questionmark"		: "questionmark.png",
	"rectangle"		: "rectangle.png",
	"rectangle.fill"	: "rectangle_fill.png",
	"sun.max"		: "sun_max.png",
	"sun.min"		: "sun_min.png"
]

public enum CNSymbol: Int
{
	public static let typeName = "Symbols"

	case character
	case chevronBackward
	case chevronDown
	case chevronForward
	case chevronUp
	case gearshape
	case handPointUp
	case handRaised
	case lineDiagonal
	case line_1p		// image in resource
	case line_2p		// image in resource
	case line_4p		// image in resource
	case line_8p		// image in resource
	case line_16p
	case moonStars
	case oval
	case ovalFill
	case paintbrush
	case pencil
	case pencilCircle
	case pencilCircleFill
	case play
	case questionmark
	case rectangle
	case rectangleFill
	case sunMax
	case sunMin

	public static var allCases: Array<CNSymbol> { get {
		return [
			.character,
			.chevronBackward,
			.chevronDown,
			.chevronForward,
			.chevronUp,
			.gearshape,
			.handPointUp,
			.handRaised,
			.lineDiagonal,
			.line_1p,
			.line_2p,
			.line_4p,
			.line_8p,
			.line_16p,
			.moonStars,
			.oval,
			.ovalFill,
			.paintbrush,
			.pencil,
			.pencilCircle,
			.pencilCircleFill,
			.play,
			.questionmark,
			.rectangle,
			.rectangleFill,
			.sunMax,
			.sunMin
		]
	}}

	public var name: String { get {
		let result: String
		switch self {
		case .character:	result = "character"
		case .chevronBackward:	result = "chevron.backward"
		case .chevronDown:	result = "chevron.down"
		case .chevronForward:	result = "chevron.forward"
		case .chevronUp:	result = "chevron.up"
		case .gearshape:	result = "gearshape"
		case .handPointUp:	result = "hand.point.up"
		case .handRaised:	result = "hand.raised"
		case .lineDiagonal:	result = "line.diagonal"
		case .line_1p:		result = "line.1p"
		case .line_2p:		result = "line.2p"
		case .line_4p:		result = "line.4p"
		case .line_8p:		result = "line.8p"
		case .line_16p:		result = "line.16p"
		case .moonStars:	result = "moon.stars"
		case .oval:		result = "oval"
		case .ovalFill:		result = "oval.fill"
		case .paintbrush:	result = "paintbrush"
		case .pencil:		result = "pencil"
		case .pencilCircle:	result = "pencil.circle"
		case .pencilCircleFill:	result = "pencil.circle.fill"
		case .play:		result = "play"
		case .questionmark:	result = "questionmark"
		case .rectangle:	result = "rectangle"
		case .rectangleFill:	result = "rectangle.fill"
		case .sunMax:		result = "sun.max"
		case .sunMin:		result = "sun.min"
		}
		return result
	}}

	public var identifier: String { get {
		let result: String
		switch self {
		case .character:	result = "character"
		case .chevronBackward:	result = "chevronBackward"
		case .chevronDown:	result = "chevronDown"
		case .chevronForward:	result = "chevronForward"
		case .chevronUp:	result = "chevronUp"
		case .gearshape:	result = "gearshape"
		case .handPointUp:	result = "handPointUp"
		case .handRaised:	result = "handRaised"
		case .lineDiagonal:	result = "lineDiagonal"
		case .line_1p:		result = "line1p"
		case .line_2p:		result = "line2p"
		case .line_4p:		result = "line4p"
		case .line_8p:		result = "line8p"
		case .line_16p:		result = "line16p"
		case .moonStars:	result = "moonStars"
		case .oval:		result = "oval"
		case .ovalFill:		result = "ovalFill"
		case .paintbrush:	result = "paintbrush"
		case .pencil:		result = "pencil"
		case .pencilCircle:	result = "pencilCircle"
		case .pencilCircleFill:	result = "pencilCircleFill"
		case .play:		result = "play"
		case .questionmark:	result = "questionmark"
		case .rectangle:	result = "rectangle"
		case .rectangleFill:	result = "rectangleFill"
		case .sunMax:		result = "sunMax"
		case .sunMin:		result = "sunMin"
		}
		return result
	}}

	public static func pencil(doFill fill: Bool) -> CNSymbol {
		return fill ? .pencilCircleFill : .pencil
	}

	public static func path(doFill fill: Bool) -> CNSymbol {
		return .lineDiagonal
	}

	public static func rectangle(doFill fill: Bool, hasRound round: Bool) -> CNSymbol {
		return fill ? .rectangleFill : .rectangle
	}

	public static func oval(doFill fill: Bool) -> CNSymbol {
		return fill ? .ovalFill : .oval
	}

	public func load(size sz: CNSymbolSize) -> CNImage {
		if let img = loadSymbol(size: sz){
			return img
		} else if let img = CNSymbol.loadImage(symbol: self) {
			let psize   = sz.toPointSize()
			let newsize = img.size.resizeWithKeepingAscpect(inSize: CGSize(width: psize, height: psize))
			if let newimg = img.resize(to: newsize) {
				return newimg
			}
		}
		CNLog(logLevel: .error, message: "Failed to load symbol: \(self.name)", atFunction: #function, inFile: #file)
		return CNImage()
	}

	private func loadSymbol(size sz: CNSymbolSize) -> CNImage? {
		let conf = CNImage.SymbolConfiguration(pointSize: sz.toPointSize(), weight: .regular)
		#if os(OSX)
			if let img = CNImage(symbolName: self.name) {
				if let cimg = img.withSymbolConfiguration(conf) {
					return cimg
				} else {
					CNLog(logLevel: .error, message: "Configuration failed", atFunction: #function, inFile: #file)
				}
			}
			return nil
		#else
			return CNImage(systemName: self.name, withConfiguration: conf)
		#endif
	}

	public static func decode(fromName name: String) -> CNSymbol? {
		for sym in CNSymbol.allCases {
			if sym.name == name {
				return sym
			}
		}
		return nil
	}

	private static func loadImage(symbol sym: CNSymbol) -> CNImage? {
		let img: CNImage?
		if let filename = imagesInResource[sym.name] {
			if let url = CNFilePath.URLForResourceDirectory(directoryName: "Images", subdirectory: nil, forClass: CNResource.self) {
				let file = url.appendingPathComponent(filename)
				if let limg = CNImage(contentsOf: file) {
					img = limg
				} else {
					CNLog(logLevel: .error, message: "Symbol file is not found: \(file.path)", atFunction: #function, inFile: #file)
					img = CNImage()
				}
			} else {
				CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
				img = CNImage()
			}
		} else {
			#if os(OSX)
				img = NSImage(named: NSImage.Name(sym.name))
			#else
				img = UIImage(named: sym.name)
			#endif
		}
		return img
	}
}

