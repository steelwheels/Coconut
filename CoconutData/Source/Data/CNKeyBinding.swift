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
public enum CNKeyBinding
{
	public enum LeaveMode {
		case Leave
		case DoNotLeave
	}

	public enum DeleteUnit {
		case character
		case word
		case paragraph
	}

	public enum CursorDirection {
		case left
		case right
		case up
		case down
	}

	public enum ScrollDirection {
		case up
		case down
	}

	public enum ScrollUnit {
		case page
		case document
	}

	public enum DocumentDirection {
		case forward
		case backward
	}

	public enum DocumentUnit {
		case word
		case line
		case paragraph
		case document
	}

	case insertNewline(LeaveMode)		// true: Leave form box, false: dont leave
	case insertTab(LeaveMode)		// true: Leave form box, false: dont leave
	case insertBackTab
	case cycleToNextInputScript
	case togglePlatformInputSystem
	case cycleToNextInputKeyboardLayout
	case deleteBackward(DeleteUnit)
	case deleteForward(DeleteUnit)
	case cancel
	case moveCursor(CursorDirection)
	case moveTo(DocumentDirection, DocumentUnit)
	case scroll(ScrollDirection, ScrollUnit)

	public static func decode(selectorName name: String) -> CNKeyBinding? {
		let result: CNKeyBinding?
		switch name {
		case "insertNewline:":
			result = .insertNewline(.DoNotLeave)
		case "insertNewlineIgnoringFieldEditor:":
			result = .insertNewline(.DoNotLeave)
		case "insertTab:":
			result = .insertTab(.DoNotLeave)
		case "insertTabIgnoringFieldEditor:":
			result = .insertTab(.DoNotLeave)
		case "insertBacktab:":
			result = .insertBackTab
		case "cycleToNextInputScript:":
			result = .cycleToNextInputScript
		case "togglePlatformInputSystem:":
			result = .togglePlatformInputSystem
		case "cycleToNextInputKeyboardLayout:":
			result = .cycleToNextInputKeyboardLayout
		case "deleteBackward:":
			result = .deleteBackward(.character)
		case "deleteWordBackward:":
			result = .deleteBackward(.word)
		case "deleteForward:":
			result = .deleteForward(.character)
		case "deleteWordForward:":
			result = .deleteForward(.word)
		case "cancelOperation:":
			result = .cancel
		case "complete:":
			result = nil	// Not supported
		case "moveUp:", "moveUpAndModifySelection:":
			result = .moveCursor(.up)
		case "scrollPageUp:":
			result = .scroll(.up, .page)
		case "moveToBeginningOfDocument:", "moveToBeginningOfDocumentAndModifySelection:":
			result = .moveTo(.backward, .document)
		case "moveToBeginningOfParagraph:", "moveParagraphBackwardAndModifySelection:":
			result = .moveTo(.backward, .paragraph)
		case "moveDown:", "moveDownAndModifySelection:":
			result = .moveCursor(.down)
		case "scrollPageDown:":
			result = .scroll(.down, .page)
		case "moveToEndOfDocument:" ,"moveToEndOfDocumentAndModifySelection:":
			result = .moveTo(.forward, .document)
		case "moveToEndOfParagraph:":
			result = .moveTo(.forward, .paragraph)
		case "moveParagraphForwardAndModifySelection:":
			result = .moveTo(.forward, .paragraph)
		case "moveLeft:", "moveLeftAndModifySelection:":
			result = .moveCursor(.left)
		case "moveToBeginningOfLine:", "moveToBeginningOfLineAndModifySelection:":
			result = .moveTo(.backward, .line)
		case "changeBaseWritingDirectionToRTL:", "changeBaseWritingDirectionToLTR:":
			result = nil	// Not supported
		case "moveWordLeft:", "moveWordLeftAndModifySelection:":
			result = .moveTo(.backward, .word)
		case "moveRight:", "moveRightAndModifySelection:":
			result = .moveCursor(.right)
		case "moveToEndOfLine:", "moveToEndOfLineAndModifySelection:":
			result = .moveTo(.forward, .line)
		case "moveWordRight:", "moveWordRightAndModifySelection:":
			result = .moveTo(.forward, .word)
		case "scrollToBeginningOfDocument:":
			result = .scroll(.up, .document)
		case "scrollToEndOfDocument:":
			result = .scroll(.down, .document)
		case "pageUp:", "pageUpAndModifySelection:":
			result = .scroll(.up, .page)
		case "pageDown:", "pageDownAndModifySelection:":
			result = .scroll(.down, .page)
		case "moveBackward:":
			result = .moveCursor(.left)
		case "moveForward:":
			result = .moveCursor(.right)
		case "deleteToEndOfParagraph:":
			result = .deleteForward(.paragraph)
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
		case .deleteBackward(let unit):
			switch unit {
			case .character:
				result = [.delete]
			case .paragraph, .word:
				result = nil 		// Not supported
			}
		case .deleteForward(let unit):
			switch unit {
			case .character:
				result = [.cursorForward(1), .delete]
			case .paragraph, .word:
				result = nil		// Not supported
			}
		case .cancel:
			result = [.string("\(ESC)")]
		case .moveCursor(let dir):
			switch dir {
			case .up:	result = [.cursorUp(1)]
			case .down:	result = [.cursorDown(1)]
			case .left:	result = [.cursorBackward(1)]
			case .right:	result = [.cursorForward(1)]
			}
		case .moveTo(_, _):
			result = nil			// Not supported
		case .scroll(_, _):
			result = nil			// Not supported

		}
		return result
	}
}
