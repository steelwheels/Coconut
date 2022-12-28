/**
 * @file	CNPreference.swift
 * @brief	Define CNPreference class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

open class CNConfig
{
	public enum LogLevel: Int {
		case nolog	= 0	// No log
		case error	= 1	// Ony error log
		case warning	= 2	// + warning log
		case debug	= 3	// + debug log
		case detail	= 4	// + detail

		public static let min	: Int	= LogLevel.nolog.rawValue
		public static let max	: Int 	= LogLevel.detail.rawValue

		public var description: String {
			get {
				let result: String
				switch self {
				case .nolog:	result = "nolog"
				case .error:	result = "error"
				case .warning:	result = "warning"
				case .debug:	result = "debug"
				case .detail:	result = "detail"
				}
				return result
			}
		}

		public func isIncluded(in level: LogLevel) -> Bool {
			return self.rawValue >= level.rawValue
		}

		public static var defaultLevel: LogLevel {
			return .warning
		}

		public static func decode(string str: String) -> LogLevel? {
			let result: LogLevel?
			switch str {
			case "nolog":		result = .nolog
			case "error":		result = .error
			case "warning":		result = .warning
			case "debug":		result = .debug
			case "detail":		result = .detail
			default:		result = nil
			}
			return result
		}
	}

	public var logLevel:	LogLevel

	public init(logLevel log: LogLevel){
		logLevel = log
	}
}

public enum CNInterfaceStyle: Int {
	case light              = 0
	case dark               = 1

	public var description: String {
		let result: String
		switch self {
		case .dark:	result = "dark"
		case .light:	result = "light"
		}
		return result
	}

	public static func decode(name nm: String) -> CNInterfaceStyle? {
		let style: CNInterfaceStyle?
		switch nm {
		case "dark":	style = .dark
		case "light":	style = .light
		default:	style = nil
		}
		return style
	}
}

public class CNPreference
{
	public static var mShared: CNPreference? = nil

	public static var shared: CNPreference { get {
		if let obj = mShared {
			return obj
		} else {
			let newobj = CNPreference()
			mShared = newobj
			return newobj
		}
	}}

	private var mTable:		Dictionary<String, CNPreferenceTable>
	private var mUserDefaults:	UserDefaults

	private init(){
		mTable		= [:]
		mUserDefaults	= UserDefaults.standard
	}

	public func get<T: CNPreferenceTable>(name nm: String, allocator alloc: () -> T) -> T {
		if let anypref = mTable[nm] as? T {
			return anypref
		} else {
			let newpref = alloc()
			mTable[nm]  = newpref
			return newpref
		}
	}

	/* This method will be accessed by sub class*/
	public func peekTable(name nm: String) -> CNPreferenceTable? {
		return mTable[nm]
	}

	/* This method will be accessed by sub class*/
	public func pokeTable(name nm: String, table tbl: CNPreferenceTable) {
		mTable[nm] = tbl
	}
}

public class CNSystemPreference: CNPreferenceTable
{
	public typealias LogLevel = CNConfig.LogLevel

	public static let LogLevelItem		= "logLevel"
	public static let InterfaceStyleItem	= "interfaceStrle"

