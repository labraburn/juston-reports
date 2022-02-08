//
//  SUI14SheetPresentationController.m
//  
//
//  Created by Anton Spivak on 03.02.2022.
//

#import "SUI14SheetPresentationController.h"
#import "SystemUI.h"

#import <objc/runtime.h>
#import <objc/message.h>

static Class kSUI14SheetPresentationControllerDetentClass = nil;
static Class kSUI14SheetPresentationControllerClass = nil;

const SUI14SheetPresentationControllerDetendIdentifier SUI14SheetPresentationControllerDetentIdentifierMedium = @"com.apple.UIKit.large";
const SUI14SheetPresentationControllerDetendIdentifier SUI14SheetPresentationControllerDetentIdentifierLarge = @"com.apple.UIKit.medium";
const SUI14SheetPresentationControllerDetendIdentifier SUI14SheetPresentationControllerDetentIdentifierSmall = @"io.1inch.small";

//
// SUI14SheetPresentationControllerDetent
//

@interface SUI14SheetPresentationControllerDetent ()

@property (nonatomic, strong) id detent;
@property (nonatomic, strong) SUI14SheetPresentationControllerDetendIdentifier identifier;
@property (nonatomic, copy, nullable) SUI14SheetDetentResulutionBlock resulutionBlock;

@end

@implementation SUI14SheetPresentationControllerDetent : NSObject

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // _UISheetDetent
        kSUI14SheetPresentationControllerDetentClass = NSClassFromString(SUIReversedStringWithParts(@"etDetent", @"_UIShe", nil));
    });
}

- (instancetype)initWithOriginalDetent:(id)detent
                            identifier:(SUI14SheetPresentationControllerDetendIdentifier)identifier
                       resulutionBlock:(SUI14SheetDetentResulutionBlock _Nullable)resulutionBlock
{
    self = [super init];
    if (self != nil) {
        _detent = detent;
        _identifier = identifier;
        _resulutionBlock = [resulutionBlock copy];
    }
    return self;
}

+ (instancetype)detentWithIdentifier:(SUI14SheetPresentationControllerDetendIdentifier)identifier
                     resolutionBlock:(SUI14SheetDetentResulutionBlock)resolutionBlock
{
    return [[self alloc] initWithOriginalDetent:[[kSUI14SheetPresentationControllerDetentClass alloc] init]
                                     identifier:SUI14SheetPresentationControllerDetentIdentifierSmall
                                resulutionBlock:resolutionBlock];
}

