/**
 * @file	CNDocumentTypeManager.swift
 * @brief	Define CNDocumentTypeManager class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNDocumentTypeManager
{
	public static let shared: CNDocumentTypeManager = CNDocumentTypeManager()

	private var mDocumentTypes:	Dictionary<String, Array<String>>	// UTI, extension

	public init() {
		mDocumentTypes = [:]
		if let infodict = Bundle.main.infoDictionary {
			/* Import document types */
			if let imports = infodict["UTImportedTypeDeclarations"] as? Array<AnyObject> {
				collectTypeDeclarations(typeDeclarations: imports)
			}
		}
	}

	private func collectTypeDeclarations(typeDeclarations decls: Array<AnyObject>){
		for decl in decls {
			if let dict = decl as? Dictionary<String, AnyObject> {
				if dict.count > 0 {
					collectTypeDeclaration(typeDeclaration: dict)
				}
			} else {
				CNLog(logLevel: .error, message: "Invalid declaration: \(decl)", atFunction: #function, inFile: #file)
			}
		}
	}

	private func collectTypeDeclaration(typeDeclaration decl: Dictionary<String, AnyObject>){
		guard let uti = decl["UTTypeIdentifier"] as? String else {
			CNLog(logLevel: .error, message: "No UTTypeIdentifier", atFunction: #function, inFile: #file)
			return
		}
		guard let tags = decl["UTTypeTagSpecification"] as? Dictionary<String, AnyObject> else {
			CNLog(logLevel: .error, message: "No UTTypeTagSpecification", atFunction: #function, inFile: #file)
			return
		}
		guard let exts = tags["public.filename-extension"] as? Array<String> else {
			CNLog(logLevel: .error, message: "No public.filename-extension", atFunction: #function, inFile: #file)
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
				CNLog(logLevel: .error, message: "Unknown UTI: \(uti)", atFunction: #function, inFile: #file)
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
