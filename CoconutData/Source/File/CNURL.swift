/*
 * @file	CNURL.swift
 * @brief	Extend URL class
 * @par Copyright
 *   Copyright (C) 2016-2021 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#endif
import Foundation

/**
 * Extend the URL methods to open, load, save, close the files in the sand-box
 */
public extension URL
{
	static func null() -> URL {
		guard let u = URL(string: "file:///dev/null") else {
			fatalError("Failed to allocate null URL")
		}
		return u
	}

	var isNull: Bool {
		get { return self.absoluteString == "file:///dev/null" }
	}

#if os(OSX)
	static func openPanel(title tl: String, type file: CNFileType, extensions exts: Array<String>, callback cbfunc: @escaping (_ url: URL?) -> Void) {
		CNExecuteInMainThread(doSync: false, execute: {
			openPanelMain(title: tl, type: file, extensions: exts, callback: cbfunc)
		})
	}

	private static func openPanelMain(title tl: String, type file: CNFileType, extensions exts: Array<String>, callback cbfunc: @escaping (_ url: URL?) -> Void) {
		let panel = NSOpenPanel()
		panel.title = tl
		switch file {
		case .File, .NotExist:
			panel.canChooseFiles       = true
			panel.canChooseDirectories = false
		case .Directory:
			panel.canChooseFiles       = false
			panel.canChooseDirectories = true
		}
		panel.allowsMultipleSelection = false
		switch panel.runModal() {
		case .OK:
			let urls = panel.urls
			if urls.count >= 1 {
				/* Bookmark this folder */
				let preference = CNPreference.shared.bookmarkPreference
				preference.add(URL: urls[0])
				cbfunc(urls[0])
			} else {
				cbfunc(nil)
			}
		case .cancel:
			cbfunc(nil)
		default:
			CNLog(logLevel: .error, message: "Unsupported result", atFunction: #function, inFile: #file)
			cbfunc(nil)
		}
	}

	static func savePanel(title tl: String, outputDirectory outdir: URL?, callback cbfunc: @escaping ((_: URL?) -> Void)) {
		CNExecuteInMainThread(doSync: false, execute: {
			self.savePanelMain(title: tl, outputDirectory: outdir, callback: cbfunc)
		})
	}

	private static func savePanelMain(title tl: String, outputDirectory outdir: URL?, callback cbfunc: @escaping ((_: URL?) -> Void))
	{
		let panel = NSSavePanel()
		panel.title = tl
		panel.canCreateDirectories = true
		panel.showsTagField = false
		if let odir = outdir {
			panel.directoryURL = odir
		}
		switch panel.runModal() {
		case .OK:
			if let newurl = panel.url {
				if FileManager.default.fileExists(atURL: newurl) {
					/* Bookmark this URL */
					let preference = CNPreference.shared.bookmarkPreference
					preference.add(URL: newurl)
				}
				cbfunc(newurl)
			} else {
				cbfunc(nil)
			}
		case .cancel:
			cbfunc(nil)
		default:
			CNLog(logLevel: .error, message: "Unsupported result", atFunction: #function, inFile: #file)
			cbfunc(nil)
		}
	}
#endif

	func loadContents() -> NSString? {
		var resstr: NSString?
		let issecure = startAccessingSecurityScopedResource()
		do {
			resstr = try NSString(contentsOf: self, encoding: String.Encoding.utf8.rawValue)
		} catch {
			resstr = nil
		}
		if issecure {
			stopAccessingSecurityScopedResource()
		}
		return resstr
	}

	func storeContents(contents str: String) -> Bool {
		var result = true
		let issecure = startAccessingSecurityScopedResource()
		do {
			try str.write(toFile: self.path, atomically: false, encoding: .utf8)
		} catch {
			result = false
		}
		if issecure {
			stopAccessingSecurityScopedResource()
		}
		return result
	}

	func loadValue() -> CNValue? {
		var result: CNValue? = nil
		if let str = self.loadContents() {
			let parser = CNValueParser()
			switch parser.parse(source: str as String) {
			case .success(let val):
				result = val
			case .failure(let err):
				CNLog(logLevel: .error, message: "Error: \(err.description)", atFunction: #function, inFile: #file)
			}
		}
		return result
	}

	func storeValue(value val: CNValue) -> Bool {
		let str = val.toScript().toStrings().joined(separator: "\n")
		return self.storeContents(contents: str)
	}
}

