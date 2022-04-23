/**
 * @file	CNTokenStream.swift
 * @brief	Define CNArrayStream class
 * @par Copyright
 *   Copyright (C) 2017 -2022 Steel Wheels Project
 */

import Foundation

public class CNTokenStream
{
	private var mStream	: CNArrayStream<CNToken>

	public required init(source src: Array<CNToken>){
		mStream = CNArrayStream(source: src)
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

	public func requireReservedWord() -> Int? {
		if let token = mStream.get() {
			if let val = token.getReservedWord() {
				return val
			}
			let _ = mStream.unget()
		}
		return nil
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

	public func requireSymbol() -> Character? {
		if let token = mStream.get() {
			if let val = token.getSymbol() {
				return val
			}
			let _ = mStream.unget()
		}
		return nil
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

	public func requireIdentifier() -> String? {
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

	public func requireBool() -> Bool? {
		if let token = mStream.get() {
			if let val = token.getBool() {
				return val
			}
			let _ = mStream.unget()
		}
		return nil
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

	public func requireInt() -> Int? {
		if let token = mStream.get() {
			if let val = token.getInt() {
				return val
			}
			let _ = mStream.unget()
		}
		return nil
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

	public func requireUInt() -> UInt? {
		if let token = mStream.get() {
			if let val = token.getUInt() {
				return val
			}
			let _ = mStream.unget()
		}
		return nil
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

	public func requireDouble() -> Double? {
		if let token = mStream.get() {
			if let val = token.getDouble() {
				return val
			}
			let _ = mStream.unget()
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

	public func requireString() -> String? {
		if let token = mStream.get() {
			if let val = token.getString() {
				return val
			}
			let _ = mStream.unget()
		}
		return nil
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

	public func requireText() -> String? {
		if let token = mStream.get() {
			if let val = token.getText() {
				return val
			}
			let _ = mStream.unget()
		}
		return nil
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


