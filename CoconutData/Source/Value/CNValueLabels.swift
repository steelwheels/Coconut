/*
 * @file	CNValueLabels.swift
 * @brief	Define CNValueLabels class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public class CNValueLabels
{
	public typealias LabelTableType = Dictionary<String, Array<CNValuePath.Element>>

	private var mLabelTable: LabelTableType?

	public init(){
		mLabelTable = nil
	}

	public func pointerToPath(pointer ptr: CNPointerValue, in root: CNMutableValue) -> Array<CNValuePath.Element> {
		let elms: Array<CNValuePath.Element>
		if let ident = ptr.path.identifier {
			if let top = root.labelTable().labelToPath(label: ident, in: root) {
				var fullelms = top
				fullelms.append(contentsOf: ptr.path.elements)
				elms = fullelms
			} else {
				CNLog(logLevel: .error, message: "Label \(ident) is not found: \(ptr.path.script)", atFunction: #function, inFile: #file)
				elms = ptr.path.elements
			}
		} else {
			elms = ptr.path.elements
		}
		return elms
	}

	public func labelToPath(label lbl: String, in root: CNMutableValue) -> Array<CNValuePath.Element>? {
		let tbl = table(in: root)
		return tbl[lbl]
	}

	private func table(in root: CNMutableValue) -> LabelTableType {
		if let tbl = mLabelTable {
			return tbl
		} else {
			let newtbl  = root.makeLabelTable(property: "id")
			mLabelTable = newtbl
			return newtbl
		}
	}

	public func clear() {
		mLabelTable = nil
	}
}

