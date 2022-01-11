//
//  ViewController.swift
//  ResourceTest
//
//  Created by Tomoo Hamada on 2021/12/25.
//

import CoconutData
import Cocoa

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	override func viewDidAppear() {
		super.viewDidAppear()
		let res0 = UTMutableValue()
		let res1 = UTValueStorage()
		let res2 = UTValueTable()
		if res0 && res1 && res2 {
			NSLog("Summary: OK")
		} else {
			NSLog("Summary: Error")
		}
	}

}

