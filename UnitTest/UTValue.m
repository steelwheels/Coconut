/**
 * @file	UTValue.m
 * @brief	Unit test function for CNValue class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "UnitTest.h"

static void
checkValue(const char * name, CNValue * src) ;
static void
printValue(CNValue * src) ;

void
testValue(void)
{
	checkValue("bool", [[CNValue alloc] initWithBooleanValue: YES]) ;
	checkValue("char", [[CNValue alloc] initWithCharValue: 'c']) ;
	checkValue("int", [[CNValue alloc] initWithSignedIntegerValue: -123]) ;
	checkValue("uint", [[CNValue alloc] initWithUnsignedIntegerValue: 456]) ;
	checkValue("float", [[CNValue alloc] initWithFloatValue: -123.45]) ;
	checkValue("string", [[CNValue alloc] initWithStringValue: @"Hello"]) ;
}

static void
checkValue(const char * name, CNValue * src)
{
	printf("**** Target: %s value\n", name) ;
	printValue(src) ;
	
	NSString * desc = [src description] ;
	NSError * error = nil ;
	CNValue * anotherval = [CNValue stringToValue: desc withType: [src type] withError: &error] ;
	printf("another value -> ") ;
	printValue(anotherval) ;
}

static void
printValue(CNValue * src)
{
	NSString * typestr = [CNValue valueTypeToString: [src type]] ;
	printf("Type : %s, ", [typestr UTF8String]) ;
	
	NSString * descstr = [src description] ;
	printf("Value : %s\n", [descstr UTF8String]) ;
}