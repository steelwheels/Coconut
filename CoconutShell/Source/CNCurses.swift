/**
 * @file	CNCurses.swift
 * @brief	Define CNCurses class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation
import Darwin.ncurses

public class CNCurses
{
	public init() {
	}

	public func setup() {
		initscr()
		start_color()
		use_default_colors()
		self.visiblePrompt = false
		self.doBuffering   = false
		self.doEcho        = false
		refresh()
	}

	public func finalize(){
		endwin()
	}

	public var screenWidth: Int {
		get { return Int(getmaxx(stdscr)) }
	}

	public var screenHeight: Int {
		get { return Int(getmaxy(stdscr)) }
	}

	public var cursorX: Int {
		get { return Int(getcurx(stdscr)) }
	}

	public var cursorY: Int {
		get { return Int(getcury(stdscr)) }
	}

	public func clear(){
		erase()
		refresh()
	}

	private var mVisiblePrompt: Bool = false
	public var visiblePrompt: Bool {
		get { return mVisiblePrompt }
		set(value) {
			curs_set(value ? 1 : 0)
			mVisiblePrompt = value ;
		}
	}

	private var mDoBuffering: Bool = false
	public var doBuffering: Bool {
		get { return mDoBuffering }
		set(value) {
			if value {
				nocbreak()
				nodelay(stdscr, false)
			} else {
				cbreak()
				nodelay(stdscr, true)
			}
			mDoBuffering = value
		}
	}

	private var mDoEcho: Bool = false
	public var doEcho: Bool {
		get { return mDoEcho }
		set(value) {
			if value {
				echo()
			} else {
				noecho()
			}
			mDoEcho = value
		}
	}

	public func setColor(foregroundColor fcol: CNColor, backgroundColor bcol: CNColor) {
		let fcol  = fcol.toDarwinColor()
		let bcol  = bcol.toDarwinColor()
		if let colid = addColorPair(foregroundColor: fcol, backgroundColor: bcol) {
			attrset(COLOR_PAIR(colid))
		} else {
			NSLog("Color table overflow")
		}
	}

	private var mNextColorPair: Int16 = 1
	private func addColorPair(foregroundColor fcol: Int32, backgroundColor bcol: Int32) -> Int32? {
		/* Search the existence pairs */
		for i in 1..<mNextColorPair {
			var f : Int16 = 0
			var b : Int16 = 0
			pair_content(Int16(i), &f, &b)
			if fcol == f && bcol == b {
				return Int32(i)
			}
		}
		if mNextColorPair < Darwin.COLORS {
			let pairid = mNextColorPair
			init_pair(pairid, Int16(fcol), Int16(bcol))
			mNextColorPair += 1
			return Int32(pairid)
		} else {
			return nil
		}
	}

	public func moveTo(x xval: Int, y yval: Int){
		if xval < screenWidth && yval < screenHeight {
			move(Int32(yval), Int32(xval))
		}
	}

	public func getKey() -> Int32? {
		let result: Int32?
		let key = getch()
		if key != Darwin.ERR {
			result = key
		} else {
			result = nil
		}
		return result
	}

	public func put(string s: String){
		addstr(s)
	}
}