+ (instancetype)smallDetent {
    return [[self alloc] initWithOriginalDetent:[[kSUI14SheetPresentationControllerDetentClass alloc] init]
                                     identifier:SUI14SheetPresentationControllerDetentIdentifierSmall
                                resulutionBlock:^CGFloat(UIView * _Nonnull containerView) {
        return 121;
    }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

+ (instancetype)mediumDetent {
    SEL sel = SUISelectorFromReversedStringParts(@"iumDetent", @"_med", nil);
    return [[self alloc] initWithOriginalDetent:[kSUI14SheetPresentationControllerDetentClass performSelector:sel]
                                     identifier:SUI14SheetPresentationControllerDetentIdentifierMedium
                                resulutionBlock:nil];
}

+ (instancetype)largeDetent {
    SEL sel = SUISelectorFromReversedStringParts(@"geDetent", @"_lar", nil);
    return [[self alloc] initWithOriginalDetent:[kSUI14SheetPresentationControllerDetentClass performSelector:sel]
                                     identifier:SUI14SheetPresentationControllerDetentIdentifierLarge
                                resulutionBlock:nil];
}

#pragma clang diagnostic pop

// Here we just pretending that we are _UISheetDetent
// And just forwarding methods to original class
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.detent;
}

#pragma mark - System methods overrides

- (NSInteger)_identifier {
    if ([self.identifier isEqualToString:SUI14SheetPresentationControllerDetentIdentifierSmall]) {
        return 0x3;
    } else if ([self.identifier isEqualToString:SUI14SheetPresentationControllerDetentIdentifierMedium]) {
        return 0x2;
    } else if ([self.identifier isEqualToString:SUI14SheetPresentationControllerDetentIdentifierLarge]) {
        return 0x1;
    } else {
        return (NSInteger)self.identifier.hash;
    }
}

- (CGFloat)_resolvedOffsetInContainerView:(UIView *)containerView
           fullHeightFrameOfPresentedView:(CGRect)fullHeightFrameOfPresentedView
                           bottomAttached:(BOOL)bottomAttached
{
    if (self.resulutionBlock != nil) {
        // Reversed on iOS 14
        return (CGRectGetHeight(fullHeightFrameOfPresentedView) - self.resulutionBlock(containerView));
    } else {
        return [self.detent _resolvedOffsetInContainerView:containerView
                            fullHeightFrameOfPresentedView:fullHeightFrameOfPresentedView
                                            bottomAttached:bottomAttached];
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SUI14SheetPresentationControllerDetent *lhs = self;
    SUI14SheetPresentationControllerDetent *rhs = object;
    
    if ((lhs.resulutionBlock == nil && lhs.resulutionBlock != nil) || (lhs.resulutionBlock != nil && lhs.resulutionBlock == nil)) {
        return [lhs.identifier isEqualToString:rhs.identifier];
    } else {
        return [lhs.detent isEqual:rhs.detent];
    }
}

@end

//
// SUI14SheetPresentationController
//

@interface SUI14SheetPresentationController ()

@property (nonatomic, strong) id _presentationController;

@end

@implementation SUI14SheetPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
{
    self = [super init];
    if (self != nil) {
        __presentationController = [[kSUI14SheetPresentationControllerClass alloc] initWithPresentedViewController:presentedViewController
                                                                                          presentingViewController:presentingViewController];;
    }
    return self;
}

+ (void)load {
    if (@available(iOS 15, *)) {
        // Skip iOS 15 and upper
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // _UISheetPresentationController
        kSUI14SheetPresentationControllerClass = NSClassFromString(SUIReversedStringWithParts(@"tationController", @"_UISheetPresen", nil));
        
        // dimmingViewWasTapped
        SEL selector1 = SUISelectorFromReversedStringParts(@"ngViewWasTapped:", @"dimmi", nil);
        Method originalMethod1 = class_getInstanceMethod(self, selector1);
        Method swizzledMethod1 = class_getInstanceMethod(kSUI14SheetPresentationControllerClass, selector1);
        method_exchangeImplementations(originalMethod1, swizzledMethod1);
        
        // sheetInteraction:didChangeOffset:
        SEL selector2 = SUISelectorFromReversedStringParts(@"action:didChangeOffset:", @"sheetInter", nil);
        Method originalMethod2 = class_getInstanceMethod([self class], @selector(sui_sw_sheetInteraction:didChangeOffset:));
        Method swizzledMethod2 = class_getInstanceMethod([kSUI14SheetPresentationControllerClass class], selector2);
        method_exchangeImplementations(originalMethod2, swizzledMethod2);
    });
}

// Here we just pretending that we are _UISheetPresentationController
// And just forwarding methods to original class
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self._presentationController;
}

- (void)animateChanges:(void (^)(void))changes {
    UICubicTimingParameters *timingParameters = [[UICubicTimingParameters alloc] initWithAnimationCurve:UIViewAnimationCurveEaseOut];
    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.28
                                                                       timingParameters:timingParameters];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [animator addAnimations:^{
        changes();
        id layout = [self performSelector:SUISelectorFromReversedStringParts(@"utInfo", @"_layo", nil)];
        [layout performSelector:SUISelectorFromReversedStringParts(@"ut", @"_layo", nil)];
    }];
#pragma clang diagnostic pop
    
    [animator startAnimation];
}

#pragma mark - Setters & Getters

- (UIPresentationController *)presentationController {
    return (id)self;
}

