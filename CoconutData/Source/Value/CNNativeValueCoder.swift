/*
 * @file	CNNativeValueCoder.swift
 * @brief	Define CNNativeValueCoder class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
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
		} else if let url = obj as? URL {
			let val: CNNativeValue = .URLValue(url)
			return (val, nil)
		} else if let image = obj as? CNImage {
			let val: CNNativeValue = .imageValue(image)
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
		if let rect = convertToRect(dictionary: obj) {
			return (CNNativeValue.rectValue(rect), nil)
		} else if let point = convertToPoint(dictionary: obj) {
			return (CNNativeValue.pointValue(point), nil)
		} else if let size = convertToSize(dictionary: obj) {
			return (CNNativeValue.sizeValue(size), nil)
		} else if let range = convertToRange(dictionary: obj) {
			return (CNNativeValue.rangeValue(range), nil)
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
					CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
				}
			}
			return (CNNativeValue.dictionaryValue(result), nil)
		} else {
			let error = NSError.parseError(message: "Failed to convert dictionary \(#function)")
			return (nil, error)
		}
	}

	private func convertToRect(dictionary obj: NSDictionary) -> CGRect? {
		if obj.count == 4 {
			if let xval = obj["x"], let yval = obj["y"], let wval = obj["width"], let hval = obj["height"] {
				if let x      = convertToFloat(object: xval),
				   let y      = convertToFloat(object: yval),
				   let width  = convertToFloat(object: wval),
				   let height = convertToFloat(object: hval) {
					return CGRect(x: x, y: y, width: width, height: height)
				}
			}
		}
		return nil
	}

	private func convertToFloat(object obj: Any) -> CGFloat? {
		if let num = obj as? NSNumber {
			return CGFloat(num.doubleValue)
		}
		return nil
	}

	private func convertToPoint(dictionary obj: NSDictionary) -> CGPoint? {
		if let (x, y) = convertTo2Numbers(dictionary: obj, name0: "x", name1: "y") {
			return CGPoint(x: CGFloat(x.doubleValue), y: CGFloat(y.doubleValue))
		} else {
			return nil
		}
	}

	private func convertToSize(dictionary obj: NSDictionary) -> CGSize? {
		if let (width, height) = convertTo2Numbers(dictionary: obj, name0: "width", name1: "height") {
			return CGSize(width: CGFloat(width.doubleValue), height: CGFloat(height.doubleValue))
		} else {
			return nil
		}
	}

	private func convertToRange(dictionary obj: NSDictionary) -> NSRange? {
		if let (location, length) = convertTo2Numbers(dictionary: obj, name0: "location", name1: "length") {
			return NSRange(location: location.intValue, length: length.intValue)
		} else {
			return nil
		}
	}

	private func convertTo2Numbers(dictionary obj: NSDictionary, name0 nm0: String, name1 nm1: String) -> (NSNumber, NSNumber)? {
		if obj.count == 2 {
			if let num0 = obj.value(forKey: nm0) as? NSNumber,
			   let num1 = obj.value(forKey: nm1) as? NSNumber {
				return (num0, num1)
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
	private var mResult: AnyObject?

	public override init(){
		mResult = nil
	}

	public func convert(value val: CNNativeValue) -> AnyObject {
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

	open override func visit(bool obj: Bool) {
		mResult = NSNumber(booleanLiteral: obj)
	}

	open override func visit(number obj: NSNumber){
		mResult = obj
	}

	open override func visit(string obj: String){
		mResult = NSString(string: obj)
	}

	open override func visit(URL url: URL){
		mResult = NSString(string: url.absoluteString)
	}

	open override func visit(color col: CNColor){
		let (red, green, blue, alpha) = col.toRGBA()
		mResult = NSDictionary(dictionary: [
			NSString(string: "red")		: NSNumber(floatLiteral: Double(red)),
			NSString(string: "green")	: NSNumber(floatLiteral: Double(green)),
			NSString(string: "blue")	: NSNumber(floatLiteral: Double(blue)),
			NSString(string: "alpha")	: NSNumber(floatLiteral: Double(alpha))
		])
	}

	open override func visit(image obj: CNImage){
		mResult = NSString(string: "\(obj.description)")
	}

	open override func visit(object obj: NSObject){
		mResult = obj
	}

	open override func visit(date obj: Date){
		mResult = NSDate(timeInterval: 0.0, since: obj)
	}

	open override func visit(range obj: NSRange){
		let location = NSNumber(integerLiteral: obj.location)
		let length   = NSNumber(integerLiteral: obj.length)
		mResult = NSDictionary(dictionary: [
			NSString(string: "location") : location,
			NSString(string: "length")   : length
		])
	}

	open override func visit(point obj: CGPoint){
		mResult = convertTo2Numbers(name0: "x", value0: Double(obj.x), name1: "y", value1: Double(obj.y))
	}

	open override func visit(size obj: CGSize){
		mResult = convertTo2Numbers(name0: "width", value0: Double(obj.width), name1: "height", value1: Double(obj.height))
	}

	open override func visit(rect obj: CGRect){
		let xnum = NSNumber(value: Double(obj.origin.x))
		let ynum = NSNumber(value: Double(obj.origin.y))
		let wnum = NSNumber(value: Double(obj.size.width))
		let hnum = NSNumber(value: Double(obj.size.height))
		mResult = NSDictionary(dictionary: [
			NSString(string: "x"): 		xnum,
			NSString(string: "y"): 		ynum,
			NSString(string: "width"): 	wnum,
			NSString(string: "height"): 	hnum
		])
	}

	open override func visit(enumType etype: String, value val: Int32) {
		mResult = NSNumber(value: val)
	}

	private func convertTo2Numbers(name0 nm0: String, value0 val0: Double, name1 nm1: String, value1 val1: Double) -> NSDictionary {
		let nmstr0  = NSString(string: nm0)
		let valnum0 = NSNumber(floatLiteral: val0)
		let nmstr1  = NSString(string: nm1)
		let valnum1 = NSNumber(floatLiteral: val1)
		return NSDictionary(dictionary: [
			nmstr0: valnum0,
			nmstr1: valnum1
		])
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
}

