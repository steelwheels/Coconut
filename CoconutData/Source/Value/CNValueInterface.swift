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
		let type   = self.toType()
		loop: for (tkey, ttyp) in type.types {
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

	public func toType() -> CNInterfaceType {
		if let typ = mType {
			return typ
		} else if let typ = mTypeCache {
			return typ
		} else {
			fatalError("Can not happen")
		}
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
	}
}

/*


	 public static let  ClassName		= "enumTable"

	 private static let definitionsItem	= "definitions"




	 public static func allEnumTables() -> Array<CNEnumTable> {
		 allocateDefaultEnumTable()
		 return mEnumTables.peekAll(doReverseOrder: true)
	 }









	 public var allTypes: Dictionary<String, CNEnumType> { get {
		 return mTypes
	 }}

	 public var count: Int { get {
		 return mTypes.count
	 }}





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
		 let alertcode = CNEnumType(typeName: "AlertType")
		 alertcode.add(members: [
			 "informational":	.intValue(CNAlertType.informational.rawValue),
			 "warning":		.intValue(CNAlertType.warning.rawValue),
			 "critical": 		.intValue(CNAlertType.critical.rawValue)
		 ])
		 self.add(enumType: alertcode)

		 let devcode = CNEnumType(typeName: "Device")
		 devcode.add(members: [
			 "mac":			.intValue(CNDevice.mac.rawValue),
			 "phone":		.intValue(CNDevice.phone.rawValue),
			 "ipad":			.intValue(CNDevice.ipad.rawValue),
			 "tv":			.intValue(CNDevice.tv.rawValue),
			 "carPlay":		.intValue(CNDevice.carPlay.rawValue)
		 ])
		 self.add(enumType: devcode)

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


 */
