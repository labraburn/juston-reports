//
//  Created by Anton Spivak
//

#import "SUIExceptionHandler.h"
#import "Categories/Foundation/NSException+NSError.h"

void throwable_execution(void (^NS_NOESCAPE executionBlock)(void), void (^NS_NOESCAPE  _Nullable errorHandler)(NSError * _Nonnull)) {
    NSError *_error = [NSError errorWithDomain:NSExceptionErrorDomain code:0 userInfo:@{}];
    @try {
        executionBlock();
    } @catch (NSException *exception) {
        if (errorHandler != nil) {
            if (exception == nil) {
                errorHandler(_error);
            } else {
                errorHandler([exception error]);
            }
        }
    } @finally {}
}
