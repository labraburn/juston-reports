//
//  O42NSExceptionHandler.h
//  
//
//  Created by Anton Spivak on 02.04.2022.
//

#import "Objective42.h"

NS_ASSUME_NONNULL_BEGIN

/// Call Objective-C throwable function inside `executionBlock` and handle it in `errorHandler` block
O42_EXPORT void throwable_execution(void (^NS_NOESCAPE executionBlock)(void), void (^NS_NOESCAPE  _Nullable errorHandler)(NSError * _Nonnull));

@interface O42NSExceptionHandler : NSObject

/// Execute block and receive an error if that has been throwed by ObjectiveC
+ (void)execute:(void (^NS_NOESCAPE)(void))block error:(NSError * __autoreleasing *)error O42_SWIFT_ERROR;

@end

NS_ASSUME_NONNULL_END
