//
//  Created by Anton Spivak
//

#import "NSException+NSError.h"

NSErrorDomain const NSExceptionErrorDomain = @"NSExceptionErrorDomain";

@implementation NSException (NSError)

- (NSError *)error {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:self.name forKey:@"NSExceptionName"];
    [userInfo setValue:(self.reason ?: @"") forKey:@"NSExceptionReason"];
    [userInfo setValue:self.callStackReturnAddresses forKey:@"NSExceptionCallStackReturnAddresses"];
    [userInfo setValue:self.callStackSymbols forKey:@"NSExceptionCallStackSymbols"];
    [userInfo setValue:(self.userInfo ?: @{}) forKey:@"NSExceptionUserInfo"];
    
    return [NSError errorWithDomain:NSExceptionErrorDomain code:0 userInfo:@{
        NSUnderlyingErrorKey : self,
        NSDebugDescriptionErrorKey : [userInfo copy],
        NSLocalizedFailureReasonErrorKey : self.reason ?: @""
    }];
}

@end
