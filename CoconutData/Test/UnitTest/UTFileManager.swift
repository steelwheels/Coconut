/**
 * @file	UTFileManager.swift
 * @brief	Test function for FileManager class
 * @par Copyright
 *   Copyright (C) 2020Steel Wheels Project
 */

import CoconutData
import Foundation

public func testFileManager(console cons: CNConsole) -> Bool
{
	var result   = true
	let fmanager = FileManager.default

	let curdir   = fmanager.currentDirectoryPath
	let plisturl = fmanager.fullPathURL(relativePath: "./Info.plist",   baseDirectory: curdir)
	let nonurl   = fmanager.fullPathURL(relativePath: "./Info.plist-2", baseDirectory: curdir)
	//cons.print(string: "fullpath: \(plisturl.path)\n")

	cons.print(string: "Test: fileExists -> ")
	if fmanager.fileExists(atURL: plisturl) {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG -> File \(plisturl.path) is NOT exist\n")
		result = false
	}
	cons.print(string: "Test: fileExists -> ")
	if fmanager.fileExists(atURL: nonurl) {
		cons.print(string: "NG -> File \(nonurl.path) is exist\n")
		result = false
	} else {
		cons.print(string: "OK\n")
	}

	cons.print(string: "Test: isAccessible (Read) -> ")
	if fmanager.isAccessible(pathString: plisturl.path, accessType: .ReadAccess) {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG -> File \(plisturl.path) can not be read\n")
		result = false
	}
	cons.print(string: "Test: isAccessible (Read) -> ")
	if fmanager.isAccessible(pathString: nonurl.path, accessType: .ReadAccess) {
		cons.print(string: "NG -> File \(nonurl.path) can be read\n")
		result = false
	} else {
		cons.print(string: "OK\n")
	}

	cons.print(string: "Test: isAccessible (CurDir) -> ")
	if fmanager.isAccessible(pathString: curdir, accessType: .AppendAccess) {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG -> File \(curdir) can be read\n")
		result = false
	}

	let homedir = "/home/user"

	cons.print(string: "rel: /tmp/a -> ")
	let url0 = fmanager.fullPathURL(relativePath: "/tmp/a", baseDirectory: homedir)
	if url0.path == "/tmp/a" {
		cons.print(string: "OK: url0 = \(url0.path)\n")
	} else {
		cons.print(string: "NG: url0 = \(url0.path)\n")
		result = false
	}
	cons.print(string: "rel: a.txt -> ")
	let url1 = fmanager.fullPathURL(relativePath: "a.txt", baseDirectory: homedir)
	if url1.path == "/home/user/a.txt" {
		cons.print(string: "OK: url0 = \(url1.path)\n")
	} else {
		cons.print(string: "NG: url0 = \(url1.path)\n")
		result = false
	}
	cons.print(string: "rel: subdir/a.txt -> ")
	let url2 = fmanager.fullPathURL(relativePath: "subdir/a.txt", baseDirectory: homedir)
	if url2.path == "/home/user/subdir/a.txt" {
		cons.print(string: "OK: url0 = \(url2.path)\n")
	} else {
		cons.print(string: "NG: url0 = \(url2.path)\n")
		result = false
	}
	cons.print(string: "rel: ../a.txt -> ")
	let url3 = fmanager.fullPathURL(relativePath: "../a.txt", baseDirectory: homedir)
	if url3.path == "/home/a.txt" {
		cons.print(string: "OK: url3 = \(url3.path)\n")
	} else {
		cons.print(string: "NG: url3 = \(url3.path)\n")
		result = false
	}

	return result
}

