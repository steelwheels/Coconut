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
		cons.print(string: "[Error] " + err.description() + "\n")
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
