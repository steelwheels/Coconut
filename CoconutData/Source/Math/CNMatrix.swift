/**
 * @file	CNMatrix.swift
 * @brief	Define CNMatrix class and it's operation
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public struct CNVector3D : Comparable
{
	public var 	values: [CGFloat]

	public init() {
		values = [0.0, 0.0, 0.0]
	}

	public init(scalars scls: [CGFloat]) {
		values = [scls[0], scls[1], scls[2]]
	}

	public var scalars: (CGFloat, CGFloat, CGFloat) {
		get { return (values[0], values[1], values[2])}
	}

	public var description: String {
		get {
			return "[\(values[0]), \(values[1]), \(values[2])]"
		}
	}

	public static func < (lhs: CNVector3D, rhs: CNVector3D) -> Bool {
		if lhs.values[0] < rhs.values[0] || lhs.values[1] < rhs.values[1] || lhs.values[2] < rhs.values[2] {
			return true
		} else {
			return false
		}
	}

	public static func > (lhs: CNVector3D, rhs: CNVector3D) -> Bool {
		if !(lhs < rhs) && (lhs != rhs) {
			return true
		} else {
			return false
		}
	}

	public static func == (lhs: CNVector3D, rhs: CNVector3D) -> Bool {
		if lhs.values[0] == rhs.values[0] && lhs.values[1] == rhs.values[1] && lhs.values[2] == rhs.values[2] {
			return true
		} else {
			return false
		}
	}

	public static func != (lhs: CNVector3D, rhs: CNVector3D) -> Bool {
		if lhs.values[0] != rhs.values[0] || lhs.values[1] != rhs.values[1] || lhs.values[2] != rhs.values[2] {
			return true
		} else {
			return false
		}
	}
}

public struct CNMatrix3D : Comparable
{
	public var	values: [[CGFloat]]

	public static var unit: CNMatrix3D {
		get {
			return CNMatrix3D(scalars: [
				[1.0, 0.0, 0.0],
				[0.0, 1.0, 0.0],
				[0.0, 0.0, 1.0]
			])
		}
	}

	public init() {
		values = [
			[0.0, 0.0, 0.0],
			[0.0, 0.0, 0.0],
			[0.0, 0.0, 0.0],
		]
	}

	public init(scalars scls: [[CGFloat]]) {
		values = [
				[scls[0][0], scls[0][1], scls[0][2]],
				[scls[1][0], scls[1][1], scls[1][2]],
				[scls[2][0], scls[2][1], scls[2][2]],
			 ]
	}

	public var description: String {
		get {
			return   "[[\(values[0][0]), \(values[0][1]), \(values[0][2])]\n"
			       + " [\(values[1][0]), \(values[1][1]), \(values[1][2])]\n"
			       + " [\(values[2][0]), \(values[2][1]), \(values[2][2])]]"
		}
	}

	public static func < (lhs: CNMatrix3D, rhs: CNMatrix3D) -> Bool {
		for x in 0..<3 {
			for y in 0..<3 {
				if lhs.values[x][y] < rhs.values[x][y] {
					return true
				}
			}
		}
		return false
	}

	public static func > (lhs: CNMatrix3D, rhs: CNMatrix3D) -> Bool {
		if !(lhs < rhs) && (lhs != rhs) {
			return true
		} else {
			return false
		}
	}

	public static func == (lhs: CNMatrix3D, rhs: CNMatrix3D) -> Bool {
		for x in 0..<3 {
			for y in 0..<3 {
				if lhs.values[x][y] != rhs.values[x][y] {
					return false
				}
			}
		}
		return true
	}

	public static func != (lhs: CNMatrix3D, rhs: CNMatrix3D) -> Bool {
		for x in 0..<3 {
			for y in 0..<3 {
				if lhs.values[x][y] != rhs.values[x][y] {
					return true
				}
			}
		}
		return false
	}
}

public func * (lhs: CNMatrix3D, rhs: CNMatrix3D) -> CNMatrix3D {
	var result = Array(repeating: Array(repeating: CGFloat(0.0), count: 3), count: 3)
	for x in 0..<3 {
		for y in 0..<3 {
			var tmp: CGFloat = 0.0
			for i in 0..<3 {
				tmp += lhs.values[y][i] * rhs.values[i][x]
			}
			result[y][x] = tmp
		}
	}
	return CNMatrix3D(scalars: result)
}

public func * (lhs: CNMatrix3D, rhs: CNVector3D) -> CNVector3D {
	let v0 =   lhs.values[0][0] * rhs.values[0]
		 + lhs.values[0][1] * rhs.values[1]
		 + lhs.values[0][2] * rhs.values[2]
	let v1 =   lhs.values[1][0] * rhs.values[0]
		 + lhs.values[1][1] * rhs.values[1]
		 + lhs.values[1][2] * rhs.values[2]
	let v2 =   lhs.values[2][0] * rhs.values[0]
		 + lhs.values[2][1] * rhs.values[1]
		 + lhs.values[2][2] * rhs.values[2]
	return CNVector3D(scalars: [v0, v1, v2])
}

public func * (lhs: CNMatrix3D, rhs: CGFloat) -> CNMatrix3D {
	let v00 = lhs.values[0][0] * rhs
	let v01 = lhs.values[0][1] * rhs
	let v02 = lhs.values[0][2] * rhs
	let v10 = lhs.values[1][0] * rhs
	let v11 = lhs.values[1][1] * rhs
	let v12 = lhs.values[1][2] * rhs
	let v20 = lhs.values[2][0] * rhs
	let v21 = lhs.values[2][1] * rhs
	let v22 = lhs.values[2][2] * rhs
	return CNMatrix3D(scalars: [
		[v00, v01, v02],
		[v10, v11, v12],
		[v20, v21, v22]
	])
}

public func distance(pointA pa: CGPoint, pointB pb: CGPoint) -> CGFloat {
	let dx = pb.x - pa.x
	let dy = pb.y - pa.y
	return sqrt(dx*dx + dy*dy)
}

