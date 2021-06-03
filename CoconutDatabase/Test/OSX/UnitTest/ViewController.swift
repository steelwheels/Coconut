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

		let adbook = CNAddressBook()
		adbook.checkAccessibility(callback: {
			(_ result: CNAddressBook.AutorizedStatus) -> Void in
			switch result {
			case .authorized:
				NSLog("AddressBook ... authorized")
			case .denied(let err):
				NSLog("AddressBook ... denied: \(err.description)")
			}
		})
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

