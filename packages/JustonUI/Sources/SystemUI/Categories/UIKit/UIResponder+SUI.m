//
//  Created by Anton Spivak
//

#import "UIResponder+SUI.h"

@implementation UIResponder (SUI)

- (UIResponder * _Nullable)sui_traverseResponderChainForSubclassOfClass:(Class)aClass {
    UIResponder *nextResponder = [self nextResponder];
    while (nextResponder != nil && ![[nextResponder class] isSubclassOfClass:aClass]) {
        nextResponder = [nextResponder nextResponder];
    }
    return nextResponder;
}

@end
