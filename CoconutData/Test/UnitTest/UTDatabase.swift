/**
 * @file		UTDatabase.swift
 * @brief	Test function for CNDatabase
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testDatabase(console cons: CNConsole) -> Bool
{
	let result0 = testMainDatabase(console: cons)
	let result1 = testRemoteDatabase(console: cons)
	return result0 && result1
}

private func testMainDatabase(console cons: CNConsole) -> Bool
{
	/* Allocate and dump initial status */
	cons.print(string: "* Main database: Initial state\n")
	let db = CNMainDatabase()
	print(database: db, console: cons)

	cons.print(string: "* Main database: add some values\n")
	let _ = db.write(identifier: "ident0", value: .numberValue(NSNumber(booleanLiteral: true)))
	let _ = db.write(identifier: "ident1", value: .numberValue(NSNumber(floatLiteral: 1.23)))
	print(database: db, console: cons)

	cons.print(string: "* Main database: after commit\n")
	db.commit()
	print(database: db, console: cons)

	readdb(database: db, identitifer: "ident0", console: cons)
	readdb(database: db, identitifer: "ident1", console: cons)
	readdb(database: db, identitifer: "ident2", console: cons)

	return true
}

private func testRemoteDatabase(console cons: CNConsole) -> Bool
{
	let maindb = CNMainDatabase()
	let _ = maindb.write(identifier: "ident0", value: .numberValue(NSNumber(booleanLiteral: true)))
	let _ = maindb.write(identifier: "ident1", value: .numberValue(NSNumber(floatLiteral: 1.23)))
	maindb.commit()
	
	let remdb = CNRemoteDatabase()
	remdb.bind(mainDatabase: maindb)

	cons.print(string: "* Remote database: read\n")
	readdb(database: remdb, identitifer: "ident0", console: cons)
	readdb(database: remdb, identitifer: "ident1", console: cons)
	readdb(database: remdb, identitifer: "ident2", console: cons)
	print(database: remdb, console: cons)

	cons.print(string: "* Remote database: write\n")
	let _ = maindb.write(identifier: "ident0", value: .numberValue(NSNumber(booleanLiteral: false)))
	let _ = remdb.write(identifier: "ident2", value: .stringValue("Hello"))
	print(database: remdb, console: cons)

	cons.print(string: "* Remote database: commit\n")
	remdb.commit()
	readdb(database: remdb, identitifer: "ident0", console: cons)
	readdb(database: remdb, identitifer: "ident1", console: cons)
	readdb(database: remdb, identitifer: "ident2", console: cons)
	print(database: remdb, console: cons)
	
	return true
}

private func readdb(database db: CNDatabaseProtocol, identitifer ident: String, console cons: CNConsole) {
	cons.print(string: "read \"\(ident)\" -> ")
	if let val = db.read(identifier: ident) {
		let valtxt = val.toText()
		valtxt.print(console: cons)
	} else {
		cons.print(string: "nil\n")
	}
}

private func print(database db: CNDatabaseProtocol, console cons: CNConsole) {
	let text = db.toText()
	text.print(console: cons)
}
