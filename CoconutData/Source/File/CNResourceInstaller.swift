/*
 * @file	CNResourceInstaller.swift
 * @brief	Define CNResourceInstaller class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNResourceInstaller
{
	private var mConsole: CNConsole

	public init(console cons: CNConsole){
		mConsole = cons
	}

	public func install(destinationDirectory dstdir: URL, sourceDirectoryNames srcdirs: Array<String>) -> Bool {
		var result: Bool = true
		let fmgr = FileManager.default
		for srcdir in srcdirs {
			let dstsubdir = dstdir.appendingPathComponent(srcdir)

			if fmgr.fileExists(atURL: dstsubdir) {
				mConsole.print(string: "Remove directory: \(dstsubdir.path)\n")
				if let err = remove(directory: dstsubdir) {
					mConsole.error(string: "[Error] \(err.toString())")
					result = false
					continue
				}
			}

			if let srcsubdir = Bundle.main.url(forResource: srcdir, withExtension: nil){
				mConsole.print(string: "Copy directory: \(srcsubdir) --> \(dstsubdir)\n")
				if let err = copy(destinationDirectory: dstsubdir, sourceDirectory: srcsubdir){
					mConsole.error(string: "[Error] \(err.toString())")
					result = false
				}
			} else {
				mConsole.error(string: "[Error] No source directory: \(srcdir)")
				result = false
			}
		}
		return result
	}

	private func makeTargetDir(directory targdir: URL) -> NSError? {
		do {
			let fmgr = FileManager.default
			switch fmgr.checkFileType(pathString: targdir.path) {
			case .Directory:
				break // Nothing have to do
			case .File:
				return NSError.fileError(message: "The file is already exist: \(targdir.path)")
			case .NotExist:
				/* Make the directory */
				mConsole.print(string: "Make directory: \(targdir.path)\n")
				try fmgr.createDirectory(at: targdir,
							 withIntermediateDirectories: false,
							 attributes: nil)
			}
			return nil
		} catch {
			return error as NSError
		}
	}

	private func remove(directory dir: URL) -> NSError? {
		let fmgr = FileManager.default
		do {
			try fmgr.removeItem(at: dir)
			return nil
		} catch {
			return error as NSError
		}
	}

	private func copy(destinationDirectory dstdir: URL, sourceDirectory srcdir: URL) -> NSError? {
		let fmgr = FileManager.default
		do {
			try fmgr.copyItem(at: srcdir, to: dstdir)
			return nil
		} catch {
			return error as NSError
		}
	}
}
