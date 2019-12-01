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
	enum CNFileSelection {
		case SelectFile
		case SelectDirectory
	}

	static func openPanel(title tl: String, selection sel: CNFileSelection, fileTypes types: Array<String>) -> URL?
	{
		let panel = NSOpenPanel()
		panel.title = tl

		switch sel {
		case .SelectFile:
			panel.canChooseFiles       = true
			panel.canChooseDirectories = false
		case .SelectDirectory:
			panel.canChooseFiles       = false
			panel.canChooseDirectories = true
		}
		panel.allowsMultipleSelection = false
		panel.allowedFileTypes = types

		var result: URL? = nil
		switch panel.runModal() {
		case .OK:
			let urls = panel.urls
			if urls.count == 1 {
				let preference = CNBookmarkPreference.sharedPreference
				preference.saveToUserDefaults(URLs: urls)
				preference.synchronize()
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
	static func openPanelWithAsync(title tl: String, selection sel: CNFileSelection, fileTypes types: Array<String>, callback cbfunc: @escaping (_ url: Array<URL>) -> Void) {
		let panel = NSOpenPanel()
		panel.title = tl

		switch sel {
		case .SelectFile:
			panel.canChooseFiles       = true
			panel.canChooseDirectories = false
		case .SelectDirectory:
			panel.canChooseFiles       = false
			panel.canChooseDirectories = true
		}
		panel.allowsMultipleSelection = false
		panel.allowedFileTypes = types

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
						let preference = CNBookmarkPreference.sharedPreference
						preference.saveToUserDefaults(URL: newurl)
						preference.synchronize()
					}
				}
			}
		})
	}
#endif

	static func relativePath(sourceURL src: URL, baseDirectory base: URL) -> URL {
		let srccomp = src.pathComponents
		let basecomp = base.pathComponents
		let common = findLastCommonComponent(array0: srccomp, array1: basecomp)
		if common > 0 {
			var resultpath = ""
			let updirs = basecomp.count - common
			for _ in 0..<updirs {
				resultpath = "../" + resultpath
			}
			var is1st : Bool = true
			for comp in common ... srccomp.count-1 {
				if is1st {
					is1st = false
				} else {
					resultpath = resultpath + "/"
				}
				resultpath = resultpath + srccomp[comp]
			}
			return URL(fileURLWithPath: resultpath)
		}
		return src
	}

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

	private static func findLastCommonComponent(array0 s0: Array<String>, array1 s1: Array<String>) -> Int {
		let s0count = s0.count
		let s1count = s1.count
		let count   = s0count < s1count ? s0count : s1count

		for i in 0..<count {
			if s0[i] != s1[i] {
				return i
			}
		}
		return count - 1
	}
}

