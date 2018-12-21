/*
 * @file	CNNativeValueCoder.swift
 * @brief	Define CNNativeValueCoder class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNJSONDecoder
{
	public func convert(object obj: Any) -> (CNNativeValue?, NSError?) {
		if let dict = obj as? NSDictionary {
			return convert(dictionary: dict)
		} else if let arr = obj as? NSArray {
			return convert(array: arr)
		} else if let num = obj as? NSNumber {
			let val: CNNativeValue = .numberValue(num)
			return (val, nil)
		} else if let str = obj as? NSString {
			let val: CNNativeValue = .stringValue(String(str))
			return (val, nil)
		} else if let _ = obj as? NSNull {
			let val: CNNativeValue = .nullValue
			return (val, nil)
		} else {
			let error = NSError.parseError(message: "Unknown object at \(#function)")
			return (nil, error)
		}
	}

	private func convert(dictionary obj: NSDictionary) -> (CNNativeValue?, NSError?) {
		if let point = convertToPoint(dictionary: obj) {
			return (CNNativeValue.pointValue(point), nil)
		} else if let size = convertToSize(dictionary: obj) {
			return (CNNativeValue.sizeValue(size), nil)
		} else if let keys = obj.allKeys as? Array<NSString> {
			var result: Dictionary<String, CNNativeValue> = [:]
			for key in keys {
				let ident = String(key)
				if let val = obj.value(forKey: ident) {
					let (elmval, err) = convert(object: val)
					if let elmobj = elmval {
						result[ident] = elmobj
					} else {
						return (nil, err!)
					}
				} else {
					NSLog("Can not happen at \(#function)")
				}
			}
			return (CNNativeValue.dictionaryValue(result), nil)
		} else {
			let error = NSError.parseError(message: "Failed to convert dictionary \(#function)")
			return (nil, error)
		}
	}

	private func convertToPoint(dictionary obj: NSDictionary) -> CGPoint? {
		if let (x, y) = convertTo2Floats(dictionary: obj, name0: "x", name1: "y") {
			return CGPoint(x: x, y: y)
		} else {
			return nil
		}
	}

	private func convertToSize(dictionary obj: NSDictionary) -> CGSize? {
		if let (width, height) = convertTo2Floats(dictionary: obj, name0: "width", name1: "height") {
			return CGSize(width: width, height: height)
		} else {
			return nil
		}
	}

	private func convertTo2Floats(dictionary obj: NSDictionary, name0 nm0: String, name1 nm1: String) -> (CGFloat, CGFloat)? {
		if obj.count == 2 {
			if let num0 = obj.value(forKey: nm0) as? NSNumber,
			   let num1 = obj.value(forKey: nm1) as? NSNumber {
				let val0 = CGFloat(num0.doubleValue)
				let val1 = CGFloat(num1.doubleValue)
				return (val0, val1)
			}
		}
		return nil
	}

	private func convert(array obj: NSArray) -> (CNNativeValue?, NSError?) {
		var result: Array<CNNativeValue> = []
		for value in Array(obj) {
			let (elmval, err) = convert(object: value)
			if let elmobj = elmval {
				result.append(elmobj)
			} else {
				return (nil, err!)
			}
		}
		return (CNNativeValue.arrayValue(result), nil)
	}
}

public class CNJSONEncoder: CNNativeValueVisitor
{
	private var mResult: NSObject?

	public override init(){
		mResult = nil
	}

	public func convert(value val: CNNativeValue) -> NSObject {
		accept(value: val)
		if let result = mResult {
			return result
		} else {
			fatalError("No object")
		}
	}

	open override func visitNill(){
		mResult = NSNull()
	}

	open override func visit(number obj: NSNumber){
		mResult = obj
	}

	open override func visit(string obj: String){
		mResult = NSString(string: obj)
	}
	
	open override func visit(date obj: Date){
		fatalError("Not supported at \(#function)")
	}

	open override func visit(range obj: NSRange){
		fatalError("Not supported at \(#function)")
	}

	open override func visit(point obj: CGPoint){
		fatalError("Not supported at \(#function)")
	}

	open override func visit(size obj: CGSize){
		fatalError("Not supported at \(#function)")
	}

	open override func visit(rect obj: CGRect){
		fatalError("Not supported at \(#function)")
	}
	open override func visit(dictionary obj: Dictionary<String, CNNativeValue>){
		let newdict = NSMutableDictionary(capacity: 32)
		for (key, val) in obj {
			accept(value: val)
			if let valobj = mResult {
				let keyobj = NSString(string: key)
				newdict.setObject(valobj, forKey: keyobj)
			} else {
				fatalError("Not supported at \(#function)")
			}
		}
		mResult = newdict
	}

	open override func visit(array obj: Array<CNNativeValue>){
		let newarr = NSMutableArray(capacity: 32)
		for val in obj {
			accept(value: val)
			if let valobj = mResult {
				newarr.add(valobj)
			} else {
				fatalError("Not supported at \(#function)")
			}
		}
		mResult = newarr
	}

	open override func visit(object obj: NSObject){
		fatalError("Not supported at \(#function)")
	}
}