- (void)setWantsFullscreen:(BOOL)wantsFullscreen {
    typedef void (*func)(id, SEL, BOOL);
    func call = (func)objc_msgSend;
    call(self.presentationController, SUISelectorFromReversedStringParts(@"tsFullScreen:", @"_setWan", nil), wantsFullscreen);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

/// Warning! This is swizzled method
/// Warning! This is method from another class
- (void)dimmingViewWasTapped:(UIView *)dimmingView {
    UIPresentationController *sself = (id)self;
    if ([sself.presentedViewController.presentingViewController.presentationController isKindOfClass:[self class]]) {
        // Replicate iOS 15
        return;
    } else {
        [self dimmingViewWasTapped:dimmingView];
    }
}

/// Warning! This is swizzled method
/// Warning! This is method from another class
- (NSArray<SUI14SheetPresentationControllerDetent *> *)detents {
    return [self.presentationController performSelector:SUISelectorFromReversedStringParts(@"nts", @"_dete", nil)];
}

/// Warning! This is swizzled method
/// Warning! This is method from another class
- (void)setDetents:(NSArray<SUI14SheetPresentationControllerDetent *> *)detents {
    [self.presentationController performSelector:SUISelectorFromReversedStringParts(@"nts:", @"_setDete", nil) withObject:detents];
}

/// Warning! This is swizzled method
/// Warning! This is method from another class
- (SUI14SheetPresentationControllerDetendIdentifier)selectedDetentIdentifier {
    NSInteger index = [[self.presentationController performSelector:SUISelectorFromReversedStringParts(@"rrentDetent", @"_indexOfCu", nil)] integerValue];
    if (index == NSNotFound) {
        return nil;
    }
    return self.detents[index].identifier;
}

/// Warning! This is swizzled method
/// Warning! This is method from another class
- (void)setSelectedDetentIdentifier:(SUI14SheetPresentationControllerDetendIdentifier)selectedDetentIdentifier {
    NSInteger index = [[self detents] indexOfObjectPassingTest:^BOOL(SUI14SheetPresentationControllerDetent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.identifier isEqualToString:selectedDetentIdentifier];
    }];
    
    typedef void (*func)(id, SEL, NSInteger);
    func call = (func)objc_msgSend;
    call(self.presentationController, SUISelectorFromReversedStringParts(@"xOfCurrentDetent:", @"_setInde", nil), index);
}

/// Warning! This is swizzled method
/// Warning! This is method from another class
- (SUI14SheetPresentationControllerDetendIdentifier)largestUndimmedDetentIdentifier {
    NSInteger index = [[self.presentationController performSelector:SUISelectorFromReversedStringParts(@"tUndimmedDetent", @"_indexOfLas", nil)] integerValue];
    if (index == NSNotFound) {
        return nil;
    }
    return self.detents[index].identifier;
}

/// Warning! This is swizzled method
/// Warning! This is method from another class
- (void)setLargestUndimmedDetentIdentifier:(SUI14SheetPresentationControllerDetendIdentifier)largestUndimmedDetentIdentifier {
    NSInteger index = [[self detents] indexOfObjectPassingTest:^BOOL(SUI14SheetPresentationControllerDetent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.identifier isEqualToString:largestUndimmedDetentIdentifier];
    }];
    
    typedef void (*func)(id, SEL, NSInteger);
    func call = (func)objc_msgSend;
    call(self.presentationController, SUISelectorFromReversedStringParts(@"astUndimmedDetent:", @"_setIndexOfL", nil), index);
}

#pragma mark - Swizzle

/// Warning! This is swizzled method
- (void)sui_sw_sheetInteraction:(id)sheetInteraction didChangeOffset:(CGPoint)offset {
    SEL sel = @selector(sui_sw_sheetInteraction:didChangeOffset:);
    IMP imp = [SUI14SheetPresentationController instanceMethodForSelector:sel];
    void (*func)(id, SEL, id, CGPoint) = (void *)imp;
    func(self, SUISelectorFromReversedStringParts(@"ction:didChangeOffset:", @"sheetIntera", nil), sheetInteraction, offset);
    
    
    UIPresentationController *sself = (id)self;
    SUI14SheetPresentationController *rself = (id)[[sself presentedViewController] presentationController];
    
    if ([rself.interactionDelegate respondsToSelector:@selector(sheetPresentationController:didChangeOffset:inContainerView:)]) {
        [rself.interactionDelegate sheetPresentationController:sself didChangeOffset:offset inContainerView:sself.containerView];
    }
}

#pragma clang diagnostic pop

@end
