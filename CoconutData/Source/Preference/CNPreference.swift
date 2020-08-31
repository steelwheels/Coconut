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
			return self.rawValue <= level.rawValue
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
	public static let shared = CNPreference()

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
		let level: LogLevel = .nolog
		super.set(intValue: level.rawValue, forKey: CNSystemPreference.LogLevelItem)

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
		//NSLog("\(#file) interface mode changed: \(style.description)")
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
			NSLog("No defined value")
			return CNConfig.LogLevel.detail
		}
		set(level){
			super.set(intValue: level.rawValue, forKey: CNSystemPreference.LogLevelItem)
		}
	}
}

public class CNUserPreference: CNPreferenceTable
{
	public let HomeDirectoryItem		= "homeDirectory"

	public init() {
		super.init(sectionName: "UserPreference")
		if let homedir = super.loadStringValue(forKey: HomeDirectoryItem) {
			super.set(stringValue: homedir, forKey: HomeDirectoryItem)
		} else {
			let homedir: String
			#if os(OSX)
				homedir = FileManager.default.homeDirectoryForCurrentUser.path
			#else
				homedir = NSHomeDirectory()
			#endif
			super.set(stringValue: homedir, forKey: HomeDirectoryItem)
		}
	}

	public var homeDirectory: URL {
		get {
			if let homedir = super.stringValue(forKey: HomeDirectoryItem) {
				let pref = CNPreference.shared.bookmarkPreference
				if let homeurl = pref.search(pathString: homedir) {
					return homeurl
				} else {
					return URL(fileURLWithPath: homedir)
				}
			}
			fatalError("Can not happen")
		}
		set(newval){
			var isdir: ObjCBool = false
			let homedir         = newval.path
			if FileManager.default.fileExists(atPath: homedir, isDirectory: &isdir) {
				if isdir.boolValue {
					super.storeStringValue(stringValue: homedir, forKey: HomeDirectoryItem)
					super.set(stringValue: homedir, forKey: HomeDirectoryItem)
					return
				}
			}
			NSLog("Invalid parameter")
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
			NSLog("Can not happen")
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
		}
		catch let err as NSError {
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
			NSLog("Failed to resolve bookmark")
			return nil
		}
	}
}

public class CNTerminalPreference: CNPreferenceTable
{
	public let ColumnNumberItem		= "colmunNumber"
	public let RowNumberItem		= "rowNumber"
	public let ForegroundTextColorItem	= "foregroundTextColor"
	public let BackgroundTextColorItem	= "backgroundTextColor"
	public let FontItem			= "font"

	public init() {
		super.init(sectionName: "TerminalPreference")

		if let num = super.loadIntValue(forKey: ColumnNumberItem) {
			super.set(intValue: num, forKey: ColumnNumberItem)
		} else {
			self.columnNumber = 80
		}

		if let num = super.loadIntValue(forKey: RowNumberItem) {
			super.set(intValue: num, forKey: RowNumberItem)
		} else {
			self.rowNumber = 25
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
			if let newfont = CNFont(name: "Courier", size: 14.0) {
				font = newfont
			} else {
				font = CNFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .regular)
			}
		}
	}

	public var columnNumber: Int {
		get {
			if let val = super.intValue(forKey: ColumnNumberItem) {
				return val
			}
			fatalError("Can not happen")
		}
		set(newval) {
			if newval != super.intValue(forKey: ColumnNumberItem) {
				super.storeIntValue(intValue: newval, forKey: ColumnNumberItem)
			}
			super.set(intValue: newval, forKey: ColumnNumberItem)
		}
	}

	public var rowNumber: Int {
		get {
			if let val = super.intValue(forKey: RowNumberItem) {
				return val
			}
			fatalError("Can not happen")
		}
		set(newval) {
			if newval != super.intValue(forKey: RowNumberItem) {
				super.storeIntValue(intValue: newval, forKey: RowNumberItem)
			}
			super.set(intValue: newval, forKey: RowNumberItem)
		}
	}

	public var foregroundTextColor: CNColor {
		get {
			if let color = self.getColor(itemName: ForegroundTextColorItem) {
				return color
			} else {
				let result: CNColor
				switch CNPreference.shared.systemPreference.interfaceStyle {
				case .dark:	result = CNColor.white
				case .light:	result = CNColor.black
				}
				self.saveColor(itemName: ForegroundTextColorItem, color: result)
				return result
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
				let result: CNColor
				switch CNPreference.shared.systemPreference.interfaceStyle {
				case .dark:	result = CNColor.black
				case .light:	result = CNColor.white
				}
				self.saveColor(itemName: BackgroundTextColorItem, color: result)
				return result
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
			fatalError("Can not happen")
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

	public var terminalPreference: CNTerminalPreference { get {
		return get(name: "terminal", allocator: {
			() -> CNTerminalPreference in
				return CNTerminalPreference()
		})
	}}
}

