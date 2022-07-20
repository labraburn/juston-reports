//
//  Created by Anton Spivak
//

#import "Objective42.h"

NS_ASSUME_NONNULL_BEGIN

O42_EXPORT NSErrorDomain const O42ExceptionErrorDomain;

@interface NSException (O42NSError)

/// Converts NSException to NSError object with `NSExceptionErrorDomain`
- (NSError *)o42_error;

/// Raises exeception
+ (void)o42_raiseExceptionWithName:(NSExceptionName)name
                            reason:(nullable NSString *)reason
                          userInfo:(nullable NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
