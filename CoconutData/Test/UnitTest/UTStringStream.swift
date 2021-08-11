/**
 * @file	UTStringStream.swift
 * @brief	Test function for CNStringStream
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testStringStream(console cons: CNConsole) -> Bool
{
	cons.print(string: "- Test string stream to token\n")
	let res0 = testStringStreamToToken(console: cons)

	cons.print(string: "- Test string stream to decode\n")
	let res1 = testStringStreamToDecode(console: cons)

	let result = res0 && res1
	if result {
		cons.print(string: "testStringStream .. OK\n")
	} else {
		cons.print(string: "testStringStream .. NG\n")
	}
	return result
}

private func testStringStreamToToken(console cons: CNConsole) -> Bool
{
	let teststr = " (ab, c1, da_) : e01 > hoge fuga"
	let stream  = CNStringStream(string: teststr)
	cons.print(string: "[INIT] " + stream.description + "\n")

	/* Split by ">" */
	guard let (streama, streamb) = stream.splitByFirstCharacter(characters: [">"]) else {
		cons.print(string: "[Error] Failed to sprite\n")
		return false
	}

	cons.print(string: "[STREAM-A] " + streama.description + "\n")
	cons.print(string: "[STREAM-B] " + streamb.description + "\n")

	let config = CNParserConfig()
	let result: Bool
	switch CNStringStreamToToken(stream: streama, config: config) {
	case .ok(let tokens):
		dumpTokens(tokens: tokens, console: cons)
		result = true
	case .error(let err):
		cons.print(string: "[Error] " + err.toString() + "\n")
		result = false
	}
	return result
}

private func dumpTokens(tokens tkns: Array<CNToken>, console cons: CNConsole)
{
	cons.print(string: "<Tokens>\n")
	for token in tkns {
		let typestr = token.type.description()
		cons.print(string: typestr + "\n")
	}
}

private func testStringStreamToDecode(console cons: CNConsole) -> Bool
{
	var result  = true

	let teststr = " 1234a"
	let stream  = CNStringStream(string: teststr)

	stream.skipSpaces()
	if let val = stream.geti() {
		if val == 1234 {
			cons.print(string: "Decoded value: \(val) ... OK\n")
		} else {
			cons.print(string: "[Error] Unexpected decoded value: \(val)\n")
			result = false
		}
	} else {
		cons.print(string: "[Error] No integer value\n")
		result = false
	}
	if let remain = stream.toString() {
		if remain == "a" {
			cons.print(string: "Remained: \(remain) .. OK\n")
		} else {
			cons.print(string: "[Error] Unexpected: \(remain)")
			result = false
		}
	} else {
		cons.print(string: "[Error] Follower string\n")
		result = false
	}
	return result
}
