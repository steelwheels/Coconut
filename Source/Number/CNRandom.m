/**
 * @file	CNRandom.m
 * @brief	Define CNRandom class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNRandom.h"
#import <time.h>

@implementation CNRandom

+ (void) initialize
{
	static dispatch_once_t once;
	dispatch_once( &once, ^{
		srand((unsigned int) time(NULL));
	});
}

+ (NSInteger) randomIntegerBetween: (NSInteger) minval and: (NSInteger) maxval
{
	if(minval < maxval){
		/* [reference]
		 *  http://homepage3.nifty.com/mmgames/c_guide/21-02.html
		 */
		return minval + (rand()*(maxval-minval+1.0)/(1.0+RAND_MAX));
	} else {
		return minval ;
	}
}

@end
