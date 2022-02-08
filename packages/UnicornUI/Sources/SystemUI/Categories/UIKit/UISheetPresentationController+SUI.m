//
//  UISheetPresentationControllerDetent+SUI.m
//  
//
//  Created by Anton Spivak on 03.02.2022.
//

#import "UISheetPresentationController+SUI.h"
#import "../../SUI14SheetPresentationController.h"
#import "../../SystemUI.h"
#import "../../SUIWeakObjectWrapper.h"

#import <objc/runtime.h>
#import <objc/message.h>

const UISheetPresentationControllerDetentIdentifier UISheetPresentationControllerDetentIdentifierSmall = @"com.1inch.small";

//
// UISheetPresentationControllerDetent
//

@implementation UISheetPresentationControllerDetent (SUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // _valueInContainerView:resolutionContext:
        SUISwizzleInstanceMethodOfClass(self, SUISelectorFromReversedStringParts(@"rView:resolutionContext:", @"_valueInContaine", nil), @selector(sui_sw_valueInContainerView:resolutionContext:));
    });
}

+ (instancetype)detentWithIdentifier:(UISheetPresentationControllerDetentIdentifier)identifier
                     resolutionBlock:(UISheetDetentResulutionBlock)resolutionBlock
{
    SEL sel = SUISelectorFromReversedStringParts(@"ntWithIdentifier:constant:", @"_dete", nil);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    UISheetPresentationControllerDetent *detend = [self performSelector:sel withObject:identifier withObject:@(60)];
#pragma clang diagnostic pop
    [detend sui_setResulutionBlock:resolutionBlock];
    return detend;
}

+ (instancetype)smallDetent {
    return [self detentWithIdentifier:UISheetPresentationControllerDetentIdentifierSmall
                      resolutionBlock:^CGFloat(UIView * _Nonnull containerView) {
        return 121;
    }];
}

#pragma mark - Swizzle

/// Warning! This is swizzled method
- (CGFloat)sui_sw_valueInContainerView:(UIView *)containerView resolutionContext:(id)resolutionContext {
    if ([self sui_resolutionBlock] == nil) {
        return [self sui_sw_valueInContainerView:containerView resolutionContext:resolutionContext];
    } else {
        return [self sui_resolutionBlock](containerView);
    }
}

#pragma mark - Setters & Getters

// sui_resolutionBlock

static void * kSUIResolutionBlockKey = &kSUIResolutionBlockKey;

- (void)sui_setResulutionBlock:(UISheetDetentResulutionBlock)sui_resolutionBlock {
    objc_setAssociatedObject(self, kSUIResolutionBlockKey, [sui_resolutionBlock copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UISheetDetentResulutionBlock _Nullable)sui_resolutionBlock {
    return objc_getAssociatedObject(self, kSUIResolutionBlockKey);
}

@end

//
// UISheetPresentationController
//

@implementation UISheetPresentationController (SUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // _sheetInteraction:didChangeOffset:
        SUISwizzleInstanceMethodOfClass(self, SUISelectorFromReversedStringParts(@"action:didChangeOffset:", @"sheetInter", nil), @selector(sui_sw_sheetInteraction:didChangeOffset:));
    });
}

#pragma mark - Swizzle

/// Warning! This is swizzled method
- (void)sui_sw_sheetInteraction:(id)sheetInteraction didChangeOffset:(CGPoint)offset {
    [self sui_sw_sheetInteraction:sheetInteraction didChangeOffset:offset];
    
    if ([self.sui_interactionDelegate respondsToSelector:@selector(sheetPresentationController:didChangeOffset:inContainerView:)]) {
        [self.sui_interactionDelegate sheetPresentationController:self didChangeOffset:offset inContainerView:self.containerView];
    }
}

#pragma mark - Setters & Getters

// wantsFullscreen

- (void)sui_setWantsFullscreen:(BOOL)wantsFullscreen {
    typedef void (*func)(id, SEL, BOOL);
    func call = (func)objc_msgSend;
    call(self, SUISelectorFromReversedStringParts(@"tsFullScreen:", @"_setWan", nil), wantsFullscreen);
}

// sui_interactionDelegate

static void * kSUIInteractionDelegateKey = &kSUIInteractionDelegateKey;

- (id<SUISheetPresentationControllerInteractionDelegate>)sui_interactionDelegate {
    SUIWeakObjectWrapper *wrapper = objc_getAssociatedObject(self, kSUIInteractionDelegateKey);
    return [wrapper wrappedObject];
}

- (void)sui_setInteractionDelegate:(id<SUISheetPresentationControllerInteractionDelegate>)sui_interactionDelegate {
    SUIWeakObjectWrapper *wrapper = [[SUIWeakObjectWrapper alloc] init];
    wrapper.wrappedObject = sui_interactionDelegate;
    objc_setAssociatedObject(self, kSUIInteractionDelegateKey, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
