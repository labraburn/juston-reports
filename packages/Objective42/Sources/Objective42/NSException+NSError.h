//
//  NSException+NSError.h
//  
//
//  Created by Anton Spivak on 02.04.2022.
//

#import "Objective42.h"

NS_ASSUME_NONNULL_BEGIN

O42_EXPORT NSErrorDomain const NSExceptionErrorDomain;

@interface NSException (O42NSError)

/// Converts NSException to NSError object with `NSExceptionErrorDomain`
- (NSError *)error;

@end

NS_ASSUME_NONNULL_END
