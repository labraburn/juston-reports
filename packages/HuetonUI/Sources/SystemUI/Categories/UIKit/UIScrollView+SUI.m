//
//  Created by Anton Spivak
//

#import "UIScrollView+SUI.h"
#import "UIResponder+SUI.h"
#import "UIEdgeInsets+SUI.h"
#import "UIView+SUI.h"

#import "../../SUIGeometry.h"
#import "../Foundation/NSObject+SUI.h"

#import <objc/runtime.h>

@implementation UIScrollView (SUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SUISwizzleInstanceMethodOfClass(self, NSSelectorFromString(@"didMoveToWindow:"), @selector(sui_didMoveToWindow:));
        SUISwizzleInstanceMethodOfClass(self, NSSelectorFromString(@"setContentOffset:"), @selector(sui_sw_setContentOffset:));
        SUISwizzleInstanceMethodOfClass(self, NSSelectorFromString(@"_scrollViewWillEndDraggingWithDeceleration:"), @selector(sui_sw_scrollViewWillEndDraggingWithDeceleration:));
        SUISwizzleInstanceMethodOfClass(self, NSSelectorFromString(@"_stopScrollDecelerationNotify:"), @selector(sui_sw_stopScrollDecelerationNotify:));
        SUISwizzleInstanceMethodOfClass(self, NSSelectorFromString(@"_scrollViewAnimationEnded:finished:"), @selector(sui_sw_scrollViewAnimationEnded:finished:));
        SUISwizzleInstanceMethodOfClass(self, NSSelectorFromString(@"_effectiveVerticalScrollIndicatorInsets"), @selector(sui_sw_effectiveVerticalScrollIndicatorInsets));
        
        if (@available(iOS 15, *)) {
            SUISwizzleInstanceMethodOfClass(self, NSSelectorFromString(@"_adjustedContentOffsetForContentOffset:skipsAdjustmentIfScrolling:"), @selector(sui_sw_adjustedContentOffsetForContentOffset:skipsAdjustmentIfScrolling:));
        } else {
            SUISwizzleInstanceMethodOfClass(self, NSSelectorFromString(@"_adjustedContentOffsetForContentOffset:"), @selector(sui_sw_adjustedContentOffsetForContentOffset:));
        }
    });
}

- (void)sui_updateScrollViewObserversIfNeeded {
    [self sui_updateScrollViewObserversIfNeededWithResponder:self.nextResponder];
}

- (void)sui_updateScrollViewObserversIfNeededWithResponder:(UIResponder *)responder {
    if (responder == nil || ![self sui_shouldAutomaticallyFindObservers]) {
        return;
    }
    
    id observer = [responder sui_scrollViewObserverForScrollView:self];
    if (observer != nil && ![[self sui_observers] containsObject:observer]) {
        [[self sui_observers] addObject:observer];
    }
    
    [self sui_updateScrollViewObserversIfNeededWithResponder:responder.nextResponder];
}

- (void)sui_adjustContentOffsetIfNecessary {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    // _adjustContentOffsetIfNecessary
    [self performSelector:SUISelectorFromReversedStringParts(@"entOffsetIfNecessary", @"_adjustCont", nil)];
#pragma clang diagnostic pop
}

- (CGPoint)sui_adjustedContentOffsetForContentOffset:(CGPoint)contentOffset withOriginalAdjustedContentOffset:(CGPoint)originalContentOffset {
    SUIUnclampedInsets unclampedContentInsets = [self sui_unclampedContentInsets];
    
    if (self.contentInsetAdjustmentBehavior == UIScrollViewContentInsetAdjustmentNever) {
        return originalContentOffset;
    }
    
    UIEdgeInsets unclampedInsets = unclampedContentInsets.insets;
    SUIFloatRange unclampedRange = unclampedContentInsets.range;
    
    if (unclampedRange.length <= 0) {
        return originalContentOffset;
    }
    
    CGPoint updated = originalContentOffset;
    CGFloat topYInset = self.safeAreaInsets.top + [self sui_refreshControlContentInsetHeight];
    
    if (unclampedInsets.top == unclampedRange.location) {
        updated.y = -topYInset;
    } else if (unclampedInsets.top == SUIFloatMaxRange(unclampedRange)) {
        if (-originalContentOffset.y >= unclampedRange.location && -originalContentOffset.y <= SUIFloatMaxRange(unclampedRange)) {
            updated.y = unclampedRange.location;
        } else {
            updated.y = originalContentOffset.y;
        }
    } else {
        updated.y = -topYInset + unclampedInsets.top;
    }
    
    return updated;
}

#pragma mark - Swizzle

/// Warning! This is swizzled method
- (void)sui_didMoveToWindow:(UIWindow *)window {
    [self sui_didMoveToWindow:window];
    if (window == nil) {
        [[self sui_observers] removeAllObjects];
    } else {
        [self sui_updateScrollViewObserversIfNeeded];
    }
}

/// Warning! This is swizzled method
- (void)sui_sw_setContentOffset:(CGPoint)contentOffset {
    const CGPoint previousContentOffset = self.contentOffset;
    [self sui_sw_setContentOffset:contentOffset];
    
    [[[self sui_observers] allObjects] enumerateObjectsUsingBlock:^(id<UISUIScrollViewObserver> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(scrollViewDidChangeContentOffset:contentOffset:previousContentOffset:)]) {
            [obj scrollViewDidChangeContentOffset:self contentOffset:self.contentOffset previousContentOffset:previousContentOffset];
        }
    }];
}

