//
//  Created by Anton Spivak
//

#import "UIView+SUI.h"
#import "UIResponder+SUI.h"
#import "UIViewController+SUI.h"
#import "UIEdgeInsets+SUI.h"

#import "../../SUIWeakObjectWrapper.h"

#import "../Foundation/NSValue+SUIGeometry.h"
#import "../Foundation/NSObject+SUI.h"

#import <objc/runtime.h>

@implementation UIView (SUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // _actingParentViewForGestureRecognizers
        SUISwizzleInstanceMethodOfClass(self, SUISelectorFromReversedStringParts(@"ewForGestureRecognizers", @"_actingParentVi", nil), @selector(sui_sw_actingParentViewForGestureRecognizers));
        
        // layoutSublayersOfLayer:
        SUISwizzleInstanceMethodOfClass(self, @selector(layoutSublayersOfLayer:), @selector(sui_sw_layoutSublayersOfLayer:));
        
        // safeAreaInsets
        SUISwizzleInstanceMethodOfClass(self, @selector(safeAreaInsets), @selector(sui_sw_safeAreaInsets));
        
        // didAddSubview:
        SUISwizzleInstanceMethodOfClass(self, @selector(didAddSubview:), @selector(sui_sw_didAddSubview:));
        
        // pointInside:withEvent:
        SUISwizzleInstanceMethodOfClass(self, @selector(pointInside:withEvent:), @selector(sui_pointInside:withEvent:));
    });
}

+ (BOOL)sui_isInAnimationBlock {
//    _currentViewAnimationState
    return [self sui_performSelector:SUISelectorFromReversedStringParts(@"wAnimationState", @"_currentVie", nil)] != nil;
}

- (void)sui_recursivelyUpdateUnclampedContentInsets:(SUIUnclampedInsets)insets withEnclosingViewController:(UIViewController *)enclosingViewController {
    if (enclosingViewController == nil) {
        [self sui_unclampedContentInsetsDidChange];
        return;
    }
    
    UIViewController *currentEnclosingViewController = [self sui_enclosingViewController];
    if (currentEnclosingViewController != nil && currentEnclosingViewController != enclosingViewController) {
        return;
    }
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self sui_enclosingViewController] != enclosingViewController) {
            return;
        }
        
        [obj sui_setUnclampedContentInsets:insets];
        [obj sui_recursivelyUpdateUnclampedContentInsets:insets withEnclosingViewController:enclosingViewController];
    }];
    
    [self sui_unclampedContentInsetsDidChange];
}

- (void)sui_recursivelyUpdateUnclampedContentInsetsToSubviewsWhileNoEnclosingViewController:(SUIUnclampedInsets)insets {
    if ([self sui_enclosingViewController] != nil) {
        return;
    }
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj sui_setUnclampedContentInsets:insets];
        [obj sui_recursivelyUpdateUnclampedContentInsetsToSubviewsWhileNoEnclosingViewController:insets];
    }];
    
    [self sui_unclampedContentInsetsDidChange];
}

- (void)sui_unclampedContentInsetsDidChange {}

#pragma mark - Swizzled

/// Warning! This is swizzled method
- (UIView *)sui_sw_actingParentViewForGestureRecognizers {
    UIView *oc_overridenGestureRecognizersParent = [self sui_overridenGestureRecognizersParent];
    if (oc_overridenGestureRecognizersParent == nil) {
        // Call original
        oc_overridenGestureRecognizersParent = [self sui_sw_actingParentViewForGestureRecognizers];
    }
    return oc_overridenGestureRecognizersParent;
}

/// Warning! This is swizzled method
- (void)sui_sw_layoutSublayersOfLayer:(CALayer *)layer {
    [self sui_sw_layoutSublayersOfLayer:layer];
    [[self sui_enclosingViewController] sui_updateUnclampedContentInsetsForChildrenIfNeccessary];
    
    UIPageViewController *enclosingPageViewController = (UIPageViewController *)[self sui_traverseResponderChainForSubclassOfClass:[UIPageViewController class]];
    if (enclosingPageViewController != nil) {
        [enclosingPageViewController sui_updateUnclampedContentInsetsForChildrenIfNeccessary];
    }
}

/// Warning! This is swizzled method
- (UIEdgeInsets)sui_sw_safeAreaInsets {
    UIEdgeInsets safeAreaInsets = [self sui_sw_safeAreaInsets];
    if ([self sui_excludesUnclampedInsets]) {
        SUIUnclampedInsets unclampedInsets = [self sui_unclampedContentInsets];
        safeAreaInsets = UIEdgeInsetsWithAdditionalUIEdgeInsets(safeAreaInsets, (UIEdgeInsets) {
            .top = -unclampedInsets.insets.top,
            .left = -unclampedInsets.insets.left,
            .bottom = -unclampedInsets.insets.bottom,
            .right = -unclampedInsets.insets.right,
        });
    }
    return safeAreaInsets;
}

//_systemContentInsetIncludingAccessories

