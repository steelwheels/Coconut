/**
 * @file	UTKeyBinding.swift
 * @brief	Test function for CNKeyBinding
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testKeyBinding(console cons: CNConsole) -> Bool
{
	printKeyBinding(selectorName:"insertNewline:", console: cons)
	printKeyBinding(selectorName:"insertNewlineIgnoringFieldEditor:", console: cons)
	printKeyBinding(selectorName:"insertTab:", console: cons)
	printKeyBinding(selectorName:"insertTabIgnoringFieldEditor:", console: cons)
	printKeyBinding(selectorName:"insertBacktab:", console: cons)
	printKeyBinding(selectorName:"cycleToNextInputScript:", console: cons)
	printKeyBinding(selectorName:"togglePlatformInputSystem:", console: cons)
	printKeyBinding(selectorName:"cycleToNextInputKeyboardLayout:", console: cons)
	printKeyBinding(selectorName:"deleteBackward:", console: cons)
	printKeyBinding(selectorName:"deleteWordBackward:", console: cons)
	printKeyBinding(selectorName:"deleteForward:", console: cons)
	printKeyBinding(selectorName:"deleteWordForward:", console: cons)
	printKeyBinding(selectorName:"cancelOperation:", console: cons)
	printKeyBinding(selectorName:"complete:", console: cons)
	printKeyBinding(selectorName:"moveUp:", console: cons)
	printKeyBinding(selectorName:"moveUpAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"scrollPageUp:", console: cons)
	printKeyBinding(selectorName:"moveToBeginningOfDocument:", console: cons)
	printKeyBinding(selectorName:"moveToBeginningOfDocumentAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"moveToBeginningOfParagraph:", console: cons)
	printKeyBinding(selectorName:"moveParagraphBackwardAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"moveDown:", console: cons)
	printKeyBinding(selectorName:"moveDownAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"scrollPageDown:", console: cons)
	printKeyBinding(selectorName:"moveToEndOfDocument:", console: cons)
	printKeyBinding(selectorName:"moveToEndOfDocumentAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"moveToEndOfParagraph:", console: cons)
	printKeyBinding(selectorName:"moveParagraphForwardAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"moveLeft:", console: cons)
	printKeyBinding(selectorName:"moveLeftAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"moveToBeginningOfLine:", console: cons)
	printKeyBinding(selectorName:"moveToBeginningOfLineAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"changeBaseWritingDirectionToRTL:", console: cons)
	printKeyBinding(selectorName:"changeBaseWritingDirectionToLTR:", console: cons)
	printKeyBinding(selectorName:"moveWordLeft:", console: cons)
	printKeyBinding(selectorName:"moveWordLeftAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"moveRight:", console: cons)
	printKeyBinding(selectorName:"moveRightAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"moveToEndOfLine:", console: cons)
	printKeyBinding(selectorName:"moveToEndOfLineAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"moveWordRight:", console: cons)
	printKeyBinding(selectorName:"moveWordRightAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"scrollToBeginningOfDocument:", console: cons)
	printKeyBinding(selectorName:"scrollToEndOfDocument:", console: cons)
	printKeyBinding(selectorName:"pageUp:", console: cons)
	printKeyBinding(selectorName:"pageUpAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"pageDown:", console: cons)
	printKeyBinding(selectorName:"pageDownAndModifySelection:", console: cons)
	printKeyBinding(selectorName:"moveBackward:", console: cons)
	printKeyBinding(selectorName:"moveForward:", console: cons)
	printKeyBinding(selectorName:"deleteToEndOfParagraph:", console: cons)
	printKeyBinding(selectorName:"centerSelectionInVisibleArea:", console: cons)
	printKeyBinding(selectorName:"transpose:", console: cons)
	printKeyBinding(selectorName:"yank:", console: cons)
	return true
}

private func printKeyBinding(selectorName name: String, console cons: CNConsole)
{
	if let kb = CNKeyBinding.decode(selectorName: name) {
		cons.print(string: "selectorName:\(name) -> ")
		if let ecodes = kb.toEscapeCode() {
			cons.print(string: "[")
			for ecode in ecodes {
				cons.print(string: "\(ecode.description()) ")
			}
			cons.print(string: "]\n")
		} else {
			cons.print(string: "[Error] Failed to convert to escape code\n")
		}
	} else {
		cons.print(string: "[Error] Failed to decode keybinding: \(name)\n")
	}
}
