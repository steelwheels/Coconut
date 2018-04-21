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

	public init(source src: Array<CNToken>){
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
		if let val = getReservedWord() {
			return (val == rid)
		} else {
			return false
		}
	}

	public func getSymbol() -> Character? {
		if let token = mStream.get() {
			return token.getSymbol()
		} else {
			return nil
		}
	}

	public func requireSymbol(symbol sym: Character) -> Bool {
		if let val = getSymbol() {
			return (val == sym)
		} else {
			return false
		}
	}

	public func getIdentifier() -> String? {
		if let token = mStream.get() {
			return token.getIdentifier()
		} else {
			return nil
		}
	}

	public func requireIdentifier(identifier ident: String) -> Bool {
		if let val = getIdentifier() {
			return (val == ident)
		} else {
			return false
		}
	}

	public func getBool() -> Bool? {
		if let token = mStream.get() {
			return token.getBool()
		} else {
			return nil
		}
	}

	public func requireBool(value src: Bool) -> Bool {
		if let val = getBool() {
			return (val == src)
		} else {
			return false
		}
	}

	public func getInt() -> Int? {
		if let token = mStream.get() {
			return token.getInt()
		} else {
			return nil
		}
	}

	public func requireInt(value src: Int) -> Bool {
		if let val = getInt() {
			return (val == src)
		} else {
			return false
		}
	}

	public func getUInt() -> UInt? {
		if let token = mStream.get() {
			return token.getUInt()
		} else {
			return nil
		}
	}

	public func requireUInt(value src: UInt) -> Bool {
		if let val = getUInt() {
			return (val == src)
		} else {
			return false
		}
	}

	public func getDouble() -> Double? {
		if let token = mStream.get() {
			return token.getDouble()
		} else {
			return nil
		}
	}

	public func requireDouble(value src: Double) -> Bool {
		if let val = getDouble() {
			return (val == src)
		} else {
			return false
		}
	}

	public func getString() -> String? {
		if let token = mStream.get() {
			return token.getString()
		} else {
			return nil
		}
	}

	public func requireString(value src: String) -> Bool {
		if let val = getString() {
			return (val == src)
		} else {
			return false
		}
	}

	public func getText() -> String? {
		if let token = mStream.get() {
			return token.getText()
		} else {
			return nil
		}
	}

	public func requireText(value src: String) -> Bool {
		if let val = getText() {
			return (val == src)
		} else {
			return false
		}
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


