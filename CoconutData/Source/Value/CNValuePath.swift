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
}
