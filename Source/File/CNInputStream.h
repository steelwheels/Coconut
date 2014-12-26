/**
 * @file	CNInputStream.h
 * @brief	Define CNInputStream class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>

@protocol  CNInputStreaming <NSObject>
- (NSError *) openByURL: (NSURL *) url ;
- (NSUInteger) readInto: (char *) buf withMaxSize: (NSUInteger) maxsize ;
@end

@interface CNInputStream : NSObject <CNInputStreaming>

@end
