/**
 * @file	CNMath.h
 * @brief	Define arithmetic functions
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
 */

import Foundation

public func pow(base b:Int, power p:UInt) -> Int
{
	var result : Int = 1
	for _ in 0..<p {
		result *= b
	}
	return result
}

public func clip<T: Comparable>(value v:T, max mx:T, min mn: T) -> T
{
	var result: T
	if v < mn {
		result = mn
	} else if v > mx {
		result = mx
	} else {
		result = v
	}
	return result
}

public func random(between val0: UInt32, and val1: UInt32) -> UInt32
{
	if val0 > val1 {
		return arc4random_uniform(val0 - val1) + val1
	} else if val1 > val0 {
		return arc4random_uniform(val1 - val0) + val0
	} else { // val0 == val1
		return val0
	}
}

public func round(value v:Double, atPoint p:Int) -> Double
{
	var mult: Double = 1.0
	for _ in 0..<p {
		mult = mult * 10.0
	}
	let ival = Int(v * mult)
	return Double(ival) / mult
}
