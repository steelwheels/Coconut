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
	}

	private var mElements: Array<Element>

	public var elements: Array<Element> {
		get { return mElements }
	}

	public init(elements elms: Array<Element>){
		mElements = elms
	}

	public init(member memb: String){
		mElements = [ .member(memb) ]
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
}
