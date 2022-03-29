//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

SUI_EXPORT NSErrorDomain const NSExceptionErrorDomain;

@interface NSException (NSError)

/// Converts NSException to NSError object with `NSExceptionErrorDomain`
- (NSError *)error;

@end

NS_ASSUME_NONNULL_END
