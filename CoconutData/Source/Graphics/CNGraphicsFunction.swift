/*
 * @file	CNGraphicsFunction.swift
 * @brief	Define functions for graphics
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public class CNGraphics
{
	public static func distance(pointA pa: CGPoint, pointB pb: CGPoint) -> CGFloat {
		let dx = pb.x - pa.x
		let dy = pb.y - pa.y
		return sqrt(dx*dx + dy*dy)
	}
}

