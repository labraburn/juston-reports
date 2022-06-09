//
//  Created by Anton Spivak
//

#import "NSObject+O42.h"
#import <objc/message.h>

@implementation NSObject (SUI)

- (id _Nullable)o42_performSelector:(SEL)aSelector {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (![self respondsToSelector:aSelector]) {
        #if DEBUG
        NSLog(@"%@ doesn't respond to selector %@", self, NSStringFromSelector(aSelector));
        #endif
        return nil;
    }
    
    return [self performSelector:aSelector];
#pragma clang diagnostic pop
}

- (id _Nullable)o42_performSelector:(SEL)aSelector withObject:(id _Nullable)object {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (![self respondsToSelector:aSelector]) {
        #if DEBUG
        NSLog(@"%@ doesn't respond to selector %@", self, NSStringFromSelector(aSelector));
        #endif
        return nil;
    }
    
    return [self performSelector:aSelector withObject:object];
#pragma clang diagnostic pop
}

- (id _Nullable)o42_performSelector:(SEL)aSelector withObject:(id _Nullable)object1 withObject:(id _Nullable)object2 {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (![self respondsToSelector:aSelector]) {
        #if DEBUG
        NSLog(@"%@ doesn't respond to selector %@", self, NSStringFromSelector(aSelector));
        #endif
        return nil;
    }
    
    return [self performSelector:aSelector withObject:object1 withObject:object2];
#pragma clang diagnostic pop
}

- (BOOL)o42_isKindOfSystemClass {
    return [NSStringFromClass([self class]) hasPrefix:@"_"];
}

@end
