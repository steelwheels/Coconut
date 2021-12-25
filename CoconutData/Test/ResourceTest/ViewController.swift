//
//  ViewController.swift
//  ResourceTest
//
//  Created by Tomoo Hamada on 2021/12/25.
//

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
		let res0 = UTValueCache()
		if res0 {
			NSLog("Summary: OK")
		} else {
			NSLog("Summary: Error")
		}
	}

}

