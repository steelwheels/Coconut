/**
 * @file	CNKeyCode.swift
 * @brief	Define CNKeyCode type
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation


/**
 * reference: https://qiita.com/baba163/items/e2390c4529ec0448151d
 * reference: https://stackoverflow.com/questions/3202629/where-can-i-find-a-list-of-mac-virtual-key-codes
 */
public enum CNKeyCode: UInt16
{
	case a 				= 0x00
	case s				= 0x01
	case d 				= 0x02
	case f 				= 0x03
	case h				= 0x04
	case g 				= 0x05
	case z 				= 0x06
	case x 				= 0x07
	case c 				= 0x08
	case v				= 0x09
	case b 				= 0x0b
	case q 				= 0x0c
	case w 				= 0x0d
	case e 				= 0x0e
	case r 				= 0x0f
	case y 				= 0x10
	case t 				= 0x11
	case _1				= 0x12
	case _2				= 0x13
	case _3				= 0x14
	case _4				= 0x15
	case _6				= 0x16
	case _5				= 0x17
	case equal 			= 0x18
	case _9				= 0x19
	case _7				= 0x1a
	case minus 			= 0x1b
	case _8				= 0x1c
	case _0				= 0x1d
	case rightBracket		= 0x1e
	case o 				= 0x1f
	case u 				= 0x20
	case leftBracket 		= 0x21
	case i 				= 0x22
	case p 				= 0x23
	case returnKey			= 0x24
	case l 				= 0x25
	case j 				= 0x26
	case quote 			= 0x27
	case k 				= 0x28
	case semicolon			= 0x29
	case backslash			= 0x2a
	case comma 			= 0x2b
	case slash 			= 0x2c
	case n 				= 0x2d
	case m 				= 0x2e
	case period 			= 0x2f
	case tab 			= 0x30
	case space			= 0x31
	case grave 			= 0x32
	case delete 			= 0x33
	case escape 			= 0x35
	case leftCommand		= 0x37
	case leftShift			= 0x38
	case capsLock			= 0x39
	case leftOption			= 0x3a
	case leftControl		= 0x3b
	case rightShift 		= 0x3c
	case rightOption		= 0x3d
	case rightControl		= 0x3e
	case function			= 0x3f
	case F17 			= 0x40
	case keypadDecimal		= 0x41
	case keypadMultiply		= 0x43
	case keypadPlus			= 0x45
	case keypadClear		= 0x47
	case volumeUp 			= 0x48
	case volumeDown			= 0x49
	case mute 			= 0x4a
	case keypadDivide		= 0x4b
	case keypadEnter		= 0x4c
	case keypadMinus		= 0x4e
	case F18 			= 0x4f
	case F19 			= 0x50
	case keypadEqual		= 0x51
	case keypad0 			= 0x52
	case keypad1 			= 0x53
	case keypad2 			= 0x54
	case keypad3 			= 0x55
	case keypad4 			= 0x56
	case keypad5 			= 0x57
	case keypad6 			= 0x58
	case keypad7 			= 0x59
	case F20			= 0x5a
	case keypad8 			= 0x5b
	case keypad9 			= 0x5c
	case F5				= 0x60
	case F6 			= 0x61
	case F7				= 0x62
	case F3				= 0x63
	case F8				= 0x64
	case F9				= 0x65
	case F11			= 0x67
	case F13			= 0x69
	case F16			= 0x6a
	case F14			= 0x6b
	case F10			= 0x6d
	case F12			= 0x6f
	case F15 			= 0x71
	case help			= 0x72
	case home			= 0x73
	case pageUp			= 0x74
	case forwardDelete		= 0x75
	case F4 			= 0x76
	case end 			= 0x77
	case F2 			= 0x78
	case pageDown			= 0x79
	case F1 			= 0x7a
	case leftArrow 			= 0x7b
	case rightArrow 		= 0x7c
	case downArrow			= 0x7d
	case upArrow 			= 0x7e
}

public enum CNSpecialKey
{
	case shift
	case control
	case command
	case option
	case capsLock
	case delete
	case forwardDelete
	case escape
	case leftArrow
	case rightArrow
	case upArrow
	case downArrow
	case home
	case end
	case pageUp
	case pageDown
	case clear
	case fn
	case decimal
	case volumeUp
	case volumeDown
	case mute
	case help
}

public enum CNKeyCategory
{
	case space(Character)
	case digit(Int)
	case alphabet(Character)
	case symbol(Character)
	case function(Int)
	case special(CNSpecialKey)

