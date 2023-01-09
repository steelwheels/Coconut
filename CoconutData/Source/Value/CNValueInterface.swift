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

public class CNInterfaceType
{
	static private var mUniqId = 0

	private var		mName:	String
	private weak var	mBase:	CNInterfaceType?
	private var		mTypes:	Dictionary<String, CNValueType>

	public var name:  String				{ get { return mName	}}
	public var base:  CNInterfaceType?			{ get { return mBase	}}
	public var types: Dictionary<String, CNValueType>	{ get { return mTypes	}}

	public static var mNilType: CNInterfaceType = CNInterfaceType(name: "Nil", base: nil, types: [:])
	public static var nilType: CNInterfaceType { get {
		return mNilType
	}}

	public init(name nm: String, base bs: CNInterfaceType?, types src: Dictionary<String, CNValueType>) {
		mName	= nm
		mBase	= bs
		mTypes	= src
	}

	public var allTypes: Dictionary<String, CNValueType> { get {
		var result: Dictionary<String, CNValueType> = [:]
		if let base = mBase {
			result.merge(base.types) { (_, new) in new }
		}
		result.merge(self.types) { (_, new) in new }
		return result
	}}

	public static func temporaryName() -> String {
		let name = "_iftyp\(mUniqId)"
		mUniqId += 1
		return name
	}
}

public class CNInterfaceValue
{
	private var mType:	CNInterfaceType?
	private var mTypeCache:	CNInterfaceType?
	private var mValues:	Dictionary<String, CNValue>

	public var values: Dictionary<String, CNValue> { get { return mValues }}

	public init(types tsrc: CNInterfaceType?, values vsrc: Dictionary<String, CNValue>) {
		mType		= tsrc
		mTypeCache	= nil
		mValues		= vsrc

		/* allocate types */
		if mType == nil {
			mTypeCache = allocateType(values: mValues)
		}
	}

	public func validate() -> Bool {
		var result = true
		loop: for (tkey, ttyp) in self.type.types {
			if let val = mValues[tkey] {
				switch CNValueType.compare(type0: ttyp, type1: val.valueType) {
				case .orderedSame:
					break
				case .orderedAscending, .orderedDescending:
					CNLog(logLevel: .error, message: "Unexpected type at \(tkey) property",
					      atFunction: #function, inFile: #file)
					result = false
					break loop
				}
			} else {
				CNLog(logLevel: .error, message: "No \(tkey) property in \(type.name)",
				      atFunction: #function, inFile: #file)
				result = false
				break
			}
		}
		return result
	}

	public func get(name nm: String) -> CNValue? {
		return mValues[nm]
	}

	public func set(name nm: String, value val: CNValue) {
		if let _ = self.type.types[nm] {
			mValues[nm] = val
		} else {
			CNLog(logLevel: .error, message: "Unexpected property: \(nm)",
			      atFunction: #function, inFile: #file)
		}
	}

	public var type: CNInterfaceType { get {
		if let typ = mType {
			return typ
		} else if let typ = mTypeCache {
			return typ
		} else {
			fatalError("Can not happen")
		}
	}}

	public static func fromValue(className clsname: String, value dict: Dictionary<String,CNValue>) -> CNInterfaceValue? {
		var result: CNInterfaceValue? = nil
		if let iftype = CNInterfaceTable.currentInterfaceTable().search(byTypeName: clsname) {
			var ptypes = dict ; ptypes["class"] = nil
			let ifval  = CNInterfaceValue(types: iftype, values: ptypes)
			if ifval.validate() {
				result = ifval
			} else {
				let val: CNValue = .dictionaryValue(dict)
				CNLog(logLevel: .error, message: "Failed to cast to interface: \(val.description)",
				      atFunction: #function, inFile: #file)
			}
		}
		return result
	}

	private func allocateType(values vals: Dictionary<String, CNValue>) -> CNInterfaceType {
		let name = CNInterfaceType.temporaryName()
		var types: Dictionary<String, CNValueType> = [:]
		for (key, val) in mValues {
			types[key] = val.valueType
		}
		let newif = CNInterfaceType(name: name, base: nil, types: types)
		/* Add to table */
		CNInterfaceTable.currentInterfaceTable().add(interfaceType: newif)
		return newif
	}
}

public class CNInterfaceTable
{
	private var      	mTypes:			Dictionary<String, CNInterfaceType>
	private weak var 	mParent:		CNInterfaceTable?

	private static var	mInterfaceTables	= CNStack<CNInterfaceTable>()

	public static func currentInterfaceTable() -> CNInterfaceTable {
		allocateDefaultInterfaceTable()
		if let top = mInterfaceTables.peek() {
			return top
		} else {
			fatalError("Can not happen")
		}
	}

	public static func pushInterfaceTable(enumTable iftable: CNInterfaceTable) {
		let parent = CNInterfaceTable.currentInterfaceTable()
		iftable.setParent(enumTable: parent)
		mInterfaceTables.push(iftable)
	}

	public static func popEnumTable() {
		if mInterfaceTables.count > 1 {
			let _ = mInterfaceTables.pop()
		} else {
			CNLog(logLevel: .error, message: "Popup interface table stack was failed",
			      atFunction: #function, inFile: #file)
		}
	}

	public var types: Dictionary<String, CNInterfaceType> { get {
		return mTypes
	}}

	public var allTypes: Dictionary<String, CNInterfaceType> { get {
		var result: Dictionary<String, CNInterfaceType> = [:]
		if let parent = mParent {
			let subres = parent.allTypes
			result.merge(subres) { (_, new) in new }
		}
		result.merge(self.types) { (_, new) in new }
		return result
	}}

	public init(){
		mTypes		= [:]
		mParent		= nil
	}

	public func setParent(enumTable etable: CNInterfaceTable) {
		mParent = etable
	}

	public func add(interfaceType iftype: CNInterfaceType){
		mTypes[iftype.name] = iftype
	}

	public func add(interfaceTypes iftypes: Array<CNInterfaceType>){
		for iftype in iftypes {
			mTypes[iftype.name] = iftype
		}
	}

	private static func allocateDefaultInterfaceTable() {
		if mInterfaceTables.count == 0 {
			let table = CNInterfaceTable()
			table.setDefaultValues()
			mInterfaceTables.push(table)
		}
	}

	public func search(byTypeName name: String) -> CNInterfaceType? {
		if let iftype = mTypes[name] {
			return iftype
		} else if let parent = mParent {
			return parent.search(byTypeName: name)
		} else {
			return nil
		}
	}

	private func setDefaultValues() {
		let pointif = CGPoint.allocateInterfaceType()
		let sizeif  = CGSize.allocateInterfaceType()
		let rectif  = CGRect.allocateInterfaceType()
		let ovalif  = CNOval.allocateInterfaceType(pointIF: pointif)
		let rangeif = NSRange.allocateInterfaceType()

		self.add(interfaceTypes: [pointif, sizeif, rectif, ovalif, rangeif])
	}
}

