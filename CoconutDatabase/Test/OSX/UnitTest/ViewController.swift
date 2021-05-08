//
//  ViewController.swift
//  UnitTest
//
//  Created by Tomoo Hamada on 2021/05/07.
//

import CoconutData
import CoconutDatabase
import Cocoa

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		CNExecuteInUserThread(level: .thread, execute: {
			() -> Void in
			let adbook = CNAddressBook()
			adbook.read(callback: {
				(_ status : CNAddressBook.ReadResult) -> Void in
				switch status {
				case .table(let table):
					NSLog("Table: \(table.records.count)")
				case .error(let err):
					NSLog("[Error] \(err.toString())")
				}
			})

/*
			adbook.startAuthorization()
			while adbook.status == .notDetermined {
				/* wait */
			}
			switch adbook.status {

			}*/
			/*
			switch adbook.read() {
			case .table(let table):
				NSLog("read ... done: \(table.records.count)")
			case .error(let err):
				NSLog("read ... failed: \(err.toString())")
			}*/
		})
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

