/**
 * @file	CNValue.m
 * @brief	Define CNValue class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNValue.h"
#import "CNError.h"

static NSError *
formatError(CNValueType type, NSString * param) ;

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

+ (NSString *) valueTypeToString: (CNValueType) type
{
	NSString * result = nil ;
	switch(type){
		case CNNilValue: {
			result = @"" ;
		} break ;
		case CNBooleanValue: {
			result = @"bool" ;
		} break ;
		case CNCharValue: {
			result = @"char" ;
		} break ;
		case CNSignedIntegerValue: {
			result = @"signed int" ;
		} break ;
		case CNUnsignedIntegerValue: {
			result = @"unsigned int" ;
		} break ;
		case CNFloatValue: {
			result = @"float" ;
		} break ;
		case CNStringValue: {
			result = @"string" ;
		} break ;
		case CNObjectValue: {
			result = @"object" ;
		} break ;
	}
	return result ;
}

+ (CNValue *) stringToValue: (NSString *) src withType: (CNValueType) type withError:(NSError *__autoreleasing*) error
{
	const char * srcstr = [src UTF8String] ;
	CNValue * result = nil ;
	switch(type){
		case CNNilValue: {
			assert(false) ;
		} break ;
		case CNBooleanValue: {
			if(strcmp(srcstr, "true") == 0 || strcmp(srcstr, "TRUE")){
				result = [[CNValue alloc] initWithBooleanValue: YES] ;
			} else if(strcmp(srcstr, "false") == 0 || strcmp(srcstr, "FALSE")){
				result = [[CNValue alloc] initWithBooleanValue: YES] ;
			} else {
				*error = formatError(CNBooleanValue, src) ;
			}
		} break ;
		case CNCharValue: {
			if(strlen(srcstr) == 1){
				result = [[CNValue alloc] initWithCharValue: srcstr[0]] ;
			} else {
				*error = formatError(CNCharValue, src) ;
			}
		} break ;
		case CNSignedIntegerValue: {
			char * endp ;
			NSInteger val = (NSInteger) strtoll(srcstr, &endp, 0) ;
			if(*endp == '\0'){
				result = [[CNValue alloc] initWithSignedIntegerValue: val] ;
			} else {
				*error = formatError(CNSignedIntegerValue, src) ;
			}
		} break ;
		case CNUnsignedIntegerValue: {
			char * endp ;
			NSUInteger val = strtoul(srcstr, &endp, 0) ;
			if(*endp == '\0'){
				result = [[CNValue alloc] initWithUnsignedIntegerValue: val] ;
			} else {
				*error = formatError(CNUnsignedIntegerValue, src) ;
			}
		} break ;
		case CNFloatValue: {
			char * endp ;
			double val = strtold(srcstr, &endp) ;
			if(*endp == '\0'){
				result = [[CNValue alloc] initWithFloatValue: val] ;
			} else {
				*error = formatError(CNUnsignedIntegerValue, src) ;
			}
		} break ;
		case CNStringValue: {
			result = [[CNValue alloc] initWithStringValue: src] ;
		} break ;
		case CNObjectValue: {
			assert(false) ; /* Not supported */
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

- (CNValueType) type
{
	return valueType ;
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

- (NSString *) description
{
	NSString * result = nil ;
	switch(valueType){
		case CNNilValue: {
			result = nil ;
		} break ;
		case CNBooleanValue: {
			result = [self booleanValue] ? @"true" : @"false" ;
		} break ;
		case CNCharValue: {
			char val = [self charValue] ;
			char valstr[32] ;
			snprintf(valstr, 32, "%c", val) ;
			result = [[NSString alloc] initWithUTF8String: valstr] ;
		} break ;
		case CNSignedIntegerValue: {
			NSInteger val = [self signedIntegerValue] ;
			char valstr[32] ;
			snprintf(valstr, 32, "%zd", val) ;
			result = [[NSString alloc] initWithUTF8String: valstr] ;
		} break ;
		case CNUnsignedIntegerValue: {
			NSUInteger val = [self unsignedIntegerValue] ;
			char valstr[32] ;
			snprintf(valstr, 32, "%tu", val) ;
			result = [[NSString alloc] initWithUTF8String: valstr] ;
		} break ;
		case CNFloatValue: {
			double val = [self floatValue] ;
			char valstr[32] ;
			snprintf(valstr, 32, "%lf", val) ;
			result = [[NSString alloc] initWithUTF8String: valstr] ;
		} break ;
		case CNStringValue: {
			result = [self stringValue] ;
		} break ;
		case CNObjectValue: {
			NSObject * objval = [self objectValue] ;
			result = [objval description] ;
		} break ;
	}
	return result ;
}

@end

static NSError *
formatError(CNValueType type, NSString * param)
{
	NSString * typestr = [CNValue valueTypeToString: type] ;
	if(typestr == nil){
		typestr = @"Unknown" ;
	}
	NSString * message = [[NSString alloc] initWithFormat:
			      @"Type %s is required, but \"%s\" is given",
			      [typestr UTF8String],
			      [param UTF8String]] ;
	return [NSError parseErrorWithMessage: message] ;
}

