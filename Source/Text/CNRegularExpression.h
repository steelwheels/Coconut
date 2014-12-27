/**
 * @file	CNRegularExpression.h
 * @brief	Define CNRegularExpression class
 * @par Copyright
 *   Copyright (C) 2007 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import <regex.h>

/**
 * @brief Regular expression
 */
@interface CNRegularExpression : NSObject
{
	/** Original pattern */
	//NSString *				originalPattern ;
	/** Body of regular expression */
	regex_t *				regularExpression ;
	/** Buffer to keep matched patterns */
	regmatch_t *				matchedPatterns ;
}

  /**
   * @brief	Initialize regular expression by pattern
   * @return Initialized CNRegularExpression object
   * @param	pattern Input regular expression
   * @param error Result error
   * @par Node
   *   Parameter error is set when pattern compilation failed.
   *   In this case, return value is nil.
   */
- (id) initWithString: (NSString *) pattern error: (NSError **) error ;

  /**
   * @brief Deallocate object
   */
- (void) dealloc ;


  /**
   * @brief Execute matching with C string
   * @retval true  Matching is successed
   * @retval false Matching is failed
   * @param str Source string to be compared
   */
- (BOOL) matchWithCString: (const char *) str ;

  /**
   * @brief Execute matching with string
   * @retval true  Matching is successed
   * @retval false Matching is failed
   * @param str Source string to be compared
   */
- (BOOL) matchWithString: (NSString *) str ;

@end
