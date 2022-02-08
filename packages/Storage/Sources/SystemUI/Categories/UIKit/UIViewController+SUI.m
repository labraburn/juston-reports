//
//  Created by Anton Spivak
//

#import "UIViewController+SUI.h"
#import "UIScrollView+SUI.h"
#import "UIView+SUI.h"
#import "UIEdgeInsets+SUI.h"

#import "../Foundation/NSObject+SUI.h"
#import "../Foundation/NSValue+SUIGeometry.h"

#import <objc/runtime.h>

@implementation UIViewController (SUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // viewDidAppear
        SUISwizzleInstanceMethodOfClass(self, @selector(viewDidAppear:), @selector(sui_sw_viewDidAppear:));
        SUISwizzleInstanceMethodOfClass(self, @selector(viewWillAppear:), @selector(sui_sw_viewWillAppear:));
        
        // _edgeInsetsForChildViewController:insetsAreAbsolute:
        SUISwizzleInstanceMethodOfClass(self, SUISelectorFromReversedStringParts(@"ewController:insetsAreAbsolute:", @"_edgeInsetsForChildVi", nil), @selector(sui_sw_edgeInsetsForChildViewController:insetsAreAbsolute:));
        
        // _updateUnclampedContentInsetsForSelfAndChildren
        SUISwizzleInstanceMethodOfClass(self, SUISelectorFromReversedStringParts(@"setsForSelfAndChildren", @"_updateContentOverlayIn", nil), @selector(sui_sw_updateContentOverlayInsetsForSelfAndChildren));
        
        // _updateContentOverlayInsetsFromParentIfNecessary
        SUISwizzleInstanceMethodOfClass(self, SUISelectorFromReversedStringParts(@"etsFromParentIfNecessary", @"_updateContentOverlayIns", nil), @selector(sui_sw_updateContentOverlayInsetsFromParentIfNecessary));
    });
}

/// Call to trigger system mechanizm that determinates offsets/insets of current state and did updates views
- (void)sui_updateContentOverlayInsetsForSelfAndChildren {
    if (self.viewIfLoaded.window == nil) {
        return;
    }
    
    // _updateContentOverlayInsetsForSelfAndChildren
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = SUISelectorFromReversedStringParts(@"rlayInsetsForSelfAndChildren", @"_updateContentOve", nil);
    if (![self respondsToSelector:sel]) {
        #if DEBUG
        NSLog(@"%@ doesn't respond to selector %@", self, NSStringFromSelector(sel));
        #endif
        return nil;
    }
    
    return [self performSelector:sel];
#pragma clang diagnostic pop
}

- (void)sui_updateContentOverlayInsetsFromParentIfNecessary {
    if (self.viewIfLoaded.window == nil) {
        return;
    }
    
    // _updateContentOverlayInsetsFromParentIfNecessary
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = SUISelectorFromReversedStringParts(@"rlayInsetsFromParentIfNecessary", @"_updateContentOve", nil);
    if (![self respondsToSelector:sel]) {
        #if DEBUG
        NSLog(@"%@ doesn't respond to selector %@", self, NSStringFromSelector(sel));
        #endif
        return nil;
    }
    
    return [self performSelector:sel];
#pragma clang diagnostic pop
}

- (void)sui_updateUnclampedContentInsetsForChildrenIfNeccessary {}

- (BOOL)sui_shouldApplyUnclampedContentInsetsToChildViewController:(UIViewController *)childViewController {
    return YES;
}

- (BOOL)sui_shouldApplyUnclampedContentInsetsFromParentViewController:(UIViewController *)parentViewController {
    return YES;
}

/// Gets `unclampedContentInsets` from parent and apply it's to self view
- (void)sui_updateUnclampedInsetsFromParentIfNecessary {
    if (self.parentViewController == nil) {
        return;
    }
    
    if (![self.parentViewController sui_shouldApplyUnclampedContentInsetsToChildViewController:self]) {
        return;
    }
    
    if (![self sui_shouldApplyUnclampedContentInsetsFromParentViewController:self.parentViewController]) {
        return;
    }
    
    SUIUnclampedInsets unclampedContentInsets = [self.parentViewController sui_unclampedContentInsets];
    [self.viewIfLoaded sui_setUnclampedContentInsets:unclampedContentInsets];
}

/// Recursively update `unclampedContentInsets` for child view controllers
- (void)sui_updateUnclampedContentInsetsForSelfAndChildren {
    if (self.viewIfLoaded.window == nil) {
        return;
    }
    
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![self sui_shouldApplyUnclampedContentInsetsToChildViewController:obj]) {
            return;
        }
        
        if (![obj sui_shouldApplyUnclampedContentInsetsFromParentViewController:self]) {
            return;
        }
        
        [obj.viewIfLoaded sui_setUnclampedContentInsets:self.sui_unclampedContentInsets];
    }];
}

#pragma mark Swizzle

// Warning! This is swizzled method.
- (UIEdgeInsets)sui_sw_edgeInsetsForChildViewController:(UIViewController *)childViewController insetsAreAbsolute:(BOOL *)insetsAreAbsolute {
    // This method directly overriden in classes from UIKitCore and super didn't called
    // System default value is _overlayContentInsets
    UIEdgeInsets insets = [self sui_sw_edgeInsetsForChildViewController:childViewController insetsAreAbsolute:insetsAreAbsolute];
    if (![childViewController sui_shouldApplyUnclampedContentInsetsFromParentViewController:childViewController]) {
        *insetsAreAbsolute = YES;
        insets = [self.view.superview safeAreaInsets];
    } else {
        insets = UIEdgeInsetsWithAdditionalUIEdgeInsets(insets, [self sui_overlayContentInsets]);
    }
    return insets;
}

