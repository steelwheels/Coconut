/**
 * @file	CNValue.m
 * @brief	Define CNValue class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNValue.h"

@implementation CNValue

+ (BOOL) isObjectType: (CNValueType) valuetype
{
	BOOL result ;
	switch(valuetype){
		case CNStringValue:
		case CNObjectValue: {
			result = YES ;
		} break ;
		default : {
			result = NO ;
		} break ;
	}
	return result ;
}

- (instancetype) initWithBooleanValue: (BOOL) val
{
	if((self = [super init])){
		valueType		= CNBooleanValue ;
		valueData.booleanValue	= val ;
	}
	return self ;
}

- (instancetype) initWithCharValue: (unsigned char) val
{
	if((self = [super init])){
		valueType		= CNCharValue ;
		valueData.charValue	= val ;
	}
	return self ;
}

- (instancetype) initWithSignedIntegerValue: (NSInteger) val
{
	if((self = [super init])){
		valueType			= CNSignedIntegerValue ;
		valueData.signedIntegerValue	= val ;
	}
	return self ;
}

- (instancetype) initWithUnsignedIntegerValue: (NSUInteger) val
{
	if((self = [super init])){
		valueType			= CNUnsignedIntegerValue ;
		valueData.unsignedIntegerValue	= val ;
	}
	return self ;
}

- (instancetype) initWithFloatValue: (double) val
{
	if((self = [super init])){
		valueType			= CNFloatValue ;
		valueData.floatValue		= val ;
	}
	return self ;
}

- (instancetype) initWithStringValue: (NSString *) val
{
	if((self = [super init])){
		valueType			= CNStringValue ;
		valueData.objectValue		= (__bridge_retained void *) val ;
	}
	return self ;
}

- (instancetype) initWithUTF8StringValue: (const char *) val
{
	if((self = [super init])){
		valueType			= CNStringValue ;
		NSString * strval		= [[NSString alloc] initWithUTF8String: val] ;
		valueData.objectValue		= (__bridge_retained void *) strval ;
	}
	return self ;
}

- (instancetype) initWithObjectValue: (NSObject *) val
{
	if((self = [super init])){
		valueType			= CNObjectValue ;
		valueData.objectValue		= (__bridge_retained void *) val ;
	}
	return self ;
}

- (void) dealloc
{
	if([CNValue isObjectType: valueType]){
		NSObject * obj = (__bridge_transfer NSObject *) valueData.objectValue ;
		obj = nil ;
	}
}

- (BOOL) booleanValue
{
	return valueData.booleanValue ;
}

- (unsigned char) charValue
{
	return valueData.charValue ;
}

- (NSInteger) signedIntegerValue
{
	return valueData.signedIntegerValue ;
}

- (NSUInteger) unsignedIntegerValue
{
	return valueData.unsignedIntegerValue ;
}

- (double) floatValue
{
	return valueData.floatValue ;
}

- (NSString *) stringValue
{
	return (__bridge NSString *) valueData.objectValue ;
}

- (NSObject *) objectValue
{
	return (__bridge NSObject *) valueData.objectValue ;
}

@end
