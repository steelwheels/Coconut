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
						console.error(string: "[Error] Output selection: \(err.description)")
						return false
					} else {
						return true
					}
				})
			} else {
				console.error(string: "Failed to read json file: \(err!.description)")
			}
		} else {
			console.error(string: "Failed to load manifest.json")
		}

		// Connection test
		testConnection(console: console)
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	private func printValue(value val: CNNativeValue, console cons: CNConsole){
		val.toText().print(console: cons)
	}

	private func testConnection(console cons: CNConsole)
	{
		var printed: Bool = false

		let connector = CNConnection()
		connector.receiverFunction = {
			(_ str: String) -> Void in
			cons.print(string: "Receive: \(str)\n")
			printed = true
		}

		connector.send(string: "Hello, connector !!")
		//connector.finish()

		while !printed {
			/* wait */
		}
	}
}