/// Warning! This is swizzled method
- (void)sui_sw_viewWillAppear:(BOOL)animated {
    // Call orginal
    [self sui_sw_viewWillAppear:animated];
    
    [self sui_updateUnclampedContentInsetsForChildrenIfNeccessary];
}

/// Warning! This is swizzled method
- (void)sui_sw_viewDidAppear:(BOOL)animated {
    // Call orginal
    [self sui_sw_viewDidAppear:animated];
    
    UIScrollView *scrollView = [self sui_contentScrollView];
    if (scrollView != nil && ![scrollView sui_isKindOfSystemClass] && [self sui_isContentScrollViewObservable]) {
        scrollView.sui_shouldAutomaticallyFindObservers = YES;
    }
}

/// Warning! This is swizzled method
- (void)sui_sw_updateContentOverlayInsetsFromParentIfNecessary {
    // Call own unclampedContentInsets updater
    [self sui_updateUnclampedInsetsFromParentIfNecessary];
    
    // Call orginal
    [self sui_sw_updateContentOverlayInsetsFromParentIfNecessary];
}

/// Warning! This is swizzled method
- (void)sui_sw_updateContentOverlayInsetsForSelfAndChildren {
    // Call own unclampedContentInsets updater
    [self sui_updateUnclampedContentInsetsForSelfAndChildren];
    
    // Call orginal
    [self sui_sw_updateContentOverlayInsetsForSelfAndChildren];
}

#pragma mark Setters & Getters

// sui_overlayContentInsets

static void * kSUIOverlayContentInsetsKey = &kSUIOverlayContentInsetsKey;

- (void)sui_setOverlayContentInsets:(UIEdgeInsets)sui_overlayContentInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(sui_overlayContentInsets, [self sui_overlayContentInsets])) {
        return;
    }
    
    if (![self isKindOfClass:[UIPageViewController class]]) {
        // See UIPageViewController+SUI.m
        // -sui_sw_edgeInsetsForChildViewController;
        [[NSException exceptionWithName:NSGenericException
                                 reason:@"sui_overlayContentInsets currently supported only for UIPageController"
                               userInfo:nil] raise];
    }
    
    objc_setAssociatedObject(self, kSUIOverlayContentInsetsKey, [NSValue valueWithUIEdgeInsets:sui_overlayContentInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self sui_updateContentOverlayInsetsForSelfAndChildren];
}

- (UIEdgeInsets)sui_overlayContentInsets {
    NSValue *value = objc_getAssociatedObject(self, kSUIOverlayContentInsetsKey);
    return value == nil ? UIEdgeInsetsZero : [value UIEdgeInsetsValue];
}

// sui_unclampedContentInsets

static void * kSUIUnclampedContentInsetsKey = &kSUIUnclampedContentInsetsKey;

- (void)sui_setUnclampedContentInsets:(SUIUnclampedInsets)sui_unclampedContentInsets {
    if (SUIUnclampedInsetsEqualToUnclampedInsets(sui_unclampedContentInsets, [self sui_unclampedContentInsets])) {
        return;
    }
    
    objc_setAssociatedObject(self, kSUIUnclampedContentInsetsKey, [NSValue valueWithSUIUnclampedInsets:sui_unclampedContentInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self sui_updateUnclampedContentInsetsForSelfAndChildren];
    
    if ([UIView sui_isInAnimationBlock]) {
        [self sui_updateContentOverlayInsetsFromParentIfNecessary];
        [self.viewIfLoaded layoutIfNeeded];
    }
}

- (SUIUnclampedInsets)sui_unclampedContentInsets {
    NSValue *value = objc_getAssociatedObject(self, kSUIUnclampedContentInsetsKey);
    return value == nil ? SUIUnclampedInsetsZero : [value SUIUnclampedInsetsValue];
}

// sui_isContextMenuViewController

- (BOOL)sui_isContextMenuViewController {
    NSString *className = NSStringFromClass([self class]);
    // _UIContextMenu..
    return [className containsString:SUIReversedStringWithParts(@"extMenu", @"_UICont", nil)];
}

// sui_contentScrollView

- (UIScrollView *)sui_contentScrollView {
    // _recordedContentScrollView
    UIScrollView *recordedContentScrollView = [self valueForKey:SUIReversedStringWithParts(@"dContentScrollView", @"_recorde", nil)];
    if (recordedContentScrollView == nil) {
        // _contentScrollView
        return [self sui_performSelector:SUISelectorFromReversedStringParts(@"entScrollView", @"_cont", nil)];
    }
    return recordedContentScrollView;
}

// sui_contentScrollViewObservable

static void * kSUIContentScrollViewObservableKey = &kSUIContentScrollViewObservableKey;

- (void)sui_setIsContentScrollViewObservable:(BOOL)sui_contentScrollViewObservable {
    objc_setAssociatedObject(self, kSUIContentScrollViewObservableKey, [NSNumber numberWithBool:sui_contentScrollViewObservable], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sui_isContentScrollViewObservable {
    NSNumber *value = objc_getAssociatedObject(self, kSUIContentScrollViewObservableKey);
    return value == nil ? YES : [value boolValue];
}

#pragma mark - Helpers

- (UIScrollView *)sui_nestedScrollView {
    return [self sui_nestedScrollViewWithLevel:3];
}

- (UIScrollView *)sui_nestedScrollViewWithLevel:(NSInteger)level {
    return [self sui_nestedScrollViewWithView:self.view level:level current:0];
}

- (UIScrollView *)sui_nestedScrollViewWithView:(UIView *)view level:(NSInteger)level current:(NSInteger)current {
    if (current > level) {
        return nil;
    }
    if ([view isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIView *target = [self sui_nestedScrollViewWithView:subview level:level current:current + 1];
        if ([target isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)target;
        }
    }
    return nil;
}

@end