/// Warning! This is swizzled method
- (BOOL)sui_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets touchAreaInsets = [self sui_touchAreaInsets];
    if (UIEdgeInsetsEqualToEdgeInsets(touchAreaInsets, UIEdgeInsetsZero)) {
        return [self sui_pointInside:point withEvent:event];
    }
    
    CGRect extendedBounds = UIEdgeInsetsInsetRect(self.bounds, touchAreaInsets);
    return CGRectContainsPoint(extendedBounds, point);
}

/// Warning! This is swizzled method
- (void)sui_sw_didAddSubview:(UIView *)subview {
    [self sui_sw_didAddSubview:subview];
    
    if ([subview sui_enclosingViewController] != nil) {
        return;
    }
    
    SUIUnclampedInsets unclampedInsets = [self sui_unclampedContentInsets];
    [subview sui_setUnclampedContentInsets:unclampedInsets];
    [subview sui_recursivelyUpdateUnclampedContentInsetsToSubviewsWhileNoEnclosingViewController:unclampedInsets];
}

#pragma mark - Setters & Getters

// sui_overridenGestureRecognizersParent

static void * kSUIOverridenGestureRecognizersParentKey = &kSUIOverridenGestureRecognizersParentKey;

- (void)sui_setOverridenGestureRecognizersParent:(UIView * _Nullable)sui_overridenGestureRecognizersParent {
    [self sui_overridenGestureRecognizersParentWeakObjectWrapper].wrappedObject = sui_overridenGestureRecognizersParent;
}

- (UIView *)sui_overridenGestureRecognizersParent {
    return [self sui_overridenGestureRecognizersParentWeakObjectWrapper].wrappedObject;
}

- (SUIWeakObjectWrapper<UIView *> *)sui_overridenGestureRecognizersParentWeakObjectWrapper {
    SUIWeakObjectWrapper *objectWrapper = objc_getAssociatedObject(self, kSUIOverridenGestureRecognizersParentKey);
    if (objectWrapper == nil) {
        objectWrapper = [[SUIWeakObjectWrapper alloc] init];
        objc_setAssociatedObject(self, kSUIOverridenGestureRecognizersParentKey, objectWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objectWrapper;
}

// sui_unclampedContentInsets

static void * kSUIUnclampedContentInsetsKey = &kSUIUnclampedContentInsetsKey;

- (void)sui_setUnclampedContentInsets:(SUIUnclampedInsets)sui_unclampedContentInsets {
    if (SUIUnclampedInsetsEqualToUnclampedInsets(sui_unclampedContentInsets, [self sui_unclampedContentInsets])) {
        return;
    }
    
    objc_setAssociatedObject(self, kSUIUnclampedContentInsetsKey, [NSValue valueWithSUIUnclampedInsets:sui_unclampedContentInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIViewController *enclosingViewController = [self sui_enclosingViewController];
    [self sui_recursivelyUpdateUnclampedContentInsets:sui_unclampedContentInsets
                          withEnclosingViewController:enclosingViewController];
}

- (SUIUnclampedInsets)sui_unclampedContentInsets {
    NSValue *value = objc_getAssociatedObject(self, kSUIUnclampedContentInsetsKey);
    return value == nil ? SUIUnclampedInsetsZero : [value SUIUnclampedInsetsValue];
}

// sui_enclosingViewController

- (UIViewController *)sui_enclosingViewController {
    return [self sui_performSelector:SUISelectorFromReversedStringParts(@"ewDelegate", @"_vi", nil)];
}

// sui_excludesUnclampedInsets

static void * kSUIExcludesUnclampedInsetsKey = &kSUIExcludesUnclampedInsetsKey;

- (void)sui_setExcludesUnclampedInsets:(BOOL)excludesUnclampedInsets {
    objc_setAssociatedObject(self, kSUIExcludesUnclampedInsetsKey, @(excludesUnclampedInsets), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sui_excludesUnclampedInsets {
    NSNumber *value = objc_getAssociatedObject(self, kSUIExcludesUnclampedInsetsKey);
    return value == nil ? NO : [value boolValue];
}

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

@interface UIView (UIDimmingView)
@end
@implementation UIView (UIDimmingView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (@available(iOS 15, *)) {
            return;
        }
        
        // UIDimmingView
        Class klass = SUIClassFromReversedStringParts(@"ingView", @"UIDimm", nil);
        Method m1 = class_getInstanceMethod(klass, @selector(hitTest:withEvent:));
        Method m2 = class_getInstanceMethod(self, @selector(sui_sw_hitTest:withEvent:));
        method_exchangeImplementations(m1, m2);
    });
}

- (UIView *)sui_sw_hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // Warning! Here self if UIDimmingView
    UIView *hit = [self sui_sw_hitTest:point withEvent:event];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id delegate = [self performSelector:@selector(delegate)];
    if (delegate != nil && [NSStringFromClass([delegate class]) containsString:@"Sheet"] && hit == self) {
        // Replicate iOS 15 for sheet controllers
        return nil;
    }
    return hit;
#pragma clang diagnostic pop

}

@end
