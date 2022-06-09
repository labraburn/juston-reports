//
//  Created by Anton Spivak
//

#import "UIScrollView+SUI.h"
#import <objc/runtime.h>

@implementation UIScrollView (SUI)

- (void)sui_scrollToTopIfPossible:(BOOL)flag {
    SEL sel = SUISelectorFromReversedStringParts(@"pIfPossible:", @"_scrollToTo", nil);
    typedef void (*function)(id, SEL, BOOL);
    function block = (function)objc_msgSend;
    block(self, sel, flag);
}

@end
