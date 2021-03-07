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
	static func openPanel(title tl: String, type file: CNFileType, extensions exts: Array<String>) -> URL? {
		if Thread.isMainThread {
			return openPanelMain(title: tl, type: file, extensions: exts)
		} else {
			let semaphore = DispatchSemaphore(value: 0)
			var result: URL? = nil
			CNExecuteInMainThread(doSync: false, execute: {
				result = openPanelMain(title: tl, type: file, extensions: exts)
				semaphore.signal()
			})
			semaphore.wait()
			return result
		}
	}

	private static func openPanelMain(title tl: String, type file: CNFileType, extensions exts: Array<String>) -> URL? {
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
			if urls.count >= 1 {
				result = urls[0]
			}
		case .cancel:
			break
		default:
			NSLog("Unknown event at \(#function)")
		}
		return result
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

