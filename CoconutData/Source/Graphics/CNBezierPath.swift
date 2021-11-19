/**
 * @file	CNBezierPath.swift
 * @brief	Extend BezierPath class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import Foundation

#if os(OSX)
public typealias CNBezierPath = NSBezierPath
#else
public typealias CNBezierPath = UIBezierPath
#endif

public extension CNBezierPath
{
	#if os(OSX)
	func addLine(to pt: CGPoint) {
		self.line(to: pt)
	}
	#else
	func appendRect(_ rt: CGRect){
		let x0 = rt.origin.x
		let y0 = rt.origin.y
		let x1 = x0 + rt.size.width
		let y1 = y0 + rt.size.height
		self.move(to: CGPoint(x: x0, y: y0))
		self.addLine(to: CGPoint(x: x1, y: y0))
		self.addLine(to: CGPoint(x: x1, y: y1))
		self.addLine(to: CGPoint(x: x0, y: y1))
		self.addLine(to: CGPoint(x: x0, y: y0))
	}

	func appendRoundedRect(_ rt: CGRect, xRadius xrad: CGFloat, yRadius yrad: CGFloat){
		self.appendRect(rt)
	}

	func appendOval(center c: CGPoint, radius r: CGFloat) {
		self.addArc(withCenter: c, radius: r, startAngle: 0.0, endAngle: CGFloat.pi * 2.0, clockwise: true)
	}
	#endif
}

