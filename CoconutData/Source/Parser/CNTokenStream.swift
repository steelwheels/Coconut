/**
 * @file	CNTokenStream.swift
 * @brief	Define CNArrayStream class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public class CNTokenStream
{
	private var mStream	: CNArrayStream<CNToken>

	public required init(source src: Array<CNToken>){
		mStream = CNArrayStream(source: src)
	}

	public var count: Int {
		get { return mStream.count }
	}

	public var lineNo: Int? {
		if let token = mStream.peek(offset: 0) {
			return token.lineNo
		} else {
			return nil
		}
	}

	public func get() -> CNToken? {
		if let token = mStream.get() {
			return token
		} else {
			return nil
		}
	}

	public func getReservedWord() -> Int? {
		if let token = mStream.get() {
			return token.getReservedWord()
		} else {
			return nil
		}
	}

	public func requireReservedWord(reservedWordId rid: Int) -> Bool {
		if let token = mStream.get() {
			if let cid = token.getReservedWord() {
				if cid == rid {
					return true
				}
			}
			let _ = mStream.unget()
		}
		return false
	}

	public func getSymbol() -> Character? {
		if let token = mStream.get() {
			return token.getSymbol()
		} else {
			return nil
		}
	}

	public func requireSymbol(symbol sym: Character) -> Bool {
		if let token = mStream.get() {
			if let val = token.getSymbol() {
				if val == sym {
					return true
				}
			}
			let _ = mStream.unget()
		}
		return false
	}

	public func getIdentifier() -> String? {
		if let token = mStream.get() {
			return token.getIdentifier()
		} else {
			return nil
		}
	}

	public func requireIdentifier(identifier ident: String) -> Bool {
		if let token = mStream.get() {
			if let val = token.getIdentifier() {
				if val == ident {
					return true
				}
			}
			let _ = mStream.unget()
		}
		return  false
	}

	public func requireAnyIdentifier() -> String? {
		if let token = mStream.get() {
			if let val = token.getIdentifier() {
				return val
			}
			let _ = mStream.unget()
		}
		return nil
	}

	public func getBool() -> Bool? {
		if let token = mStream.get() {
			return token.getBool()
		} else {
			return nil
		}
	}

	public func requireBool(value src: Bool) -> Bool {
		if let token = mStream.get() {
			if let val = token.getBool() {
				if val == src {
					return true
				}
			}
			let _ = mStream.unget()
		}
		return false
	}

	public func getInt() -> Int? {
		if let token = mStream.get() {
			return token.getInt()
		} else {
			return nil
		}
	}

	public func requireInt(value src: Int) -> Bool {
		if let token = mStream.get() {
			if let val = token.getInt() {
				if val == src {
					return true
				}
			}
			let _ = mStream.unget()
		}
		return false
	}

	public func getUInt() -> UInt? {
		if let token = mStream.get() {
			return token.getUInt()
		} else {
			return nil
		}
	}

	public func requireUInt(value src: UInt) -> Bool {
		if let token = mStream.get() {
			if let val = token.getUInt() {
				if val == src {
					return true
				}
			}
			let _ = mStream.unget()
		}
		return false
	}

	public func getDouble() -> Double? {
		if let token = mStream.get() {
			return token.getDouble()
		} else {
			return nil
		}
	}

	public func requireDouble(value src: Double) -> Bool {
		if let token = mStream.get() {
			if let val = token.getDouble() {
				if val == src {
					return true
				}
			}
			let _ = mStream.unget()
		}
		return false
	}

	public func getAnyInt() -> Int? {
		if let token = mStream.get() {
			if let val = token.getInt() {
				return val
			} else if let val = token.getUInt() {
				return Int(val)
			} else if let val = token.getDouble() {
				return Int(val)
			}
		}
		return nil
	}

	public func getAnyDouble() -> Double? {
		if let token = mStream.get() {
			if let val = token.getInt() {
				return Double(val)
			} else if let val = token.getUInt() {
				return Double(val)
			} else if let val = token.getDouble() {
				return val
			}
		}
		return nil
	}

	public func getString() -> String? {
		if let token = mStream.get() {
			return token.getString()
		} else {
			return nil
		}
	}

	public func requireString(value src: String) -> Bool {
		if let token = mStream.get() {
			if let val = token.getString() {
				if val == src {
					return true
				}
			}
			let _ = mStream.unget()
		}
		return false
	}

	public func getText() -> String? {
		if let token = mStream.get() {
			return token.getText()
		} else {
			return nil
		}
	}

	public func requireText(value src: String) -> Bool {
		if let token = mStream.get() {
			if let val = token.getText() {
				if val == src {
					return true
				}
			}
			let _ = mStream.unget()
		}
		return false
	}

	public func unget() -> CNToken? {
		return mStream.unget()
	}

	public func peek(offset ofst: Int) -> CNToken? {
		return mStream.peek(offset: ofst)
	}

	public func isEmpty() -> Bool {
		return mStream.isEmpty()
	}

	public func append(item newitem: CNToken){
		mStream.append(item: newitem)
	}

	public func trace(trace trc: (_ src: CNToken) -> Bool) -> Array<CNToken> {
		return mStream.trace(trace: trc)
	}

	public var description: String {
		return mStream.description
	}
}


