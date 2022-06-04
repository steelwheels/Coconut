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

public struct CNEnum {
	public static let ClassName		= "enum"

	public var name: 	String
	public var value:	Int

	public init(name n: String, value v: Int){
		name 	= n
		value	= v
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNEnum? {
		if let nameval = val["name"], let valval = val["value"] {
			if let namestr = nameval.toString(), let valnum = valval.toNumber() {
				return CNEnum(name: namestr, value: valnum.intValue)
			}
		}
		return nil
	}

	public func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"class":	.stringValue(CNEnum.ClassName),
			"name":		.stringValue(self.name),
			"value":	.numberValue(NSNumber(integerLiteral: Int(self.value)))
		]
		return result
	}

}

public class CNEnumType
{
	public static let ClassName		= "enumType"

	private var mTypeName:		String
	private var mMembers:		Array<CNEnum>

	public var typeName: String        { get { return mTypeName }}
	public var members:  Array<CNEnum> { get { return mMembers  }}

	public init(typeName name: String){
		mTypeName  = name
		mMembers   = []
	}

	public func add(member memb: CNEnum){
		mMembers.append(memb)
	}

	public func add(name nm: String, value val: Int){
		let newobj = CNEnum(name: nm, value: val)
		mMembers.append(newobj)
	}

	public func add(members membs: Dictionary<String, Int>){
		for key in membs.keys.sorted() {
			if let val = membs[key] {
				self.add(name: key, value: val)
			}
		}
	}

	public func search(byName name: String) -> CNEnum? {
		for memb in mMembers {
			if memb.name == name {
				return memb
			}
		}
		return nil
	}

	public static func fromValue(typeName name: String, value topval: Dictionary<String, CNValue>) -> Result<CNEnumType, NSError> {
		let result = CNEnumType(typeName: name)
		for (key, val) in topval {
			switch val {
			case .boolValue(let val):
				result.add(member: CNEnum(name: key, value: val ? 1 : 0))
			case .numberValue(let num):
				result.add(member: CNEnum(name: key, value: num.intValue))
			default:
				let txt = val.toText().toStrings().joined(separator: "\n")
				let err = NSError.parseError(message: "Invalid enum value: \(txt)")
				return .failure(err)
			}
		}
		return .success(result)
	}

	public func toValue() -> Dictionary<String, CNValue> {
		var result: Dictionary<String, CNValue> = [:]
		for memb in mMembers {
			result[memb.name] = .numberValue(NSNumber(integerLiteral: memb.value))
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

	public var typeNames: Array<String> { get {
		return Array(mTypes.keys)
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

	public func search(byMemberName name: String) -> Array<Int> {
		var result: Array<Int> = []
		/* User defined value is first */
		for (_, etype) in mTypes {
			if let enm = etype.search(byName: name) {
				result.append(enm.value)
			}
		}
		if let parent = mParent {
			result.append(contentsOf: parent.search(byMemberName: name))
		}
		return result
	}

	public func search(byTypeName tname: String, memberName mname: String) -> Int? {
		if let etype = self.search(byTypeName: tname) {
			if let enm = etype.search(byName: mname) {
				return enm.value
			}
		}
		if let parent = mParent {
			return parent.search(byTypeName: tname, memberName: mname)
		} else {
			return nil
		}
	}

	public func merge(enumTable src: CNEnumTable) {
		for (key, val) in src.mTypes {
			mTypes[key] = val
		}
	}

	public static func fromValue(value topval: CNValue) -> Result<CNEnumTable?, NSError> {
		guard let dictval = topval.toDictionary() else {
			return .failure(NSError.parseError(message: "Top value must be dictionary"))
		}
		guard hasClassName(value: dictval) else {
			return .failure(NSError.parseError(message: "Class name \"\(CNEnumTable.ClassName)\" is required"))
		}
		if let defs = hasDefinitions(value: dictval) {
			return fromValue(value: defs)
		} else {
			return .failure(NSError.parseError(message: "No valid definitions in enum table"))
		}
	}

	private static func hasClassName(value val: Dictionary<String, CNValue>) -> Bool {
		if let clsval = val["class"] {
			if let clsstr = clsval.toString() {
				if clsstr == CNEnumTable.ClassName {
					return true
				}
			}
		}
		return false
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
	}
}
