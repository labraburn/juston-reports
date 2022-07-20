//
//  Created by Anton Spivak
//

#import "O42NSExceptionHandler.h"
#import "NSException+O42.h"

void throwable_execution(void (^NS_NOESCAPE executionBlock)(void), void (^NS_NOESCAPE  _Nullable errorHandler)(NSError * _Nonnull)) {
    NSError *_error = [NSError errorWithDomain:O42ExceptionErrorDomain code:0 userInfo:@{}];
    @try {
        executionBlock();
    } @catch (NSException *exception) {
        if (errorHandler != nil) {
            if (exception == nil) {
                errorHandler(_error);
            } else {
                errorHandler([exception o42_error]);
            }
        }
    } @finally {}
}

@implementation O42NSExceptionHandler

+ (void)execute:(void (^NS_NOESCAPE)(void))block error:(NSError * __autoreleasing *)error {
    @try {
        block();
    } @catch (NSException *exception) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:O42ExceptionErrorDomain code:0 userInfo:@{}];
            if (exception != nil) {
                *error = [exception o42_error];
            }
        }
    } @finally {}
}

@end
