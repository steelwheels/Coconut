/**
 * @file	CNEditLineCore.h
 * @brief	Define CNEditLineCore class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

#import <Foundation/Foundation.h>

@interface CNEditLineCore : NSObject
{
	@private struct editline *	mEditLine ;
}

- (nonnull instancetype) init ;
- (void) dealloc ;

- (void) setup: (nonnull NSString *) name withInput: (nonnull NSFileHandle *) inhdl withOutput: (nonnull NSFileHandle *) outhdl withError: (nonnull NSFileHandle *) errhdl ;
- (void) finalize ;
- (void) reset ;

- (void) setBufferedMode: (BOOL) mode ;
- (BOOL) bufferedMode ;

- (nullable NSString *) gets ;
- (char) getc ;

@end
