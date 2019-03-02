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

				/* Select output file */
				URL.savePanel(title: "Select JSON output", outputDirectory: nil, saveFileCallback: {
					(_  url:URL) -> Bool in
					if let err = CNJSONFile.writeFile(URL: url, JSONObject: value) {
						CNLog(type: .Error, message: "Output selection: \(err.description)", file: #file, line: #line, function: #function)
						return false
					} else {
						return true
					}
				})
			} else {
				CNLog(type: .Error, message: "Failed to read json file: \(err!.description)", file: #file, line: #line, function: #function)
			}
		} else {
			CNLog(type: .Error, message: "Failed to load manifest.json", file: #file, line: #line, function: #function)
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

