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
	private static let 	ClassName = "enum"
	public typealias	Value     = CNEnumType.Value

	private var		mEnumType:	CNEnumType
	private var 		mMemberName:	String

	public static var className: String { get {
		return CNEnum.ClassName
	}}

	public var enumType: CNEnumType? { get {
		return mEnumType
	}}

	public var memberName: String { get {
		return mMemberName
	}}

	public init(type t: CNEnumType, member n: String){
		mEnumType	= t
		mMemberName	= n
	}

	public var typeName: String { get {
		return mEnumType.typeName
	}}

	public var value: Value { get {
		if let val = mEnumType.value(forMember: mMemberName) {
			return val
		} else {
			CNLog(logLevel: .error, message: "No value for member \(mMemberName)", atFunction: #function, inFile: #file)
			return .intValue(0)
		}
	}}

	public func compare(_ v: CNEnum) -> ComparisonResult {
		switch CNComparator.compare(string0: self.typeName, string1: v.typeName) {
		case .orderedSame:
			return CNComparator.compare(string0: self.memberName, string1: v.memberName)
		case .orderedDescending:
			return .orderedDescending
		case .orderedAscending:
			return .orderedAscending
		}
	}
}

public class CNEnumType
{
	public static let ClassName		= "enumType"

	public enum Value {
		case intValue(Int)
		case stringValue(String)

		public func toValue() -> CNValue {
			switch self {
			case .intValue(let ival):	return CNValue.numberValue(NSNumber(integerLiteral: ival))
			case .stringValue(let sval):	return CNValue.stringValue(sval)
			}
		}

		public func toScript() -> String {
			switch self {
			case .intValue(let ival):	return "\(ival)"
			case .stringValue(let sval):	return "\"\(sval)\""
			}
		}

		public static func isSame(_ val0: Value, _ val1: Value) -> Bool {
			var result = false
			switch val0 {
			case .intValue(let i0):
				switch val1 {
				case .intValue(let i1):
					result = (i0 == i1)
				case .stringValue(_):
					break
				}
			case .stringValue(let s0):
				switch val1 {
				case .intValue(_):
					break
				case .stringValue(let s1):
					result = (s0 == s1)
				}
			}
			return result
		}
	}

	private var mTypeName:		String
	private var mMembers:		Dictionary<String, Value>	// <member-name, value>

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

	public func add(name nm: String, value val: Value){
		mMembers[nm] = val
	}

	public func add(members membs: Dictionary<String, Value>){
		for key in membs.keys.sorted() {
			if let val = membs[key] {
				self.add(name: key, value: val)
			}
		}
	}

	public var names: Array<String> { get {
		return mMembers.keys.sorted()
	}}

	public func value(forMember name: String) -> Value? {
		return mMembers[name]
	}

	public func search(byValue targ: Value) -> CNEnum? {
		for (key, val) in mMembers {
			if CNEnumType.Value.isSame(targ, val) {
				return CNEnum(type: self, member: key)
			}
		}
		return nil
	}
}

public class CNEnumTable
{
	public static let  ClassName		= "enumTable"

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
		return mEnumTables.peekAll(doReverseOrder: true)
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

