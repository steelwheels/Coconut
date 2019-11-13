/**
 * @file	CNKeyBinding.swift
 * @brief	Define CNKeyBinding class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

private let ESC:	Character		= "\u{1b}"	// ESC

/*
 * reference: https://www.hcs.harvard.edu/~jrus/site/system-bindings.html
 */
public enum CNKeyBinding {
	case insertNewline(Bool)		// true: Leave form box, false: dont leave
	case insertTab(Bool)			// true: Leave form box, false: dont leave
	case insertBackTab
	case cycleToNextInputScript
	case togglePlatformInputSystem
	case cycleToNextInputKeyboardLayout
	case deleteBackward(Int)		// 0: One character, 1: One word, 2: One paragraph
	case deleteForward(Int)			// 0: One character, 1: One word, 2: One paragraph
	case cancel
	case moveUp(Int)			// 0: One line, 1: Paragraph, 2: Document
	case moveDown(Int)			// 0: One line, 1: Paragraph, 2: Document
	case moveLeft(Int)			// 0: One char, 1: Word, 2: Line
	case moveRight(Int)			// 0: One char, 1: Word, 2: Line
	case scrollUp				// page up
	case scrollDown				// page down

	public static func decode(selectorName name: String) -> CNKeyBinding? {
		let result: CNKeyBinding?
		switch name {
		case "insertNewline:":
			result = .insertNewline(true)
		case "insertNewlineIgnoringFieldEditor:":
			result = .insertNewline(false)
		case "insertTab:":
			result = .insertTab(true)
		case "insertTabIgnoringFieldEditor:":
			result = .insertTab(false)
		case "insertBacktab:":
			result = .insertBackTab
		case "cycleToNextInputScript:":
			result = .cycleToNextInputScript
		case "togglePlatformInputSystem:":
			result = .togglePlatformInputSystem
		case "cycleToNextInputKeyboardLayout:":
			result = .cycleToNextInputKeyboardLayout
		case "deleteBackward:":
			result = .deleteBackward(0)
		case "deleteWordBackward:":
			result = .deleteBackward(1)
		case "deleteForward:":
			result = .deleteForward(0)
		case "deleteWordForward:":
			result = .deleteForward(1)
		case "cancelOperation:":
			result = .cancel
		case "complete:":
			result = nil	// Not supported
		case "moveUp:", "moveUpAndModifySelection:":
			result = .moveUp(0)
		case "scrollPageUp:":
			result = .scrollUp
		case "moveToBeginningOfDocument:", "moveToBeginningOfDocumentAndModifySelection:":
			result = .moveUp(2)
		case "moveToBeginningOfParagraph:", "moveParagraphBackwardAndModifySelection:":
			result = .moveUp(1)
		case "moveDown:", "moveDownAndModifySelection:":
			result = .moveDown(0)
		case "scrollPageDown:":
			result = .scrollDown
		case "moveToEndOfDocument:" ,"moveToEndOfDocumentAndModifySelection:":
			result = .moveDown(2)
		case "moveToEndOfParagraph:":
			result = .moveDown(1)
		case "moveParagraphForwardAndModifySelection:":
			result = .moveUp(1)
		case "moveLeft:", "moveLeftAndModifySelection:":
			result = .moveLeft(0)
		case "moveToBeginningOfLine:", "moveToBeginningOfLineAndModifySelection:":
			result = .moveLeft(2)
		case "changeBaseWritingDirectionToRTL:", "changeBaseWritingDirectionToLTR:":
			result = nil	// Not supported
		case "moveWordLeft:", "moveWordLeftAndModifySelection:":
			result = .moveLeft(1)
		case "moveRight:", "moveRightAndModifySelection:":
			result = .moveRight(0)
		case "moveToEndOfLine:", "moveToEndOfLineAndModifySelection:":
			result = .moveRight(2)
		case "moveWordRight:", "moveWordRightAndModifySelection:":
			result = .moveRight(1)
		case "scrollToBeginningOfDocument:":
			result = .moveUp(2)
		case "scrollToEndOfDocument:":
			result = .moveDown(2)
		case "pageUp:", "pageUpAndModifySelection:":
			result = .scrollUp
		case "pageDown:", "pageDownAndModifySelection:":
			result = .scrollDown
		case "moveBackward:":
			result = .moveLeft(0)
		case "moveForward:":
			result = .moveRight(0)
		case "deleteToEndOfParagraph:":
			result = .deleteForward(2)
		case "centerSelectionInVisibleArea:":
			result = nil 	// Not supported
		case "transpose:":
			result = nil 	// Not supported
		case "yank:":
			result = nil 	// Not supported
		default:
			result = nil
		}
		return result
	}

	public func toEscapeCode() -> [CNEscapeCode]? {
		var result: [CNEscapeCode]? = nil
		switch self {
		case .insertNewline(_):
			result = [.newline]
		case .insertTab(_):
			result = [.tab]
		case .insertBackTab:
			result = nil // Not supported
		case .cycleToNextInputScript:
			result = nil // Not supported
		case .togglePlatformInputSystem:
			result = nil // Not supported
		case .cycleToNextInputKeyboardLayout:
			result = nil // Not supported
		case .deleteBackward(let n):
			if n == 0 {
				result = [.delete]
			}
		case .deleteForward(let n):
			if n == 0 {
				result = [.cursorForward(1), .delete]
			}
		case .cancel:
			result = [.string("\(ESC)")]
		case .moveUp(let n):
			if n == 0 {
				result = [.cursorUp(1)]
			}
		case .moveDown(let n):
			if n == 0 {
				result = [.cursorDown(1)]
			}
		case .moveLeft(let n):
			if n == 0 {
				result = [.cursorBack(1)]
			}
		case .moveRight(let n):
			if n == 0 {
				result = [.cursorForward(1)]
			}
		case .scrollUp:
			result = [.scrollUp]
		case .scrollDown:
			result = [.scrollDown]
		}
		return result
	}
}
