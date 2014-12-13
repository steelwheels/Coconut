/**
 * @file	CNValue.h
 * @brief	Define CNValue class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>

typedef enum  {
	CNNilValue,
	CNBooleanValue,
	CNCharValue,
	CNSignedIntegerValue,
	CNUnsignedIntegerValue,
	CNFloatValue,
	CNStringValue,
	CNObjectValue
} CNValueType ;

@interface CNValue : NSObject
{
	CNValueType			valueType ;
	union {
		BOOL			booleanValue ;
		unsigned char		charValue ;
		NSInteger		signedIntegerValue ;
		NSUInteger		unsignedIntegerValue ;
		double			floatValue ;
		void *			objectValue ;
	} valueData ;
}

+ (BOOL) isObjectType: (CNValueType) valuetype ;
+ (NSString *) valueTypeToString: (CNValueType) type ;
+ (CNValue *) stringToValue: (NSString *) src withType: (CNValueType) type withError: (NSError * __autoreleasing *) error ;

- (instancetype) initWithBooleanValue: (BOOL) val ;
- (instancetype) initWithCharValue: (unsigned char) val ;
- (instancetype) initWithSignedIntegerValue: (NSInteger) val ;
- (instancetype) initWithUnsignedIntegerValue: (NSUInteger) val ;
- (instancetype) initWithFloatValue: (double) val ;
- (instancetype) initWithStringValue: (NSString *) val ;
- (instancetype) initWithUTF8StringValue: (const char *) val ;
- (instancetype) initWithObjectValue: (NSObject *) val ;

- (void) dealloc ;

- (CNValueType) type ;

- (BOOL) booleanValue ;
- (unsigned char) charValue ;
- (NSInteger) signedIntegerValue ;
- (NSUInteger) unsignedIntegerValue ;
- (double) floatValue ;
- (NSString *) stringValue ;
- (NSObject *) objectValue ;

- (NSString *) description ;

@end
