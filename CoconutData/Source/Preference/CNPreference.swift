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
		case error	= 0	// Error
		case warning	= 1	// + Warning (default value)
		case flow	= 2	// + Control flow
		case detail	= 3	// + Precise information

		public var description: String {
			get {
				let result: String
				switch self {
				case .error:	result = "error"
				case .warning:	result = "warning"
				case .flow:	result = "flow"
				case .detail:	result = "detail"
				}
				return result
			}
		}

		public func isMatched(logLevel level: LogLevel) -> Bool {
			return self.rawValue >= level.rawValue
		}

		public static var defaultLevel: LogLevel {
			return .warning
		}

		public static func decode(string str: String) -> LogLevel? {
			let result: LogLevel?
			switch str {
			case "error":		result = .error
			case "warning":		result = .warning
			case "flow":		result = .flow
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
}

public class CNSystemPreference: CNPreferenceTable
{
	public typealias LogLevel = CNConfig.LogLevel

	public let LogLevelItem		= "logLevel"
	public let InterfaceStyleItem	= "interfaceStrle"

	public init(){
		super.init(sectionName: "SystemPreference")

		/* Set initial value */
		let level: LogLevel = .error
		super.set(intValue: level.rawValue, forKey: LogLevelItem)

		let style = self.interfaceStyle
		super.set(intValue: style.rawValue, forKey: InterfaceStyleItem)

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
		// NSLog("\(#file) interface mode changed: \(style.description)")
		super.set(intValue: style.rawValue, forKey: InterfaceStyleItem)
        }

	open func set(config conf: CNConfig){
		self.logLevel = conf.logLevel
	}

	public var logLevel: LogLevel {
		get {
			if let ival = super.intValue(forKey: LogLevelItem) {
				if let level = CNConfig.LogLevel(rawValue: ival) {
					return level
				}
			}
			NSLog("No defined value")
			return CNConfig.LogLevel.detail
		}
		set(level){
			super.set(intValue: level.rawValue, forKey: LogLevelItem)
		}
	}

	public var interfaceStyle: CNInterfaceStyle {
                get {
                        let result: CNInterfaceStyle
                        #if os(OSX)
                                let appearance = NSApplication.shared.effectiveAppearance.name
                                switch appearance {
				case .aqua, .accessibilityHighContrastAqua, .accessibilityHighContrastVibrantLight, .vibrantLight:
					result = .light
				case .darkAqua, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark, .vibrantDark:
					result = .dark
				default:
					result = .light
			}
                        #else
                                result = .light
                        #endif
                        return result
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
}

