//
//  Created by Anton Spivak
//

#import "SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

/// Call Objective-C throwable function inside `executionBlock` and handle in `errorHandler` block
SUI_EXPORT void throwable_execution(void (^NS_NOESCAPE executionBlock)(void), void (^NS_NOESCAPE  _Nullable errorHandler)(NSError * _Nonnull));

NS_ASSUME_NONNULL_END
