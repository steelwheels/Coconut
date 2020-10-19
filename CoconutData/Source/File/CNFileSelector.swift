/*
 * @file	CNFileSelector.swift
 * @brief	Define CNFileSelector class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

#if os(OSX)

public class CNFileSelector
{
	private var mSelectedURL:	URL?
	private var mDidSelected:	Bool

	public init() {
		mSelectedURL	= nil
		mDidSelected	= false
	}

	public func selectInputFile(title tstr: String, extensions exts: Array<String>) -> URL? {
		mSelectedURL	= nil
		mDidSelected	= false
		/* open panel to select */
		CNExecuteInMainThread(doSync: false, execute: {
			URL.openPanelWithAsync(title: tstr, selection: .SelectFile, fileTypes: exts, callback: {
				(_ urls: Array<URL>) -> Void in
				if urls.count >= 1 {
					self.mSelectedURL = urls[0]
				}
				self.mDidSelected = true
			})
		})
		while !mDidSelected {
			usleep(100)
		}
		return mSelectedURL
	}
}

#endif

