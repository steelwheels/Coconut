/**
 * @file	CNSignal.swift
 * @brief	Define CNSignal class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 * @reference
 *   The original source is copied from https://github.com/IBM-Swift/BlueSignals/blob/master/Sources/Signals/Signals.swift
 */

import Foundation
import Darwin

public class CNSignalManager
{
	public enum Signal {
		case hup
		case int
		case quit
		case abrt
		case kill
		case alrm
		case term
		case pipe
		case user(Int)

		public var valueOf: Int32 {

			switch self {
			case .hup:
				return Int32(SIGHUP)
			case .int:
				return Int32(SIGINT)
			case .quit:
				return Int32(SIGQUIT)
			case .abrt:
				return Int32(SIGABRT)
			case .kill:
				return Int32(SIGKILL)
			case .alrm:
				return Int32(SIGALRM)
			case .term:
				return Int32(SIGTERM)
			case .pipe:
				return Int32(SIGPIPE)
			case .user(let sig):
				return Int32(sig)

			}
		}
	}

	public typealias SigActionHandler = @convention(c)(Int32) -> Void

	public class func trap(signal: Signal, action: @escaping SigActionHandler) {
		var signalAction = sigaction(__sigaction_u: unsafeBitCast(action, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)

		_ = withUnsafePointer(to: &signalAction) { actionPointer in
			sigaction(signal.valueOf, actionPointer, nil)
		}
	}

	public class func trap(signals: [(signal: Signal, action: SigActionHandler)]) {
		for sighandler in signals {
			CNSignalManager.trap(signal: sighandler.signal, action: sighandler.action)
		}
	}

	public class func trap(signals: [Signal], action: @escaping SigActionHandler) {
		for signal in signals {
			CNSignalManager.trap(signal: signal, action: action)
		}
	}

	public class func raise(signal: Signal) {
		_ = Darwin.raise(signal.valueOf)
	}

	public class func ignore(signal: Signal) {
		_ = Darwin.signal(signal.valueOf, SIG_IGN)
	}

	public class func restore(signal: Signal){
		_ = Darwin.signal(signal.valueOf, SIG_DFL)
	}

}