	private func setDefaultValues() {
		let alertcode = CNEnumType(typeName: "AlertType")
		alertcode.add(members: [
			"informational":	.intValue(CNAlertType.informational.rawValue),
			"warning":		.intValue(CNAlertType.warning.rawValue),
			"critical": 		.intValue(CNAlertType.critical.rawValue)
		])
		self.add(enumType: alertcode)

		let exitcode = CNEnumType(typeName: "ExitCode")
		exitcode.add(members: [
			"noError": 		.intValue(CNExitCode.NoError.rawValue),
			"internalError":	.intValue(CNExitCode.InternalError.rawValue),
			"commaneLineError":	.intValue(CNExitCode.CommandLineError.rawValue),
			"syntaxError":		.intValue(CNExitCode.SyntaxError.rawValue),
			"exception":		.intValue(CNExitCode.Exception.rawValue)
		])
		self.add(enumType: exitcode)

		let logcode = CNEnumType(typeName: "LogLevel")
		logcode.add(members: [
			"nolog":		.intValue(CNConfig.LogLevel.nolog.rawValue),
			"error":		.intValue(CNConfig.LogLevel.error.rawValue),
			"warning":		.intValue(CNConfig.LogLevel.warning.rawValue),
			"debug":		.intValue(CNConfig.LogLevel.debug.rawValue),
			"detail":		.intValue(CNConfig.LogLevel.detail.rawValue)
		])
		self.add(enumType: logcode)

		let filetype = CNEnumType(typeName: "FileType")
		filetype.add(members: [
			"notExist":		.intValue(CNFileType.NotExist.rawValue),
			"file":			.intValue(CNFileType.File.rawValue),
			"directory":		.intValue(CNFileType.Directory.rawValue)
		])
		self.add(enumType: filetype)

		let acctype = CNEnumType(typeName: "AccessType")
		acctype.add(members: [
			"read":			.intValue(CNFileAccessType.ReadAccess.rawValue),
			"write": 		.intValue(CNFileAccessType.WriteAccess.rawValue),
			"append": 		.intValue(CNFileAccessType.AppendAccess.rawValue)
		])
		self.add(enumType: acctype)

		let axis = CNEnumType(typeName: CNAxis.typeName)
		axis.add(members: [
			"horizontal":		.intValue(CNAxis.horizontal.rawValue),
			"vertical":		.intValue(CNAxis.vertical.rawValue)
		])
		self.add(enumType: axis)

		let alignment = CNEnumType(typeName: CNAlignment.typeName)
		alignment.add(members: [
			"leading": 		.intValue(CNAlignment.leading.rawValue),
			"trailing": 		.intValue(CNAlignment.trailing.rawValue),
			"fill": 		.intValue(CNAlignment.fill.rawValue),
			"center": 		.intValue(CNAlignment.center.rawValue)
		])
		self.add(enumType: alignment)

		let btnstate = CNEnumType(typeName: CNButtonState.typeName)
		btnstate.add(members: [
			"hidden":	.intValue(CNButtonState.hidden.rawValue),
			"disable":	.intValue(CNButtonState.disable.rawValue),
			"off":		.intValue(CNButtonState.off.rawValue),
			"on":		.intValue(CNButtonState.on.rawValue)
		])
		self.add(enumType: btnstate)

		let distribution = CNEnumType(typeName: CNDistribution.typeName)
		distribution.add(members: [
			"fill":			.intValue(CNDistribution.fill.rawValue),
			"fillProportinally":	.intValue(CNDistribution.fillProportinally.rawValue),
			"fillEqually":		.intValue(CNDistribution.fillEqually.rawValue),
			"equalSpacing":		.intValue(CNDistribution.equalSpacing.rawValue)
		])
		self.add(enumType: distribution)

		let fontsize = CNEnumType(typeName: "FontSize")
		fontsize.add(members: [
			"small":		.intValue(Int(CNFont.smallSystemFontSize)),
			"regular":		.intValue(Int(CNFont.systemFontSize)),
			"large": 		.intValue(Int(CNFont.systemFontSize * 1.5))
		])
		self.add(enumType: fontsize)

		let symbol = CNEnumType(typeName: CNSymbol.typeName)
		var symbols: Dictionary<String, CNEnumType.Value> = [:]
		for sym in CNSymbol.allCases {
			symbols[sym.identifier] = .stringValue(sym.name)
		}
		symbol.add(members: symbols)
		self.add(enumType: symbol)

		let symsize = CNEnumType(typeName: CNSymbolSize.typeName)
		symsize.add(members: [
			"small":		.intValue(Int(CNSymbolSize.small.rawValue)),
			"regular":		.intValue(Int(CNSymbolSize.regular.rawValue)),
			"large": 		.intValue(Int(CNSymbolSize.large.rawValue))
		])
		self.add(enumType: symsize)

		let textalign = CNEnumType(typeName: "TextAlign")
		textalign.add(members: [
			"left":			.intValue(NSTextAlignment.left.rawValue),
			"center":		.intValue(NSTextAlignment.center.rawValue),
			"right":		.intValue(NSTextAlignment.right.rawValue),
			"justfied":		.intValue(NSTextAlignment.justified.rawValue),
			"normal":		.intValue(NSTextAlignment.natural.rawValue)
		])
		self.add(enumType: textalign)

		let authorize = CNEnumType(typeName: "Authorize")
		authorize.add(members: [
			"undetermined":		.intValue(CNAuthorizeState.Undetermined.rawValue),
			"denied":		.intValue(CNAuthorizeState.Denied.rawValue),
			"authorized":		.intValue(CNAuthorizeState.Authorized.rawValue)
		])
		self.add(enumType: authorize)

		let animstate = CNEnumType(typeName: "AnimationState")
		animstate.add(members: [
			"idle":			.intValue(CNAnimationState.idle.rawValue),
			"run":			.intValue(CNAnimationState.run.rawValue),
			"pause":		.intValue(CNAnimationState.pause.rawValue)
		])
		self.add(enumType: animstate)

		let compres = CNEnumType(typeName: "ComparisonResult")
		compres.add(members: [
			"ascending":		.intValue(ComparisonResult.orderedAscending.rawValue),
			"same":			.intValue(ComparisonResult.orderedSame.rawValue),
			"descending":		.intValue(ComparisonResult.orderedDescending.rawValue)
		])
		self.add(enumType: compres)

		let sortorder = CNEnumType(typeName: "SortOrder")
		sortorder.add(members: [
			"none":			.intValue(CNSortOrder.none.rawValue),
			"increasing":		.intValue(CNSortOrder.increasing.rawValue),
			"decreasing":		.intValue(CNSortOrder.decreasing.rawValue)
		])
		self.add(enumType: sortorder)
	}
}

