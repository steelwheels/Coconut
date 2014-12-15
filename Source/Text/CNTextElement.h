/**
 * @file	CNTextElement.h
 * @brief	Define CNTextElement class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>

typedef enum {
	CNTextLineElement,
	CNTextSectionElement
} CNTextElementKind ;

@protocol CNTextElementOperatiing <NSObject>
- (void) printToFile: (FILE *) outfp withIndent: (NSUInteger) indent ;
@end

@interface CNTextElement : NSObject <CNTextElementOperatiing>

@property (assign, nonatomic) CNTextElementKind		elementKind ;

- (instancetype) initWithElementKind: (CNTextElementKind) kind ;

+ (void) printIndent: (NSUInteger) indent toFile: (FILE *) outfp ;

@end

