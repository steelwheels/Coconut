/**
 * @file	CNPreference.swift
 * @brief	Define CNPreference class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation


open class CNConfig
{
	public enum LogLevel: Int {
		case error	= 0	// Error
		case warning	= 1	// + Warning (default value)
		case flow	= 2	// + Control flow
		case detail	= 3	// + Precise information

		public var description: String {
			get {
				let result: String
				switch self {
				case .error:	result = "error"
				case .warning:	result = "warning"
				case .flow:	result = "flow"
				case .detail:	result = "detail"
				}
				return result
			}
		}

		public func isMatched(logLevel level: LogLevel) -> Bool {
			return self.rawValue >= level.rawValue
		}

		public static var defaultLevel: LogLevel {
			return .warning
		}

		public static func decode(string str: String) -> LogLevel? {
			let result: LogLevel?
			switch str {
			case "error":		result = .error
			case "warning":		result = .warning
			case "flow":		result = .flow
			case "detail":		result = .detail
			default:		result = nil
			}
			return result
		}
	}

	public var logLevel:	LogLevel

	public init(logLevel log: LogLevel){
		logLevel = log
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
	public var logLevel:		CNConfig.LogLevel

	public init(){
		#if DEBUG
			logLevel = .flow
		#else
			logLevel = .error
		#endif
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
				log(type: .error, string:  "Invalid description: \(decl)", file: #file, line: #line, function: #function)
			}
		}
	}

	private func collectTypeDeclaration(typeDeclaration decl: Dictionary<String, AnyObject>){
		guard let uti = decl["UTTypeIdentifier"] as? String else {
			log(type: .error, string: "No UTTypeIdentifier", file: #file, line: #line, function: #function)
			return
		}
		guard let tags = decl["UTTypeTagSpecification"] as? Dictionary<String, AnyObject> else {
			log(type: .error, string: "No UTTypeTagSpecification", file: #file, line: #line, function: #function)
			return
		}
		guard let exts = tags["public.filename-extension"] as? Array<String> else {
			log(type: .error, string: "No public.filename-extension", file: #file, line: #line, function: #function)
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
				log(type: .error, string: "Unknown UTI: \(uti)", file: #file, line: #line, function: #function)
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
		return get(name: "documentType", allocator: {
			() -> CNDocumentTypePreference in return CNDocumentTypePreference()
		})
	}}

	open func set(config conf: CNConfig){
		CNPreference.shared.systemPreference.logLevel = conf.logLevel
	}
}


