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

open class CNPreference
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

	public let LogLevelItem	= "logLevel"

	public override init(){
		super.init()
		let level: LogLevel = .error
		super.set(intValue: level.rawValue, forKey: LogLevelItem)
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
}

extension CNPreference
{
	public var systemPreference: CNSystemPreference { get {
		return get(name: "system", allocator: {
			() -> CNSystemPreference in
				return CNSystemPreference()
		})
	}}

	open func set(config conf: CNConfig){
		CNPreference.shared.systemPreference.logLevel = conf.logLevel
	}
}

