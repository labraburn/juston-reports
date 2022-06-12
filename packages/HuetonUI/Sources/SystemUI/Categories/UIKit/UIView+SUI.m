//
//  Created by Anton Spivak
//

#import "UIView+SUI.h"
#import "UIViewController+SUI.h"
#import "UIEdgeInsets+SUI.h"

@import Objective42;
@import ObjectiveC.runtime;
@import ObjectiveC.message;

@implementation UIView (SUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // pointInside:withEvent:
        SUISwizzleInstanceMethodOfClass(self, @selector(pointInside:withEvent:), @selector(sui_sw_pointInside:withEvent:));
    });
}

+ (BOOL)sui_isInAnimationBlock {
    // _currentViewAnimationState
    return [self o42_performSelector:SUISelectorFromReversedStringParts(@"wAnimationState", @"_currentVie", nil)] != nil;
}

- (void)sui_triggerFirstInteractionIfPossible {
    // _presentMenuAtLocation:
    SEL sel = SUISelectorFromReversedStringParts(@"nuAtLocation:", @"_presentMe", nil);
    
    id<UIInteraction> interaction = [self.interactions firstObject];
    if (interaction == nil || ![interaction respondsToSelector:sel]) {
        return;
    }
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    typedef void (*function)(id, SEL, CGPoint);
    function block = (function)objc_msgSend;
    block(interaction, sel, center);
}

#pragma mark - Swizzled

/// Warning! This is swizzled method
- (BOOL)sui_sw_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets touchAreaInsets = [self sui_touchAreaInsets];
    if (UIEdgeInsetsEqualToEdgeInsets(touchAreaInsets, UIEdgeInsetsZero)) {
        return [self sui_sw_pointInside:point withEvent:event];
    }
    
    CGRect extendedBounds = UIEdgeInsetsInsetRect(self.bounds, touchAreaInsets);
    return CGRectContainsPoint(extendedBounds, point);
}

#pragma mark - Setters & Getters

// sui_touchAreaInsets

static void * kSUITouchAreaInsetsKey = &kSUITouchAreaInsetsKey;

- (UIEdgeInsets)sui_touchAreaInsets {
    NSValue *value = objc_getAssociatedObject(self, kSUITouchAreaInsetsKey);
    UIEdgeInsets touchAreaInsets = UIEdgeInsetsZero;
    if (value != nil) {
        [value getValue:&touchAreaInsets];
    }
    return touchAreaInsets;
}

- (void)sui_setTouchAreaInsets:(UIEdgeInsets)touchAreaInsets {
    NSValue *value = [NSValue value:&touchAreaInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, kSUITouchAreaInsetsKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
