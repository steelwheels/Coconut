//
//  ViewController.swift
//  UnitTest
//
//  Created by Tomoo Hamada on 2021/05/07.
//

import CoconutData
import CoconutDatabase
import Cocoa

class ViewController: NSViewController
{
	private var mAddressBook:	CNAddressBook = CNAddressBook()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		mAddressBook.checkAccessibility(callback: {
			(_ result: CNAddressBook.AutorizedStatus) -> Void in
			switch result {
			case .authorized:
				NSLog("AddressBook ... authorized")
			case .denied:
				NSLog("AddressBook ... denied")
			}
		})

		switch mAddressBook.readContent() {
		case .table(let table):
			let txt = table.toText().toStrings().joined(separator: "\n")
			NSLog("table = \(txt)")
		case .error(let err):
			NSLog("error = \(err.description)")
		}

	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

