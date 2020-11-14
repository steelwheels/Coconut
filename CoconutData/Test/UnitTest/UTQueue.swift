/**
 * @file	UTQueue.swift
 * @brief	Test function for CNQueue class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testQueue(console cons: CNConsole) -> Bool
{
	var result = true

	let queue = CNQueue<Int>()
	printQueue(message: "Initial", queue: queue, console: cons)

	push(queue: queue, data: 0)
	push(queue: queue, data: 1)

	if !pop(queue: queue) {
		result = false
	}

	if !pop(queue: queue) {
		result = false
	}

	if pop(queue: queue) {
		result = false
	}

	for i in 0..<8 {
		let UNIT_NUM = 16

		/* Push */
		for j in 0..<UNIT_NUM {
			queue.push(i*UNIT_NUM + j)
		}
		printQueue(message: "Push x \(UNIT_NUM)", queue: queue, console: cons)

		/* Pop */
		for j in 0..<UNIT_NUM {
			if let data = queue.pop() {
				let expval = i*UNIT_NUM + j
				if data != expval {
					cons.print(string: "[Error] Not matched \(data) != \(expval)\n")
				}
			} else {
				cons.error(string: "[Error] Queue under flow")
				result = false
			}
		}
		printQueue(message: "Pop x \(UNIT_NUM)", queue: queue, console: cons)

		if let _ = queue.pop() {
			cons.error(string: "[Error] Queue is not empty")
			result = false
		}
		printQueue(message: "Pop 1 more ", queue: queue, console: cons)
	}

	if result {
		cons.print(string: "testQueue .. OK\n")
	} else {
		cons.print(string: "testQueue .. NG\n")
	}

	return result
}

private func push(queue que: CNQueue<Int>, data dt: Int)
{
	que.push(dt)
	printQueue(message: "Push", queue: que, console: cons)
}

private func pop(queue que: CNQueue<Int>) -> Bool {
	let result: Bool
	if let data = que.pop() {
		printQueue(message: "Pop", queue: que, console: cons)
		cons.print(string: " Data = \(data)\n")
		result = true
	} else {
		printQueue(message: "Pop", queue: que, console: cons)
		cons.print(string: " Data = nil\n")
		result = false
	}
	return result
}

private func printQueue(message msg: String, queue que: CNQueue<Int>, console cons: CNConsole)
{
	cons.print(string: "\(msg): ")
	que.dumpState(console: cons)
}
