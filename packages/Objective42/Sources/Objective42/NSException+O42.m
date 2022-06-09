//
//  NSException+O42.m
//  
//
//  Created by Anton Spivak on 02.04.2022.
//

#import "NSException+O42.h"

NSErrorDomain const O42ExceptionErrorDomain = @"O42ExceptionErrorDomain";

@implementation NSException (NSError)

- (NSError *)o42_error {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:self.name forKey:@"NSExceptionName"];
    [userInfo setValue:(self.reason ?: @"") forKey:@"NSExceptionReason"];
    [userInfo setValue:self.callStackReturnAddresses forKey:@"NSExceptionCallStackReturnAddresses"];
    [userInfo setValue:self.callStackSymbols forKey:@"NSExceptionCallStackSymbols"];
    [userInfo setValue:(self.userInfo ?: @{}) forKey:@"NSExceptionUserInfo"];
    
    return [NSError errorWithDomain:O42ExceptionErrorDomain code:0 userInfo:@{
        NSUnderlyingErrorKey : self,
        NSDebugDescriptionErrorKey : [userInfo copy],
        NSLocalizedFailureReasonErrorKey : self.reason ?: @""
    }];
}

@end
