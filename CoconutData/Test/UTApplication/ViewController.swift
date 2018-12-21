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
		let console = CNFileConsole()
		
		//let _ = URL.openPanel(title: "UTApplication", selection: .SelectFile, fileTypes: ["txt"])
		if let url = CNFilePath.URLForResourceFile(fileName: "manifest", fileExtension: "json") {
			Swift.print("URL: \(url.description)")
			let (valuep, err) = CNJSONFile.readFile(URL: url)
			if let value = valuep {
				console.print(string: "** JSON file ***\n")
				printValue(value: value, console: console)
			} else {
				NSLog("Failed to read json file]: \(err!.description)")
			}
		} else {
			NSLog("Failed to load manifest.json")
		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	private func printValue(value val: CNNativeValue, console cons: CNConsole){
		val.toText().print(console: cons)
	}
}