/// Warning! This is swizzled method
- (BOOL)sui_sw_scrollViewWillEndDraggingWithDeceleration:(BOOL)arg1 {
    BOOL result = [self sui_sw_scrollViewWillEndDraggingWithDeceleration:arg1];
    [[[self sui_observers] allObjects] enumerateObjectsUsingBlock:^(id<UISUIScrollViewObserver> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
            [obj scrollViewDidEndDragging:self willDecelerate:arg1];
        }
    }];
    return result;
}

/// Warning! This is swizzled method
- (void)sui_sw_stopScrollDecelerationNotify:(BOOL)arg1  {
    [self sui_sw_stopScrollDecelerationNotify:arg1];
    [[[self sui_observers] allObjects] enumerateObjectsUsingBlock:^(id<UISUIScrollViewObserver> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
            [obj scrollViewDidEndDecelerating:self];
        }
    }];
}

/// Warning! This is swizzled method
- (void)sui_sw_scrollViewAnimationEnded:(id)arg1 finished:(BOOL)arg2  {
    [self sui_sw_scrollViewAnimationEnded:arg1 finished:arg2];
    [[[self sui_observers] allObjects] enumerateObjectsUsingBlock:^(id<UISUIScrollViewObserver> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(scrollViewAnimationEnded:finished:)]) {
            [obj scrollViewAnimationEnded:self finished:arg2];
        }
    }];
}

/// Warning! This is swizzled method
- (UIEdgeInsets)sui_sw_effectiveVerticalScrollIndicatorInsets {
    UIEdgeInsets original = [self sui_sw_effectiveVerticalScrollIndicatorInsets];
    SUIUnclampedInsets unclampedInsets = [self sui_unclampedContentInsets];
    
    return UIEdgeInsetsWithAdditionalUIEdgeInsets(original, (UIEdgeInsets) {
        .top = -unclampedInsets.insets.top,
        .left = -unclampedInsets.insets.left,
        .bottom = -unclampedInsets.insets.bottom,
        .right = -unclampedInsets.insets.right,
    });
}

/// Warning! This is swizzled method
- (CGPoint)sui_sw_adjustedContentOffsetForContentOffset:(CGPoint)contentOffset API_AVAILABLE(ios(11.0)) API_DEPRECATED("", ios(11.0, 14.0)) {
    CGPoint original = [self sui_sw_adjustedContentOffsetForContentOffset:contentOffset];
    return [self sui_adjustedContentOffsetForContentOffset:contentOffset withOriginalAdjustedContentOffset:original];
}

/// Warning! This is swizzled method
/// This method called from `_adjustedContentOffsetForContentOffset:` starting from iOS 15
- (CGPoint)sui_sw_adjustedContentOffsetForContentOffset:(CGPoint)contentOffset skipsAdjustmentIfScrolling:(BOOL)flag API_AVAILABLE(ios(15.0)) {
    CGPoint original = [self sui_sw_adjustedContentOffsetForContentOffset:contentOffset skipsAdjustmentIfScrolling:flag];
    return [self sui_adjustedContentOffsetForContentOffset:contentOffset withOriginalAdjustedContentOffset:original];
}

#pragma mark - Setters & Getters

// sui_observers

static void * kSUIScrollViewObserversKey = &kSUIScrollViewObserversKey;

- (NSHashTable<id<UISUIScrollViewObserver>> *)sui_observers {
    NSHashTable *hashTable = objc_getAssociatedObject(self, kSUIScrollViewObserversKey);
    if (hashTable == nil) {
        hashTable = [NSHashTable weakObjectsHashTable];
        objc_setAssociatedObject(self, kSUIScrollViewObserversKey, hashTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return hashTable;
}

// sui_setShouldAutomaticallyFindObservers

static void *kSUIShoudlAutomaticallyFindObserversKey = &kSUIShoudlAutomaticallyFindObserversKey;

- (void)sui_setShouldAutomaticallyFindObservers:(BOOL)automaticallyFindObservers {
    objc_setAssociatedObject(self, kSUIShoudlAutomaticallyFindObserversKey, [NSNumber numberWithBool:automaticallyFindObservers], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (automaticallyFindObservers) {
        [self sui_updateScrollViewObserversIfNeeded];
    } else {
        [[self sui_observers] removeAllObjects];
    }
}

- (BOOL)sui_shouldAutomaticallyFindObservers {
    NSNumber *value = objc_getAssociatedObject(self, kSUIShoudlAutomaticallyFindObserversKey);
    return value == nil ? NO : [value boolValue];
}

// sui_contentOffsetAnimationDuration

- (void)sui_setContentOffsetAnimationDuration:(NSTimeInterval)sui_contentOffsetAnimationDuration {
    [self setValue:@(sui_contentOffsetAnimationDuration) forKey:SUIReversedStringWithParts(@"etAnimationDuration", @"_contentOffs", nil)];
}

- (NSTimeInterval)sui_contentOffsetAnimationDuration {
    NSNumber *sui_contentOffsetAnimationDuration = [self valueForKey:SUIReversedStringWithParts(@"etAnimationDuration", @"_contentOffs", nil)];
    return [sui_contentOffsetAnimationDuration doubleValue];
}

// sui_refreshControlContentInsetHeight

- (CGFloat)sui_refreshControlContentInsetHeight {
    NSNumber *sui_contentOffsetAnimationDuration = [self valueForKey:SUIReversedStringWithParts(@"ntentInsetHeight", @"_refreshControlCo", nil)];
    return [sui_contentOffsetAnimationDuration doubleValue];
}

@end