	public init(){
		super.init(sectionName: "SystemPreference")

		/* Set initial value */
		if let logval = super.loadIntValue(forKey: CNSystemPreference.LogLevelItem) {
			if let _ = LogLevel(rawValue: logval) {
				super.set(intValue: logval, forKey: CNSystemPreference.LogLevelItem)
			} else {
				CNLog(logLevel: .error, message: "Unknown log level", atFunction: #function, inFile: #file)
				super.set(intValue: LogLevel.defaultLevel.rawValue, forKey: CNSystemPreference.LogLevelItem)
			}
		} else {
			super.set(intValue: LogLevel.defaultLevel.rawValue, forKey: CNSystemPreference.LogLevelItem)
		}

		let style = self.interfaceStyle
		super.set(intValue: style.rawValue, forKey: CNSystemPreference.InterfaceStyleItem)

		/* Watch interface style switching */
		#if os(OSX)
			let center = DistributedNotificationCenter.default()
			center.addObserver(self,
					   selector: #selector(interfaceModeChanged(sender:)),
					   name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"),
					   object: nil)
		#endif
	}

	deinit {
		#if os(OSX)
			let center = DistributedNotificationCenter.default()
			center.removeObserver(self)
		#endif
	}

	@objc public func interfaceModeChanged(sender: NSNotification) {
		let style = self.interfaceStyle
		super.set(intValue: style.rawValue, forKey: CNSystemPreference.InterfaceStyleItem)
        }

	open func set(config conf: CNConfig){
		self.logLevel = conf.logLevel
	}

	public var version: String {
		get {
			if let str = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
				return str
			} else {
				return "unknown"
			}
		}
	}

	public var interfaceStyle: CNInterfaceStyle {
                get {
			let result: CNInterfaceStyle
                        #if os(OSX)
				if let _ = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") {
					result = .dark
				} else {
					result = .light
				}
                        #else
                                result = .light
                        #endif
                        return result
                }
        }

	public var logLevel: LogLevel {
		get {
			if let ival = super.intValue(forKey: CNSystemPreference.LogLevelItem) {
				if let level = CNConfig.LogLevel(rawValue: ival) {
					return level
				}
			}
			return CNConfig.LogLevel.defaultLevel
		}
		set(level){
			super.set(intValue: level.rawValue, forKey: CNSystemPreference.LogLevelItem)
		}
	}
}

public class CNUserPreference: CNPreferenceTable
{
	public let DocumentDirectoryItem = "documentDirectory"
	public let LibraryDirectoryItem  = "libraryDirectory"

	public init() {
		super.init(sectionName: "UserPreference")
		if let docdir = super.loadStringValue(forKey: DocumentDirectoryItem) {
			super.set(stringValue: docdir, forKey: DocumentDirectoryItem)
		} else {
			let docdir = FileManager.default.documentDirectory
			super.set(stringValue: docdir.path, forKey: DocumentDirectoryItem)
		}
		if let libdir = super.loadStringValue(forKey: LibraryDirectoryItem) {
			super.set(stringValue: libdir, forKey: LibraryDirectoryItem)
		} else {
			let libdir = FileManager.default.libraryDirectory
			super.set(stringValue: libdir.path, forKey: LibraryDirectoryItem)
		}
	}

