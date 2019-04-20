/**
 * @file	CNPreferemce.h
 * @brief	Define CNPreference class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public enum CNBuildMode {
	case Release
	case Debug

	public var description: String {
		get {
			let result: String
			switch self {
			case .Debug:	result = "debug"
			case .Release:	result = "release"
			}
			return result
		}
	}
}

open class CNConfig
{
	public var	buildMode:	CNBuildMode

	public init(){
		buildMode	= .Debug
	}
}

open class CNPreference
{
	public static let shared = CNPreference()

	private var mTable:	Dictionary<String, AnyObject>

	private init(){
		mTable = [:]
	}

	public func get<T:AnyObject>(name nm: String, allocator alloc: () -> T) -> T {
		if let anypref = mTable[nm] as? T {
			return anypref
		} else {
			let newpref = alloc()
			mTable[nm]  = newpref
			return newpref
		}
	}

	public func set(name nm: String, preference pref: AnyObject){
		mTable[nm] = pref
	}
}

public class CNSystemPreference
{
	public var buildMode:		CNBuildMode

	public init(){
		buildMode = .Debug
	}
}

public class CNDocumentTypePreference: CNLogging
{
	private var mConsole:		CNConsole?
	private var mDocumentTypes:	Dictionary<String, Array<String>>	// UTI, extension

	public init() {
		mConsole        = nil
		mDocumentTypes  = [:]

		if let infodict = Bundle.main.infoDictionary {
			/* Import document types */
			if let imports = infodict["UTImportedTypeDeclarations"] as? Array<AnyObject> {
				collectTypeDeclarations(typeDeclarations: imports)
			}
		}
	}

	public func set(console cons: CNConsole?) {
		mConsole = cons
	}

	public var console: CNConsole? {
		get { return mConsole }
	}

	private func collectTypeDeclarations(typeDeclarations decls: Array<AnyObject>){
		for decl in decls {
			if let dict = decl as? Dictionary<String, AnyObject> {
				if dict.count > 0 {
					collectTypeDeclaration(typeDeclaration: dict)
				}
			} else {
				log(type: .Error, string:  "Invalid description: \(decl)", file: #file, line: #line, function: #function)
			}
		}
	}

	private func collectTypeDeclaration(typeDeclaration decl: Dictionary<String, AnyObject>){
		guard let uti = decl["UTTypeIdentifier"] as? String else {
			log(type: .Error, string: "No UTTypeIdentifier", file: #file, line: #line, function: #function)
			return
		}
		guard let tags = decl["UTTypeTagSpecification"] as? Dictionary<String, AnyObject> else {
			log(type: .Error, string: "No UTTypeTagSpecification", file: #file, line: #line, function: #function)
			return
		}
		guard let exts = tags["public.filename-extension"] as? Array<String> else {
			log(type: .Error, string: "No public.filename-extension", file: #file, line: #line, function: #function)
			return
		}
		mDocumentTypes[uti] = exts
	}

	public var UTIs: Array<String> {
		get {
			return Array(mDocumentTypes.keys)
		}
	}

	public func fileExtensions(forUTIs utis: [String]) -> [String] {
		var result: [String] = []
		for uti in utis {
			if let exts = mDocumentTypes[uti] {
				result.append(contentsOf: exts)
			} else {
				log(type: .Error, string: "Unknown UTI: \(uti)", file: #file, line: #line, function: #function)
			}
		}
		return result
	}

	public func UTIs(forExtensions exts: [String]) -> [String] {
		var result: [String] = []
		for ext in exts {
			for uti in mDocumentTypes.keys {
				if let val = mDocumentTypes[uti] {
					if val.contains(ext) {
						result.append(uti)
					}
				}
			}
		}
		return result
	}
}

extension CNPreference
{
	public var systemPreference: CNSystemPreference { get {
		return get(name: "system", allocator: {
			() -> CNSystemPreference in return CNSystemPreference()
		})
	}}

	public var documentTypePreference: CNDocumentTypePreference { get {
		return get(name: "system", allocator: {
			() -> CNDocumentTypePreference in return CNDocumentTypePreference()
		})
	}}
}

private var sDidSetupped: Bool = false

public func CNSetupPreference(config conf: CNConfig)
{
	/* Skip setup if it already setupped */
	if sDidSetupped {
		return
	} else {
		sDidSetupped = true
	}

	/* Setup system preference */
	let pref = CNPreference.shared
	pref.systemPreference.buildMode = conf.buildMode

}

