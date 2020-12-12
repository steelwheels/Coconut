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
	var isValid: Bool {
		get {
			let result: Bool
			if self.absoluteString == "file:///dev/null" {
				result = false
			} else {
				result = true
			}
			return result
		}
	}

#if os(OSX)
	static func openPanel(title tl: String, type file: CNFileType, extensions exts: Array<String>) -> URL?
	{
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

		var result: URL? = nil
		switch panel.runModal() {
		case .OK:
			let urls = panel.urls
			if urls.count == 1 {
				let preference = CNPreference.shared.bookmarkPreference
				preference.add(URL: urls[0])
				result = urls[0]
			} else {
				NSLog("Invalid result: \(urls)")
			}
		case .cancel:
			break
		default:
			break
		}
		return result
	}

	/* Note: this method is used to open panel from the non-main thread */
	static func openPanelWithAsync(title tl: String, type file: CNFileType, extensions exts: Array<String>, callback cbfunc: @escaping (_ url: Array<URL>) -> Void) {
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
			(_ responce: NSApplication.ModalResponse) -> Void in
			switch responce {
			case .OK:
				cbfunc(panel.urls)
			default:
				cbfunc([])
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

