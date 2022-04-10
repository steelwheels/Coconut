/**
 * @file	CNValuePath.swift
 * @brief	Define CNValuePath class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNValuePath
{
	public enum Element {
		case member(String)		// member name
		case index(Int)			// array index

		static func isSame(source0 src0: Element, source1 src1: Element) -> Bool {
			let result: Bool
			switch src0 {
			case .member(let memb0):
				switch src1 {
				case .member(let memb1):
					result = memb0 == memb1
				case .index(_):
					result = false
				}
			case .index(let idx0):
				switch src1 {
				case .member(_):
					result = false
				case .index(let idx1):
					result = idx0 == idx1
				}
			}
			return result
		}
	}

	private var mElements:   Array<Element>
	private var mExpression: String

	public var elements: Array<Element> { get {
		return mElements
	}}

	public var expression: String { get {
		return mExpression
	}}

	public init(elements elms: Array<Element>){
		mElements   = elms
		mExpression = CNValuePath.toExpression(elements: elms)
	}

	public init(member memb: String){
		mElements   = [ .member(memb) ]
		mExpression = CNValuePath.toExpression(elements: mElements)
	}

	public init(path pth: CNValuePath, subPath subs: Array<Element>){
		mElements = []
		for src in pth.elements {
			mElements.append(src)
		}
		for subs in subs {
			mElements.append(subs)
		}
		mExpression = CNValuePath.toExpression(elements: mElements)
	}

	public func isIncluded(in targ: CNValuePath) -> Bool {
		let selms = self.mElements
		let telms = targ.mElements
		if selms.count <= telms.count {
			for i in 0..<selms.count {
				if !Element.isSame(source0: selms[i], source1: telms[i]) {
					return false
				}
			}
			return true
		} else {
			return false
		}
	}

	public var description: String { get {
		var result = ""
		var is1st = true
		for elm in mElements {
			if is1st {
				is1st = false
			} else {
				result += ", "
			}
			switch elm {
			case .member(let str): result += ".member(\(str))"
			case .index(let idx):  result += ".index(\(idx))"
			}
		}
		return result
	}}

	public static func toExpression(elements elms: Array<Element>) -> String {
		var result: String = ""
		var is1st:  Bool   = true
		for elm in elms {
			switch elm {
			case .member(let str):
				if is1st {
					is1st  = false
				} else {
					result += "."
				}
				result    += str
			case .index(let idx):
				result    += "[\(idx)]"
			}
		}
		return result
	}

	public static func pathExpression(string str: String) -> Array<Element>? {
		var result: Array<Element> = []
		var finished               = true
		let members = str.components(separatedBy: ".")
		for member in members {
			if members.isEmpty {
				CNLog(logLevel: .error, message: "No member name: \(str)")
				finished = false
				break
			}
			let elms = member.components(separatedBy: "[")
			if let first = elms.first {
				/* Decode 1st component */
				let firststr = String(first)
				if firststr.isEmpty {
					CNLog(logLevel: .error, message: "No member name: \(str)")
					finished = false
					break
				}
				result.append(.member(firststr))

				/* Decode rest components */
				let rests = elms.dropFirst()
				if rests.count > 0 {
					for rest in rests {
						if rest.last == "]" {
							let idxstr = rest.dropLast()
							if let idx = Int(idxstr) {
								result.append(.index(idx))
							} else {
								CNLog(logLevel: .error, message: "Invalid index: \(idxstr) in \(str)")
								finished = false
								break
							}
						} else {
							CNLog(logLevel: .error, message: "Not closed by \"]\": \(str)")
							finished = false
							break
						}
					}
				}
			} else {
				CNLog(logLevel: .error, message: "No member name: \(str)")
				finished = false
				break
			}
		}
		return finished && result.count > 0 ? result : nil
	}

	public func compare(_ val: CNValuePath) -> ComparisonResult {
		let selfstr = self.mExpression
		let srcstr  = val.mExpression
		if selfstr == srcstr {
			return .orderedSame
		} else if selfstr > srcstr {
			return .orderedDescending
		} else {
			return .orderedAscending
		}
	}
}
