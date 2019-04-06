/*
 * @file	CNNativeValueVisitor.swift
 * @brief	Define CNNativeValueVisitor class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNNativeValueVisitor
{
	public func accept(value val: CNNativeValue){
		switch val {
		case .nullValue:		visitNill()
		case .numberValue(let obj):	visit(number: obj)
		case .stringValue(let obj):	visit(string: obj)
		case .dateValue(let obj):	visit(date: obj)
		case .rangeValue(let obj):	visit(range: obj)
		case .pointValue(let obj):	visit(point: obj)
		case .sizeValue(let obj):	visit(size: obj)
		case .rectValue(let obj):	visit(rect: obj)
		case .dictionaryValue(let obj):	visit(dictionary: obj)
		case .arrayValue(let obj):	visit(array: obj)
		case .URLValue(let obj):	visit(URL: obj)
		case .imageValue(let obj):	visit(image: obj)
		}
	}

	open func visitNill(){	}
	open func visit(number obj: NSNumber){	}
	open func visit(string obj: String){ }
	open func visit(date obj: Date){ }
	open func visit(range obj: NSRange){ }
	open func visit(point obj: CGPoint){ }
	open func visit(size obj: CGSize){ }
	open func visit(rect obj: CGRect){ }
	open func visit(dictionary obj: Dictionary<String, CNNativeValue>){ }
	open func visit(array obj: Array<CNNativeValue>){ }
	open func visit(URL obj: URL){ }
	open func visit(image obj: CNImage){ }
}

