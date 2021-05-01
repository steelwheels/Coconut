/*
 * @file	CNFileInstaller.swift
 * @brief	Define CNFileInstaller class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

open class CNFileInstaller
{
	private var mConsole:			CNConsole

	public init(console cons: CNConsole){
		mConsole		= cons
	}

	open func installFiles() -> NSError? {
		return nil
	}

	public func makeTargetDir(directory targdir: URL) -> NSError? {
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
		} catch let err as NSError {
			return err
		} catch {
			let err = NSError.fileError(message: "Failed to create directory: \(targdir.path)")
			return err
		}
	}

	public func copyFile(targetDirectory dstdir: URL, sourceDirectory srcdir: String?, sourceName srcname: String?, sourceExtension srcext: String, sourceClass srcclass: AnyClass) -> NSError? {
		/* Correct source URLs */
		let srcurls: Array<URL>
		if let sname = srcname {
			if let srcurl = CNFilePath.URLForResourceFile(fileName: sname, fileExtension: srcext, subdirectory: srcdir, forClass: srcclass){
				srcurls = [srcurl]
			} else {
				return NSError.fileError(message: "Source file is not found: name=\(sname), extension=\(srcext)")
			}
		} else {
			switch CNFilePath.URLsForResourceFiles(fileExtension: srcext, subdirectory: srcdir, forClass: srcclass) {
			case .ok(let urls):
				srcurls = urls
			case .error(let err):
				return err
			}
		}
		if srcurls.count == 0 {
			return NSError.fileError(message: "Source file is not found: extension=\(srcext)")
		}

		/* Copy files */
		for srcurl in srcurls {
			let srcname = srcurl.lastPathComponent
			if srcname.count > 0 {
				let dstfile = dstdir.appendingPathComponent(srcname)
				do {
					mConsole.print(string: "Copy from \(srcurl.path) to \(dstfile.path)\n")
					let fmgr    = FileManager.default
					try fmgr.copyItem(at: srcurl, to: dstfile)
					return nil
				} catch let err as NSError {
					return err
				} catch {
					return NSError.fileError(message: "Failed to copy file from \(srcurl.path) to \(dstfile.path)")
				}
			} else {
				return NSError.fileError(message: "Failed to get source file name: \(srcurl.path)")
			}
		}
		return nil
	}
}
