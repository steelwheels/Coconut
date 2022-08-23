/**
 * @file	CNAlert.swift
 * @brief	Define CNAlert class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

/* Common implementation of NSAlert.Style */
public enum CNAlertType: Int {
	case	informational	= 1
	case 	warning		= 2
	case	critical	= 3
}

