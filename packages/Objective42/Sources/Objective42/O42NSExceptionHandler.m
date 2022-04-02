//
//  O42NSExceptionHandler.m
//  
//
//  Created by Anton Spivak on 02.04.2022.
//

#import "O42NSExceptionHandler.h"
#import "NSException+NSError.h"

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

@implementation O42NSExceptionHandler

+ (void)execute:(void (^NS_NOESCAPE)(void))block error:(NSError * __autoreleasing *)error {
    @try {
        block();
    } @catch (NSException *exception) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSExceptionErrorDomain code:0 userInfo:@{}];
            if (exception != nil) {
                *error = [exception error];
            }
        }
    } @finally {}
}

@end
