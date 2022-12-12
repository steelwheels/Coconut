/**
 * @file	CNStruct.swift
 * @brief	Define CNStruct class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNStructType
{
	private var mTypeName:		String
	private var mTypes:		Dictionary<String, CNValueType>

	public init(typeName name: String) {
		mTypeName	= name
		mTypes		= [:]
	}

	public var typeName: String { get { return mTypeName }}

	public var members:  Dictionary<String, CNValueType>	{ get { return mTypes		    }}
	public var memberNames: Array<String>			{ get { return Array(mTypes.keys)   }}
	public var memberTypes: Array<CNValueType>		{ get { return Array(mTypes.values) }}

	public func add(name nm: String, type vtype: CNValueType){
		mTypes[nm] = vtype
	}

	public func add(types vtypes: Dictionary<String, CNValueType>){
		for (nm, typ) in vtypes {
			mTypes[nm] = typ
		}
	}
}

public struct CNStruct
{
	private var mType:	CNStructType
	private var mValues:	Dictionary<String, CNValue>

	public var type:  CNStructType		       { get { return mType  }}
	public var values: Dictionary<String, CNValue> { get { return mValues }}

	public init(type stype: CNStructType, values vals: Dictionary<String, CNValue>) {
		mType   = stype
		mValues = vals
	}

	public func value(forMember name: String) -> CNValue? {
		return mValues[name]
	}
}

public class CNStructTable
{
	public static let  ClassName		= "structTable"

	private var      mTypes:	Dictionary<String, CNStructType>
	private weak var mParent:	CNStructTable?

	private static var mStructTables = CNStack<CNStructTable>()

	public static func currentStructTable() -> CNStructTable {
		allocateDefaultStructTable()
		if let top = mStructTables.peek() {
			return top
		} else {
			fatalError("Can not happen")
		}
	}

	public static func allStructTables() -> Array<CNStructTable> {
		allocateDefaultStructTable()
		return mStructTables.peekAll(doReverseOrder: true)
	}

	public static func pushStructTable(structTable table: CNStructTable) {
		let parent = CNStructTable.currentStructTable()
		table.setParent(structTable: parent)
		mStructTables.push(table)
	}

	public static func popStructTable() {
		if mStructTables.count > 1 {
			let _ = mStructTables.pop()
		} else {
			CNLog(logLevel: .error, message: "Popup struct table stack was failed", atFunction: #function, inFile: #file)
		}
	}

	private static func allocateDefaultStructTable() {
		if mStructTables.count == 0 {
			let table = CNStructTable()
			table.setDefaultTypes()
			mStructTables.push(table)
		}
	}

	public init(){
		mTypes		= [:]
		mParent		= nil
	}

	public func setParent(structTable table: CNStructTable) {
		mParent = table
	}

	public var allTypes: Dictionary<String, CNStructType> { get {
		return mTypes
	}}

	public var count: Int { get {
		return mTypes.count
	}}

	public func add(structType etype: CNStructType){
		mTypes[etype.typeName] = etype
	}

	public func search(byTypeName name: String) -> CNStructType? {
		if let stype = mTypes[name] {
			return stype
		} else if let parent = mParent {
			return parent.search(byTypeName: name)
		} else {
			return nil
		}
	}

	private func setDefaultTypes() {
		let color = CNStructType(typeName: CNColor.ClassName)
		color.add(types: [
			"r":		.numberType,
			"g":		.numberType,
			"b":		.numberType,
			"a":		.numberType
		])
		add(structType: color)

		let font = CNStructType(typeName: CNFont.ClassName)
		font.add(types: [
			"name":		.stringType,
			"size":		.numberType
		])
		add(structType: font)

		color.add(types: [
			"r":		.numberType,
			"g":		.numberType,
			"b":		.numberType,
			"a":		.numberType
		])
		add(structType: color)

		let point = CNStructType(typeName: CGPoint.ClassName)
		point.add(types: [
			"x":		.numberType,
			"y":		.numberType
		])
		add(structType: point)

		let rect = CNStructType(typeName: CGRect.ClassName)
		rect.add(types: [
			"x":		.numberType,
			"y":		.numberType,
			"width":	.numberType,
			"height":	.numberType
		])
		add(structType: rect)

		let size = CNStructType(typeName: CGSize.ClassName)
		size.add(types: [
			"width":	.numberType,
			"height":	.numberType
		])
		add(structType: size)

		let oval = CNStructType(typeName: CNOval.ClassName)
		size.add(types: [
			"center":	.structType(point),
			"radius":	.numberType
		])
		add(structType: oval)

		let vectorpath = CNStructType(typeName: CNVectorPath.ClassName)
		vectorpath.add(types: [
			"lineWidth":	.numberType,
			"doFill":	.boolType,
			"fillColor":	.structType(color),
			"strokeColor":	.structType(color),
			"points":	.arrayType(.structType(point))
		])
		add(structType: vectorpath)

		let vectorrect = CNStructType(typeName: CNVectorRect.ClassName)
		vectorrect.add(types: [
			"lineWidth":	.numberType,
			"doFill":	.boolType,
			"fillColor":	.structType(color),
			"strokeColor":	.structType(color),
			"origin":	.structType(point),
			"size":		.structType(size),
			"isRounded":	.boolType,
			"rx":		.numberType,
			"ry":		.numberType
		])
		add(structType: vectorrect)

		let image = CNStructType(typeName: CNImage.ClassName)
		image.add(types: [
			"size":		.structType(size)
		])

		let vectoroval = CNStructType(typeName: CNVectorOval.ClassName)
		vectoroval.add(types: [
			"lineWidth":	.numberType,
			"doFill":	.boolType,
			"fillColor":	.structType(color),
			"strokeColor":	.structType(color),
			"center":	.structType(point),
			"radius":	.numberType
		])
		add(structType: vectoroval)

		let vectorstr = CNStructType(typeName: CNVectorString.ClassName)
		vectorstr.add(types: [
			"origin":	.structType(point),
			"text":		.stringType,
			"font":		.structType(font),
			"color":	.structType(color)
		])
		add(structType: vectorstr)
	}
}
