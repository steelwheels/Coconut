/**
 * @file	CNEnum.swift
 * @brief	Define CNEnum class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import Foundation

public struct CNEnum
{
	public static let ClassName = "enum"

	private weak var	mEnumType:	CNEnumType?
	private var 		mMemberName:	String

	public var memberName: String { get {
		return mMemberName
	}}

	public init(type t: CNEnumType, member n: String){
		mEnumType	= t
		mMemberName	= n
	}

	public var typeName: String { get {
		if let etype = mEnumType {
			return etype.typeName
		} else {
			CNLog(logLevel: .error, message: "No owner type", atFunction: #function, inFile: #file)
			return "?"
		}
	}}

	public var value: Int { get {
		if let etype = mEnumType {
			if let val = etype.value(forMember: mMemberName) {
				return val
			} else {
				CNLog(logLevel: .error, message: "No value for member \(mMemberName)", atFunction: #function, inFile: #file)
			}
		} else {
			CNLog(logLevel: .error, message: "No owner type", atFunction: #function, inFile: #file)
		}
		return 0
	}}

	public static func fromValue(typeName tname: String, memberName mname: String) -> CNEnum? {
		let table = CNEnumTable.currentEnumTable()
		if let etype = table.search(byTypeName: tname) {
			if let _ = etype.value(forMember: mname) {
				return CNEnum(type: etype, member: mname)
			} else {
				CNLog(logLevel: .error, message: "Enum member is not found. type:\(tname), member:\(mname)", atFunction: #function, inFile: #file)
			}
		} else {
			CNLog(logLevel: .error, message: "Enum type is not found: \(tname)", atFunction: #function, inFile: #file)
		}
		return nil
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNEnum? {
		if let typeval = val["type"], let membval = val["member"] {
			if let typestr = typeval.toString(), let membstr = membval.toString() {
				return fromValue(typeName: typestr, memberName: membstr)
			}
		}
		CNLog(logLevel: .error, message: "No such enum value", atFunction: #function, inFile: #file)
		return nil
	}

	public func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"class":	.stringValue(CNEnum.ClassName),
			"type":		.stringValue(self.typeName),
			"member":	.stringValue(self.memberName)
		]
		return result
	}
}

public class CNEnumType
{
	public static let ClassName		= "enumType"

	private var mTypeName:		String
	private var mMembers:		Dictionary<String, Int>	// <member-name, value>

	public var typeName: String { get {
		return mTypeName
	}}

	public init(typeName name: String){
		mTypeName  = name
		mMembers   = [:]
	}

	public func allocate(name nm: String) -> CNEnum? {
		if let _ = mMembers[nm] {
			return CNEnum(type: self, member: nm)
		} else {
			return nil
		}
	}

	public func add(name nm: String, value val: Int){
		mMembers[nm] = val
	}

	public func add(members membs: Dictionary<String, Int>){
		for key in membs.keys.sorted() {
			if let val = membs[key] {
				self.add(name: key, value: val)
			}
		}
	}

	public var names: Array<String> { get {
		return mMembers.keys.sorted()
	}}

	public func value(forMember name: String) -> Int? {
		return mMembers[name]
	}

	public static func fromValue(typeName name: String, value topval: Dictionary<String, CNValue>) -> Result<CNEnumType, NSError> {
		let result = CNEnumType(typeName: name)
		for (key, val) in topval {
			switch val {
			case .boolValue(let val):
				result.add(name: key, value: val ? 1 : 0)
			case .numberValue(let num):
				result.add(name: key, value: num.intValue)
			default:
				let txt = val.toScript().toStrings().joined(separator: "\n")
				let err = NSError.parseError(message: "Invalid enum value: \(txt)")
				return .failure(err)
			}
		}
		return .success(result)
	}

	public func toValue() -> Dictionary<String, CNValue> {
		var result: Dictionary<String, CNValue> = [:]
		for (key, val) in mMembers {
			result[key] = .numberValue(NSNumber(integerLiteral: val))
		}
		return result
	}
}

public class CNEnumTable
{
	public static let  ClassName		= "enumTable"

	private static let definitionsItem	= "definitions"

	private var      mTypes:	Dictionary<String, CNEnumType>
	private weak var mParent:	CNEnumTable?

	private static var mEnumTables = CNStack<CNEnumTable>()

	public static func currentEnumTable() -> CNEnumTable {
		allocateDefaultEnumTable()
		if let top = mEnumTables.peek() {
			return top
		} else {
			fatalError("Can not happen")
		}
	}

	public static func allEnumTables() -> Array<CNEnumTable> {
		allocateDefaultEnumTable()
		return mEnumTables.peekAll()
	}

	public static func pushEnumTable(enumTable etable: CNEnumTable) {
		let parent = CNEnumTable.currentEnumTable()
		etable.setParent(enumTable: parent)
		mEnumTables.push(etable)
	}

	public static func popEnumTable() {
		if mEnumTables.count > 1 {
			let _ = mEnumTables.pop()
		} else {
			CNLog(logLevel: .error, message: "Popup enum table stack was failed", atFunction: #function, inFile: #file)
		}
	}

	private static func allocateDefaultEnumTable() {
		if mEnumTables.count == 0 {
			let table = CNEnumTable()
			table.setDefaultValues()
			mEnumTables.push(table)
		}
	}

	public init(){
		mTypes		= [:]
		mParent		= nil
	}

	public func setParent(enumTable etable: CNEnumTable) {
		mParent = etable
	}

	public var allTypes: Dictionary<String, CNEnumType> { get {
		return mTypes
	}}

	public var count: Int { get {
		return mTypes.count
	}}

	public func add(enumType etype: CNEnumType){
		mTypes[etype.typeName] = etype
	}

	public func search(byTypeName name: String) -> CNEnumType? {
		if let etype = mTypes[name] {
			return etype
		} else if let parent = mParent {
			return parent.search(byTypeName: name)
		} else {
			return nil
		}
	}

	public func search(byMemberName name: String) -> Array<CNEnum> {
		var result: Array<CNEnum> = []
		/* User defined value is first */
		for etype in mTypes.values {
			if let eobj = etype.allocate(name: name) {
				result.append(eobj)
			}
		}
		if let parent = mParent {
			result.append(contentsOf: parent.search(byMemberName: name))
		}
		return result
	}

	public static func fromValue(value topval: CNValue) -> Result<CNEnumTable?, NSError> {
		guard let dictval = topval.toDictionary() else {
			return .failure(NSError.parseError(message: "Top value must be dictionary"))
		}
		guard CNValue.hasClassName(inValue: dictval, className: CNEnumTable.ClassName) else {
			return .failure(NSError.parseError(message: "Class name \"\(CNEnumTable.ClassName)\" is required"))
		}
		if let defs = hasDefinitions(value: dictval) {
			return fromValue(value: defs)
		} else {
			return .failure(NSError.parseError(message: "No valid definitions in enum table"))
		}
	}

	private static func hasDefinitions(value val: Dictionary<String, CNValue>) -> Dictionary<String, CNValue>? {
		if let val = val[CNEnumTable.definitionsItem] {
			return val.toDictionary()
		} else {
			return nil
		}
	}

	private static func fromValue(value topval: Dictionary<String, CNValue>) -> Result<CNEnumTable?, NSError> {
		let result = CNEnumTable()
		for (key, val) in topval {
			switch val {
			case .dictionaryValue(let dict):
				switch CNEnumType.fromValue(typeName: key, value: dict) {
				case .success(let etype):
					result.add(enumType: etype)
				case .failure(let err):
					return .failure(err)
				}
			default:
				let err = NSError.parseError(message: "Unexpected contents of enum table")
				return .failure(err)
			}
		}
		return .success(result.count > 0 ? result: nil)
	}

	public func toValue() -> Dictionary<String, CNValue> {
		var members: Dictionary<String, CNValue> = [:]
		for (key, etype) in mTypes {
			members[key] = .dictionaryValue(etype.toValue())
		}
		let result: Dictionary<String, CNValue> = [
			"class":			.stringValue(CNEnumTable.ClassName),
			CNEnumTable.definitionsItem:	.dictionaryValue(members)
		]
		return result
	}

	public func merge(enumTable src: CNEnumTable) {
		for (key, val) in src.mTypes {
			mTypes[key] = val
		}
	}

	private func setDefaultValues() {
		let exitcode = CNEnumType(typeName: "ExitCode")
		exitcode.add(members: [
			"noError": 		CNExitCode.NoError.rawValue,
			"internalError":	CNExitCode.InternalError.rawValue,
			"commaneLineError":	CNExitCode.CommandLineError.rawValue,
			"syntaxError":		CNExitCode.SyntaxError.rawValue,
			"exception":		CNExitCode.Exception.rawValue
		])
		self.add(enumType: exitcode)

		let logcode = CNEnumType(typeName: "LogLevel")
		logcode.add(members: [
			"nolog":		CNConfig.LogLevel.nolog.rawValue,
			"error":		CNConfig.LogLevel.error.rawValue,
			"warning":		CNConfig.LogLevel.warning.rawValue,
			"debug":		CNConfig.LogLevel.debug.rawValue,
			"detail":		CNConfig.LogLevel.detail.rawValue
		])
		self.add(enumType: logcode)

		let valtype = CNEnumType(typeName: "ValueType")
		valtype.add(members: [
			"nullType":		CNValueType.nullType.rawValue,
			"boolType":		CNValueType.boolType.rawValue,
			"numberType":		CNValueType.numberType.rawValue,
			"stringType":		CNValueType.stringType.rawValue,
			"dateType":		CNValueType.dateType.rawValue,
			"rangeType":		CNValueType.rangeType.rawValue,
			"pointType":		CNValueType.pointType.rawValue,
			"sizeType":		CNValueType.sizeType.rawValue,
			"rectType":		CNValueType.rectType.rawValue,
			"enumType":		CNValueType.enumType.rawValue,
			"dictionaryType":	CNValueType.dictionaryType.rawValue,
			"arrayType":		CNValueType.arrayType.rawValue,
			"URLType":		CNValueType.URLType.rawValue,
			"colorType":		CNValueType.colorType.rawValue,
			"imageType":		CNValueType.imageType.rawValue,
			"recordType":		CNValueType.recordType.rawValue,
			"segmentType":		CNValueType.segmentType.rawValue,
			"objectType":		CNValueType.objectType.rawValue
		])
		self.add(enumType: valtype)

		let filetype = CNEnumType(typeName: "FileType")
		filetype.add(members: [
			"notExist":		CNFileType.NotExist.rawValue,
			"file":			CNFileType.File.rawValue,
			"directory":		CNFileType.Directory.rawValue
		])
		self.add(enumType: filetype)

		let acctype = CNEnumType(typeName: "AccessType")
		acctype.add(members: [
			"read":			CNFileAccessType.ReadAccess.rawValue,
			"write": 		CNFileAccessType.WriteAccess.rawValue,
			"append": 		CNFileAccessType.AppendAccess.rawValue
		])
		self.add(enumType: acctype)

		let axis = CNEnumType(typeName: CNAxis.typeName)
		axis.add(members: [
			"horizontal":		CNAxis.horizontal.rawValue,
			"vertical":		CNAxis.vertical.rawValue
		])
		self.add(enumType: axis)

		let alignment = CNEnumType(typeName: CNAlignment.typeName)
		alignment.add(members: [
			"leading": 		CNAlignment.leading.rawValue,
			"trailing": 		CNAlignment.trailing.rawValue,
			"fill": 		CNAlignment.fill.rawValue,
			"center": 		CNAlignment.center.rawValue
		])
		self.add(enumType: alignment)

		let distribution = CNEnumType(typeName: CNDistribution.typeName)
		distribution.add(members: [
			"fill":			CNDistribution.fill.rawValue,
			"fillProportinally":	CNDistribution.fillProportinally.rawValue,
			"fillEqually":		CNDistribution.fillEqually.rawValue,
			"equalSpacing":		CNDistribution.equalSpacing.rawValue
		])
		self.add(enumType: distribution)

		let fontsize = CNEnumType(typeName: "FontSize")
		fontsize.add(members: [
			"small":		Int(CNFont.smallSystemFontSize),
			"regular":		Int(CNFont.systemFontSize),
			"large": 		Int(CNFont.systemFontSize * 1.5)
		])
		self.add(enumType: fontsize)

		let textalign = CNEnumType(typeName: "TextAlign")
		textalign.add(members: [
			"left":			NSTextAlignment.left.rawValue,
			"center":		NSTextAlignment.center.rawValue,
			"right":		NSTextAlignment.right.rawValue,
			"justfied":		NSTextAlignment.justified.rawValue,
			"normal":		NSTextAlignment.natural.rawValue
		])
		self.add(enumType: textalign)

		let authorize = CNEnumType(typeName: "Authorize")
		authorize.add(members: [
			"undetermined":		CNAuthorizeState.Undetermined.rawValue,
			"denied":		CNAuthorizeState.Denied.rawValue,
			"authorized":		CNAuthorizeState.Authorized.rawValue
		])
		self.add(enumType: authorize)

		let animstate = CNEnumType(typeName: "AnimationState")
		animstate.add(members: [
			"idle":			CNAnimationState.idle.rawValue,
			"run":			CNAnimationState.run.rawValue,
			"pause":		CNAnimationState.pause.rawValue
		])
		self.add(enumType: animstate)

		let compres = CNEnumType(typeName: "ComparisonResult")
		compres.add(members: [
			"ascending":		ComparisonResult.orderedAscending.rawValue,
			"same":			ComparisonResult.orderedSame.rawValue,
			"descending":		ComparisonResult.orderedDescending.rawValue
		])
		self.add(enumType: compres)

		let sortorder = CNEnumType(typeName: "SortOrder")
		sortorder.add(members: [
			"none":			CNSortOrder.none.rawValue,
			"increasing":		CNSortOrder.increasing.rawValue,
			"decreasing":		CNSortOrder.decreasing.rawValue
		])
		self.add(enumType: sortorder)
	}
}

