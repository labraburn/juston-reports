//
//  Created by Anton Spivak
//

#import "UIResponder+SUI.h"
#import "UIScrollView+SUI.h"

@implementation UIResponder (SUI)

- (void)sui_overrideNextResponderWithResponder:(UIResponder *)overridenNextResponder forType:(UIEventType)type {
    SEL sel = SUISelectorFromReversedStringParts(@"erWithResponder:forType:", @"_overrideNextRespond", nil);
    
    typedef void (* func) (id, SEL, id, long long);
    func call = (func) [self methodForSelector:sel];
    
    call(self, sel, overridenNextResponder, type);
}

- (id<UISUIScrollViewObserver>)sui_scrollViewObserverForScrollView:(UIScrollView *)scrollView {
    return nil;
}

- (UIResponder * _Nullable)sui_traverseResponderChainForSubclassOfClass:(Class)aClass {
    UIResponder *nextResponder = [self nextResponder];
    while (nextResponder != nil && ![[nextResponder class] isSubclassOfClass:aClass]) {
        nextResponder = [nextResponder nextResponder];
    }
    return nextResponder;
}

@end