	public var documentDirectory: URL {
		get {
			if let docdir = super.stringValue(forKey: DocumentDirectoryItem) {
				let pref = CNPreference.shared.bookmarkPreference
				if let docurl = pref.search(pathString: docdir) {
					return docurl
				} else {
					return URL(fileURLWithPath: docdir)
				}
			}
			fatalError("Can not happen at function \(#function) in file \(#file)")
		}
		set(newval){
			var isdir: ObjCBool = false
			let docdir          = newval.path
			if FileManager.default.fileExists(atPath: docdir, isDirectory: &isdir) {
				if isdir.boolValue {
					super.storeStringValue(stringValue: docdir, forKey: DocumentDirectoryItem)
					super.set(stringValue: docdir, forKey: DocumentDirectoryItem)
					return
				}
			}
			CNLog(logLevel: .error, message: "Invalid parameter", atFunction: #function, inFile: #file)
		}
	}

	public var libraryDirectory: URL {
		get {
			if let libdir = super.stringValue(forKey: LibraryDirectoryItem) {
				let pref = CNPreference.shared.bookmarkPreference
				if let liburl = pref.search(pathString: libdir) {
					return liburl
				} else {
					return URL(fileURLWithPath: libdir)
				}
			}
			fatalError("Can not happen at function \(#function) in file \(#file)")
		}
		set(newval){
			var isdir: ObjCBool = false
			let libdir          = newval.path
			if FileManager.default.fileExists(atPath: libdir, isDirectory: &isdir) {
				if isdir.boolValue {
					super.storeStringValue(stringValue: libdir, forKey: LibraryDirectoryItem)
					super.set(stringValue: libdir, forKey: LibraryDirectoryItem)
					return
				}
			}
			CNLog(logLevel: .error, message: "Invalid parameter", atFunction: #function, inFile: #file)
		}
	}
}

public class CNBookmarkPreference: CNPreferenceTable
{
	public let BookmarkItem		= "bookmark"

	public init() {
		super.init(sectionName: "BookmarkPreference")
		if let dict = super.loadDataDictionaryValue(forKey: BookmarkItem) {
			super.set(dataDictionaryValue: dict, forKey: BookmarkItem)
		} else {
			super.set(dataDictionaryValue: [:], forKey: BookmarkItem)
		}
	}

	public func add(URL url: URL) {
		if var dict = super.dataDictionaryValue(forKey: BookmarkItem) {
			let data = URLToData(URL: url)
			dict[url.path] = data
			super.set(dataDictionaryValue: dict, forKey: BookmarkItem)
			super.storeDataDictionaryValue(dataDictionaryValue: dict, forKey: BookmarkItem)
		} else {
			CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		}
	}

	public func search(pathString path: String) -> URL? {
		if let dict = super.dataDictionaryValue(forKey: BookmarkItem) {
			if let data = dict[path] {
				return dataToURL(bookmarkData: data)
			}
		}
		return nil
	}

	public func clear() {
		let empty: Dictionary<String, Data> = [:]
		super.set(dataDictionaryValue: empty, forKey: BookmarkItem)
		super.storeDataDictionaryValue(dataDictionaryValue: empty, forKey: BookmarkItem)
	}

	private func URLToData(URL url: URL) -> Data {
		do {
			#if os(OSX)
				let data = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
			#else
				let data = try url.bookmarkData(options: .suitableForBookmarkFile, includingResourceValuesForKeys: nil, relativeTo: nil)
			#endif
			return data
		} catch {
			let err = error as NSError
			fatalError("\(err.description)")
		}
	}

	private func dataToURL(bookmarkData bmdata: Data) -> URL? {
		do {
			var isstale: Bool = false
			#if os(OSX)
				let newurl = try URL(resolvingBookmarkData: bmdata, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isstale)
			#else
				let newurl = try URL(resolvingBookmarkData: bmdata, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: &isstale)
			#endif
			return newurl
		}
		catch {
			let err = error as NSError
			CNLog(logLevel: .error, message: err.description, atFunction: #function, inFile: #file)
			return nil
		}
	}
}

public class CNViewPreference: CNPreferenceTable
{
	public let ForegroundColorItem	= "foregroundColor"
	public let BackgroundColorItem	= "backgroundColor"

	public init() {
		super.init(sectionName: "ViewPreference")

		if let coldict = super.loadColorDictionaryValue(forKey: ForegroundColorItem) {
			super.set(colorDictionaryValue: coldict, forKey: ForegroundColorItem)
		} else {
			let coldict: Dictionary<CNInterfaceStyle, CNColor> = [:]
			super.set(colorDictionaryValue: coldict, forKey: ForegroundColorItem)
		}

		if let coldict = super.loadColorDictionaryValue(forKey: BackgroundColorItem) {
			super.set(colorDictionaryValue: coldict, forKey: BackgroundColorItem)
		} else {
			let coldict: Dictionary<CNInterfaceStyle, CNColor> = [:]
			super.set(colorDictionaryValue: coldict, forKey: BackgroundColorItem)
		}
	}

	public var foregroundColor: CNColor {
		get {
			#if os(OSX)
			let DarkColor  = CNColor.systemGray
			let LightColor = CNColor.black
			#else
			let DarkColor  = CNColor.systemGray
			let LightColor = CNColor.black
			#endif

			if let color = self.getColor(itemName: ForegroundColorItem) {
				return color
			} else {
				let result: CNColor
				switch CNPreference.shared.systemPreference.interfaceStyle {
				case .dark:	result = DarkColor
				case .light:	result = LightColor
				}
				self.saveColor(itemName: ForegroundColorItem, color: result)
				return result
			}
		}
		set(newcol) {
			self.saveColor(itemName: ForegroundColorItem, color: newcol)
		}
	}

	public var backgroundColor: CNColor {
		get {
			#if os(OSX)
			let DarkColor  = CNColor.darkGray
			let LightColor = CNColor.white
			#else
			let DarkColor  = CNColor.systemGray6
			let LightColor = CNColor.white
			#endif

			if let color = self.getColor(itemName: BackgroundColorItem) {
				return color
			} else {
				let result: CNColor
				switch CNPreference.shared.systemPreference.interfaceStyle {
				case .dark:	result = DarkColor
				case .light:	result = LightColor
				}
				self.saveColor(itemName: BackgroundColorItem, color: result)
				return result
			}
		}
		set(newcol) {
			self.saveColor(itemName: BackgroundColorItem, color: newcol)
		}
	}

	private func getColor(itemName name: String) -> CNColor? {
		let style = CNPreference.shared.systemPreference.interfaceStyle
		if let dict = super.colorDictionaryValue(forKey: name) {
			if let color = dict[style] {
				return color
			}
		}
		return nil
	}

	private func saveColor(itemName name: String, color col: CNColor) {
		let style = CNPreference.shared.systemPreference.interfaceStyle
		if var dict = super.colorDictionaryValue(forKey: name) {
			dict[style] = col
			super.set(colorDictionaryValue: dict, forKey: name)
			super.storeColorDictionaryValue(dataDictionaryValue: dict, forKey: name)
		} else {
			let dict: Dictionary<CNInterfaceStyle, CNColor> = [style:col]
			super.set(colorDictionaryValue: dict, forKey: name)
			super.storeColorDictionaryValue(dataDictionaryValue: dict, forKey: name)
		}
	}
}

public class CNTerminalPreference: CNPreferenceTable
{
	public let WidthItem			= "width"
	public let HeightItem			= "height"
	public let ForegroundTextColorItem	= "foregroundTextColor"
	public let BackgroundTextColorItem	= "backgroundTextColor"
	public let FontItem			= "font"

	public init() {
		super.init(sectionName: "TerminalPreference")

		if let num = super.loadIntValue(forKey: WidthItem) {
			super.set(intValue: num, forKey: WidthItem)
		} else {
			self.width = 80
		}

		if let num = super.loadIntValue(forKey: HeightItem) {
			super.set(intValue: num, forKey: HeightItem)
		} else {
			self.height = 20
		}

		if let coldict = super.loadColorDictionaryValue(forKey: ForegroundTextColorItem) {
			super.set(colorDictionaryValue: coldict, forKey: ForegroundTextColorItem)
		} else {
			let coldict: Dictionary<CNInterfaceStyle, CNColor> = [:]
			super.set(colorDictionaryValue: coldict, forKey: ForegroundTextColorItem)
		}

		if let coldict = super.loadColorDictionaryValue(forKey: BackgroundTextColorItem) {
			super.set(colorDictionaryValue: coldict, forKey: BackgroundTextColorItem)
		} else {
			let coldict: Dictionary<CNInterfaceStyle, CNColor> = [:]
			super.set(colorDictionaryValue: coldict, forKey: BackgroundTextColorItem)
		}

		if let newfont = super.loadFontValue(forKey: FontItem) {
			super.set(fontValue: newfont, forKey: FontItem)
		} else {
			font = CNFont.monospacedSystemFont(ofSize: 16.0, weight: .regular)
		}
	}

	public var width: Int {
		get {
			if let val = super.intValue(forKey: WidthItem) {
				return val
			}
			fatalError("Can not happen at function \(#function) in file \(#file)")
		}
		set(newval) {
			let orgval = super.intValue(forKey: WidthItem)
			if newval != orgval {
				super.storeIntValue(intValue: newval, forKey: WidthItem)
				super.set(intValue: newval, forKey: WidthItem)
			}
		}
	}

	public var height: Int {
		get {
			if let val = super.intValue(forKey: HeightItem) {
				return val
			}
			fatalError("Can not happen at function \(#function) in file \(#file)")
		}
		set(newval) {
			let orgval = super.intValue(forKey: HeightItem)
			if newval != orgval {
				super.storeIntValue(intValue: newval, forKey: HeightItem)
				super.set(intValue: newval, forKey: HeightItem)
			}
		}
	}

	public var foregroundTextColor: CNColor {
		get {
			if let color = self.getColor(itemName: ForegroundTextColorItem) {
				return color
			} else {
				let color = CNSemanticColorTable.foregroundTextColor
				self.saveColor(itemName: ForegroundTextColorItem, color: color)
				return color
			}
		}
		set(newcol) {
			self.saveColor(itemName: ForegroundTextColorItem, color: newcol)
		}
	}

	public var backgroundTextColor: CNColor {
		get {
			if let color = self.getColor(itemName: BackgroundTextColorItem) {
				return color
			} else {
				let color = CNSemanticColorTable.backgroundTextColor
				self.saveColor(itemName: BackgroundTextColorItem, color: color)
				return color
			}
		}
		set(newcol) {
			self.saveColor(itemName: BackgroundTextColorItem, color: newcol)
		}
	}

	private func getColor(itemName name: String) -> CNColor? {
		let style = CNPreference.shared.systemPreference.interfaceStyle
		if let dict = super.colorDictionaryValue(forKey: name) {
			if let color = dict[style] {
				return color
			}
		}
		return nil
	}

	private func saveColor(itemName name: String, color col: CNColor) {
		let style = CNPreference.shared.systemPreference.interfaceStyle
		if var dict = super.colorDictionaryValue(forKey: name) {
			dict[style] = col
			super.set(colorDictionaryValue: dict, forKey: name)
			super.storeColorDictionaryValue(dataDictionaryValue: dict, forKey: name)
		} else {
			let dict: Dictionary<CNInterfaceStyle, CNColor> = [style:col]
			super.set(colorDictionaryValue: dict, forKey: name)
			super.storeColorDictionaryValue(dataDictionaryValue: dict, forKey: name)
		}
	}

	public var font: CNFont {
		get {
			if let font = super.fontValue(forKey: FontItem) {
				return font
			}
			fatalError("Can not happen at function \(#function) in file \(#file)")
		}
		set(newfont) {
			super.set(fontValue: newfont, forKey: FontItem)
			super.storeFontValue(fontValue: newfont, forKey: FontItem)
		}
	}
}

extension CNPreference
{
	public var systemPreference: CNSystemPreference { get {
		return get(name: "system", allocator: {
			() -> CNSystemPreference in
				return CNSystemPreference()
		})
	}}

	public var userPreference: CNUserPreference { get {
		return get(name: "user", allocator: {
			() -> CNUserPreference in
				return CNUserPreference()
		})
	}}

	public var bookmarkPreference: CNBookmarkPreference { get {
		return get(name: "bookmark", allocator: {
			() -> CNBookmarkPreference in
				return CNBookmarkPreference()
		})
	}}

	public var viewPreference: CNViewPreference { get {
		return get(name: "view", allocator: {
			() -> CNViewPreference in
				return CNViewPreference()
		})
	}}

	public var terminalPreference: CNTerminalPreference { get {
		return get(name: "terminal", allocator: {
			() -> CNTerminalPreference in
				return CNTerminalPreference()
		})
	}}
}

