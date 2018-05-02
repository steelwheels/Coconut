//
//  ViewController.swift
//  UTApplication
//
//  Created by Tomoo Hamada on 2018/05/02.
//  Copyright © 2018年 Steel Wheels Project. All rights reserved.
//

import CoconutData
import Cocoa

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func viewDidAppear() {
		let _ = URL.openPanel(title: "UTApplication", selection: .SelectFile, fileTypes: ["txt"])
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

