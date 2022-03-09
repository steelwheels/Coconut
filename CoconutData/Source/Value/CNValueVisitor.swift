/*
 * @file	CNValueVisitor.swift
 * @brief	Define CNValueVisitor class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public class CNValueVisitor
{
	public func accept(value val: CNValue){
		switch val {
		case .nullValue:			visitNill()
		case .boolValue(let obj):		visit(bool: obj)
		case .numberValue(let obj):		visit(number: obj)
		case .stringValue(let obj):		visit(string: obj)
		case .dateValue(let obj):		visit(date: obj)
		case .enumValue(let obj):		visit(enumType: obj)
		case .rangeValue(let obj):		visit(range: obj)
		case .pointValue(let obj):		visit(point: obj)
		case .sizeValue(let obj):		visit(size: obj)
		case .rectValue(let obj):		visit(rect: obj)
		case .dictionaryValue(let obj):		visit(dictionary: obj)
		case .arrayValue(let obj):		visit(array: obj)
		case .URLValue(let obj):		visit(URL: obj)
		case .colorValue(let obj):		visit(color: obj)
		case .imageValue(let obj):		visit(image: obj)
		case .recordValue(let obj):		visit(record: obj)
		case .objectValue(let obj):		visit(object: obj)
		case .reference(let obj):		visit(reference: obj)
		}
	}

	open func visitNill(){	}
	open func visit(bool obj: Bool){	}
	open func visit(number obj: NSNumber){	}
	open func visit(string obj: String){ }
	open func visit(date obj: Date){ }
	open func visit(enumType obj: CNEnum){ }
	open func visit(range obj: NSRange){ }
	open func visit(point obj: CGPoint){ }
	open func visit(size obj: CGSize){ }
	open func visit(rect obj: CGRect){ }
	open func visit(dictionary obj: Dictionary<String, CNValue>){ }
	open func visit(array obj: Array<CNValue>){ }
	open func visit(URL obj: URL){ }
	open func visit(color obj: CNColor){ }
	open func visit(image obj: CNImage){ }
	open func visit(record obj: CNRecord){ }
	open func visit(object obj: NSObject){ }
	open func visit(reference obj: CNValueReference) { }
}

