//
//  UIControl+SUI.m
//  
//
//  Created by Andrew Podkovyrin on 08.02.2022.
//

#import "UIControl+SUI.h"

#import "../../SystemUI.h"

#import <objc/runtime.h>

@implementation UIControl (SUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SUISwizzleInstanceMethodOfClass(self, @selector(pointInside:withEvent:), @selector(sui_pointInside:withEvent:));
    });
}

- (BOOL)sui_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    const UIEdgeInsets touchAreaInsets = self.sui_touchAreaInsets;
    if(UIEdgeInsetsEqualToEdgeInsets(touchAreaInsets, UIEdgeInsetsZero)) {
        return [self sui_pointInside:point withEvent:event];
    }
    
    CGRect extendedBounds = UIEdgeInsetsInsetRect(self.bounds, touchAreaInsets);
    return CGRectContainsPoint(extendedBounds, point);
}

- (UIEdgeInsets)sui_touchAreaInsets {
    NSValue *value = objc_getAssociatedObject(self, @selector(sui_touchAreaInsets));
    if (value) {
        UIEdgeInsets touchAreaInsets;
        [value getValue:&touchAreaInsets];
        return touchAreaInsets;
    }
    else {
        return UIEdgeInsetsZero;
    }
}

- (void)setSui_touchAreaInsets:(UIEdgeInsets)touchAreaInsets {
    NSValue *value = [NSValue value:&touchAreaInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, @selector(sui_touchAreaInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
