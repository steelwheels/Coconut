/*
 * @file	CNFileURL.swift
 * @brief	Extend CNFileURL class
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
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
		panel.allowedFileTypes = exts
		panel.begin(completionHandler: {
			(_ resp: NSApplication.ModalResponse) -> Void in
			switch resp {
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
				NSLog("Unsupported result")
				cbfunc(nil)
			}
		})
	}

	static func savePanel(title tl: String, outputDirectory outdir: URL?, saveFileCallback callback: @escaping ((_: URL) -> Bool))
	{
		let panel = NSSavePanel()
		panel.title = tl
		panel.canCreateDirectories = true
		panel.showsTagField = false
		if let odir = outdir {
			panel.directoryURL = odir
		}
		panel.begin(completionHandler: { (result: NSApplication.ModalResponse) -> Void in
			if result == .OK {
				if let newurl = panel.url {
					if callback(newurl) {
						let preference = CNPreference.shared.bookmarkPreference
						preference.add(URL: newurl)
					}
				}
			}
		})
	}
#endif

	func loadContents() -> NSString? {
		var resstr: NSString? = nil
		let issecure = startAccessingSecurityScopedResource()
		do {
			resstr = try NSString(contentsOf: self, encoding: String.Encoding.utf8.rawValue)
			if resstr == nil {
				return nil
			}
		} catch {
			return nil
		}
		if issecure {
			stopAccessingSecurityScopedResource()
		}
		return resstr
	}
}

