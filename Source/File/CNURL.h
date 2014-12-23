/**
 * @file	CNURL.h
 * @brief	Extend NSURL class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>

/**
 * @brief Type of URI scheme.
 * Reference <a href="http://en.wikipedia.org/wiki/URI_scheme">URI scheme</a>.
 */
typedef enum {
	CNURINoScheme,          /**<< No scheme		*/
	CNURIFileScheme,        /**<< File scheme	*/
	CNURIHttpScheme,	/**<< HTTP scheme	*/
	CNURIHttpsScheme	/**<< HTTPS scheme	*/
} CNURIScheme ;

@interface NSURL (CNURLExtension)

+ (NSURL *) allocateURLForFile: (NSString *) fname error: (NSError **) error ;
+ (CNURIScheme) schemeOfString: (NSString *) src ;

@end
