/**
 * @file	UTMatrix.swift
 * @brief	Test function for CNMatrix3D datastructure
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testMatrix(console cons: CNConsole) -> Bool
{
	let vec0 = CNVector3D()
	cons.print(string: "vec0 = \(vec0.description)\n")

	let vec1 = CNVector3D(scalars: [1.0, 2.0, 3.0])
	cons.print(string: "vec1 = \(vec1.description)\n")

	let mtx0 = CNMatrix3D.unit
	cons.print(string: "mtx0 = \n\(mtx0.description)\n")

	let mtx1 = mtx0 * 2.0
	cons.print(string: "mtx1 = \n\(mtx1.description)\n")

	let res0 = mtx0 * mtx0
	cons.print(string: "res0 = \(res0.description)\n")

	let res1 = mtx1 * vec1
	cons.print(string: "res1 = \(res1.description)\n")

	return true
}

