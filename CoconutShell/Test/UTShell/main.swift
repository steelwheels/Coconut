//
//  main.swift
//  UTShell
//
//  Created by Tomoo Hamada on 2018/09/24.
//  Copyright © 2018年 Steel Wheels Project. All rights reserved.
//

import CoconutData
import CoconutShell
import Foundation

print("Hello, World!")

let file = CNFileConsole()
let process = CNShell.execute(command: "ls", console: file, terminateHandler: {
	(_ exitcode: Int32) -> Void in
	file.print(string: "*** /bin/ls ... done")
})
process.waitUntilExit()

print("Bye")