	public static func category(from code: CNKeyCode) -> CNKeyCategory {
		let result: CNKeyCategory
		switch code {
		case .a:		result = .alphabet("a")
		case .s:		result = .alphabet("s")
		case .d:		result = .alphabet("d")
		case .f:		result = .alphabet("f")
		case .h:		result = .alphabet("h")
		case .g:		result = .alphabet("g")
		case .z:		result = .alphabet("z")
		case .x:		result = .alphabet("x")
		case .c:		result = .alphabet("c")
		case .v:		result = .alphabet("v")
		case .b:		result = .alphabet("b")
		case .q:		result = .alphabet("q")
		case .w:		result = .alphabet("w")
		case .e:		result = .alphabet("e")
		case .r:		result = .alphabet("r")
		case .y:		result = .alphabet("y")
		case .t:		result = .alphabet("t")
		case ._1:		result = .digit(1)
		case ._2:		result = .digit(2)
		case ._3:		result = .digit(3)
		case ._4: 		result = .digit(4)
		case ._6:		result = .digit(6)
		case ._5:		result = .digit(5)
		case .equal:		result = .symbol("=")
		case ._9:		result = .digit(9)
		case ._7:		result = .digit(7)
		case .minus:		result = .symbol("-")
		case ._8:		result = .digit(8)
		case ._0:		result = .digit(0)
		case .rightBracket:	result = .symbol("]")
		case .o:		result = .alphabet("o")
		case .u:		result = .alphabet("u")
		case .leftBracket:	result = .symbol("[")
		case .i:		result = .alphabet("i")
		case .p:		result = .alphabet("p")
		case .returnKey:	result = .space("\n")
		case .l:		result = .alphabet("l")
		case .j:		result = .alphabet("j")
		case .quote:		result = .symbol("'")
		case .k:		result = .alphabet("k")
		case .semicolon:	result = .symbol(";")
		case .backslash:	result = .symbol("\\")
		case .comma:		result = .symbol(",")
		case .slash:		result = .symbol("/")
		case .n:		result = .alphabet("n")
		case .m:		result = .alphabet("m")
		case .period:		result = .symbol(".")
		case .tab:		result = .space("\t")
		case .space: 		result = .space(" ")
		case .grave: 		result = .symbol("^")
		case .delete: 		result = .special(.delete)
		case .escape: 		result = .special(.escape)
		case .leftCommand: 	result = .special(.command)
		case .leftShift: 	result = .special(.shift)
		case .capsLock: 	result = .special(.capsLock)
		case .leftOption: 	result = .special(.option)
		case .leftControl: 	result = .special(.control)
		case .rightShift: 	result = .special(.shift)
		case .rightOption: 	result = .special(.option)
		case .rightControl: 	result = .special(.control)
		case .function: 	result = .special(.fn)
		case .F17: 		result = .function(17)
		case .keypadDecimal:	result = .special(.decimal)
		case .keypadMultiply:	result = .symbol("*")
		case .keypadPlus:	result = .symbol("+")
		case .keypadClear:	result = .special(.clear)
		case .volumeUp:		result = .special(.volumeUp)
		case .volumeDown:	result = .special(.volumeDown)
		case .mute:		result = .special(.mute)
		case .keypadDivide:	result = .symbol("/")
		case .keypadEnter:	result = .space("\r")
		case .keypadMinus:	result = .symbol("-")
		case .F18:		result = .function(18)
		case .F19:		result = .function(19)
		case .keypadEqual:	result = .symbol("=")
		case .keypad0:		result = .digit(0)
		case .keypad1:		result = .digit(1)
		case .keypad2:		result = .digit(2)
		case .keypad3:		result = .digit(3)
		case .keypad4:		result = .digit(4)
		case .keypad5:		result = .digit(5)
		case .keypad6:		result = .digit(6)
		case .keypad7:		result = .digit(7)
		case .F20:		result = .function(20)
		case .keypad8:		result = .digit(8)
		case .keypad9:		result = .digit(9)
		case .F5:		result = .function(5)
		case .F6:		result = .function(6)
		case .F7:		result = .function(7)
		case .F3:		result = .function(3)
		case .F8:		result = .function(8)
		case .F9:		result = .function(9)
		case .F11:		result = .function(11)
		case .F13:		result = .function(13)
		case .F16:		result = .function(16)
		case .F14:		result = .function(14)
		case .F10:		result = .function(10)
		case .F12:		result = .function(12)
		case .F15:		result = .function(15)
		case .help:		result = .special(.help)
		case .home:		result = .special(.home)
		case .pageUp:		result = .special(.pageUp)
		case .forwardDelete:	result = .special(.forwardDelete)
		case .F4:		result = .function(4)
		case .end:		result = .special(.end)
		case .F2:		result = .function(2)
		case .pageDown:		result = .special(.pageDown)
		case .F1:		result = .function(1)
		case .leftArrow:	result = .special(.leftArrow)
		case .rightArrow:	result = .special(.rightArrow)
		case .downArrow:	result = .special(.downArrow)
		case .upArrow:		result = .special(.upArrow)
		}
		return result
	}
}


