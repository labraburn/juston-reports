//
//  Created by Anton Spivak
//

#import "SUISheetPresentationControllerDetent.h"

#import <objc/message.h>
#import <objc/runtime.h>

static Class kSUI13SheetPresentationControllerDetentClass = nil;
static Class kSUI15SheetPresentationControllerDetentClass = nil;

const SUISheetPresentationControllerDetendIdentifier SUISheetPresentationControllerDetentIdentifierMaximum = @"com.apple.UIKit.maximum";
const SUISheetPresentationControllerDetendIdentifier SUISheetPresentationControllerDetentIdentifierLarge = @"com.apple.UIKit.large";
const SUISheetPresentationControllerDetendIdentifier SUISheetPresentationControllerDetentIdentifierMedium = @"com.apple.UIKit.medium";
const SUISheetPresentationControllerDetendIdentifier SUISheetPresentationControllerDetentIdentifierSmall = @"com.apple.UIKit.small";

@interface SUISheetPresentationControllerDetent ()

@property (nonatomic, copy) SUISheetPresentationControllerDetendIdentifier identifier;
@property (nonatomic, copy) SUISheetDetentResulutionBlock resulutionBlock;
@property (nonatomic, strong) id presentationControllerDetent;

@end

@implementation SUISheetPresentationControllerDetent

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // _UISheetDetent
        kSUI13SheetPresentationControllerDetentClass = NSClassFromString(SUIReversedStringWithParts(@"etDetent", @"_UIShe", nil));
    });
}

- (instancetype)initWithPresentationControllerDetent:(id)presentationControllerDetent
                                          identifier:(SUISheetPresentationControllerDetendIdentifier)identifier
                                     resulutionBlock:(SUISheetDetentResulutionBlock _Nullable)resulutionBlock
{
    self = [super init];
    if (self != nil) {
        _identifier = [identifier copy];
        _resulutionBlock = [resulutionBlock copy];
        _presentationControllerDetent = presentationControllerDetent;
    }
    return self;
}

+ (instancetype)detentWithIdentifier:(SUISheetPresentationControllerDetendIdentifier)identifier
                     resolutionBlock:(SUISheetDetentResulutionBlock)resolutionBlock
{
    id presentationControllerDetent = nil;
    
    if (@available(iOS 15, *)) {
        Class klass = [UISheetPresentationControllerDetent class];
        presentationControllerDetent = [[klass alloc] init];
    } else {
        presentationControllerDetent = [[kSUI13SheetPresentationControllerDetentClass alloc] init];
    }
    
    return [[SUISheetPresentationControllerDetent alloc] initWithPresentationControllerDetent:presentationControllerDetent
                                                                                   identifier:identifier
                                                                              resulutionBlock:resolutionBlock];
}

+ (instancetype)maximumDetent {
    id presentationControllerDetent = nil;
    
    if (@available(iOS 15, *)) {
        Class klass = [UISheetPresentationControllerDetent class];
        presentationControllerDetent = [[klass alloc] init];
    } else {
        presentationControllerDetent = [[kSUI13SheetPresentationControllerDetentClass alloc] init];
    }
    
    SUISheetDetentResulutionBlock resolutionBlock = ^CGFloat (UIView *containerView, CGRect frame) {
        return CGRectGetHeight(frame);
    };
    
    return [[SUISheetPresentationControllerDetent alloc] initWithPresentationControllerDetent:presentationControllerDetent
                                                                                   identifier:SUISheetPresentationControllerDetentIdentifierMaximum
                                                                              resulutionBlock:resolutionBlock];
}

+ (instancetype)largeDetent {
    id presentationControllerDetent = nil;
    
    if (@available(iOS 15, *)) {
        presentationControllerDetent = [UISheetPresentationControllerDetent largeDetent];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // _largeDetent
        SEL sel = SUISelectorFromReversedStringParts(@"geDetent", @"_lar", nil);
        presentationControllerDetent = [kSUI13SheetPresentationControllerDetentClass performSelector:sel];
#pragma clang diagnostic pop
    }
    
    return [[SUISheetPresentationControllerDetent alloc] initWithPresentationControllerDetent:presentationControllerDetent
                                                                                   identifier:SUISheetPresentationControllerDetentIdentifierLarge
                                                                              resulutionBlock:nil];
}

+ (instancetype)mediumDetent {
    id presentationControllerDetent = nil;
    
    if (@available(iOS 15, *)) {
        presentationControllerDetent = [UISheetPresentationControllerDetent mediumDetent];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // _mediumDetent
        SEL sel = SUISelectorFromReversedStringParts(@"iumDetent", @"_med", nil);
        presentationControllerDetent = [kSUI13SheetPresentationControllerDetentClass performSelector:sel];
#pragma clang diagnostic pop
    }
    
    return [[SUISheetPresentationControllerDetent alloc] initWithPresentationControllerDetent:presentationControllerDetent
                                                                                   identifier:SUISheetPresentationControllerDetentIdentifierMedium
                                                                              resulutionBlock:nil];
}

+ (instancetype)smallDetent {
    id presentationControllerDetent = nil;
    
    if (@available(iOS 15, *)) {
        Class klass = [UISheetPresentationControllerDetent class];
        presentationControllerDetent = [[klass alloc] init];
    } else {
        presentationControllerDetent = [[kSUI13SheetPresentationControllerDetentClass alloc] init];
    }
    
    SUISheetDetentResulutionBlock resolutionBlock = ^CGFloat (UIView *containerView, CGRect frame) {
        return 121.0f;
    };
    
    return [[SUISheetPresentationControllerDetent alloc] initWithPresentationControllerDetent:presentationControllerDetent
                                                                                   identifier:SUISheetPresentationControllerDetentIdentifierSmall
                                                                              resulutionBlock:resolutionBlock];
}

#pragma mark -

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.presentationControllerDetent;
}

#pragma mark -

- (NSInteger)_identifier {
    if (@available(iOS 15, *)) {
        return self.identifier;
    } else {
        if ([self.identifier isEqualToString:SUISheetPresentationControllerDetentIdentifierSmall]) {
            return 0x3;
        } else if ([self.identifier isEqualToString:SUISheetPresentationControllerDetentIdentifierMedium]) {
            return 0x2;
        } else if ([self.identifier isEqualToString:SUISheetPresentationControllerDetentIdentifierLarge]) {
            return 0x1;
        } else if ([self.identifier isEqualToString:SUISheetPresentationControllerDetentIdentifierMaximum]) {
            return 0x0;
        } else {
            return (NSInteger)self.identifier.hash;
        }
    }
}

// Attention!
// This method called only BEFORE iOS 15
- (CGFloat)_resolvedOffsetInContainerView:(UIView *)containerView
           fullHeightFrameOfPresentedView:(CGRect)fullHeightFrameOfPresentedView
                           bottomAttached:(BOOL)bottomAttached
{
    if (self.resulutionBlock == nil) {
        return [self.presentationControllerDetent _resolvedOffsetInContainerView:containerView
                                                  fullHeightFrameOfPresentedView:fullHeightFrameOfPresentedView
                                                                  bottomAttached:bottomAttached];
    } else {
        // Reversed BEFORE iOS 15
        CGFloat value = self.resulutionBlock(containerView, fullHeightFrameOfPresentedView) + containerView.safeAreaInsets.bottom;
        return MAX((fullHeightFrameOfPresentedView.size.height - value) + fullHeightFrameOfPresentedView.origin.y, fullHeightFrameOfPresentedView.origin.y);
    }
}

// Attention!
// This method called only AFTER iOS 15 and BEFORE iOS 16
- (CGFloat)_valueInContainerView:(UIView *)containerView
               resolutionContext:(id)resolutionContext
{
    if (self.resulutionBlock == nil) {
        return [self.presentationControllerDetent _valueInContainerView:containerView
                                                      resolutionContext:resolutionContext];
    } else {
        typedef CGRect (*function)(id, SEL);
        function block = (function)SUI_OBJC_MSG_SEND_STRET;
        CGRect frame = block(resolutionContext, SUISelectorFromReversedStringParts(@"ransformedFrame", @"_fullHeightUnt", nil));
        return self.resulutionBlock(containerView, frame);
    }
}

// Attention!
// This method called only AFTER iOS 16
- (CGFloat)resolvedValueInContext:(id)context API_AVAILABLE(ios(16.0)) {
    if (self.resulutionBlock == nil) {
        return [self.presentationControllerDetent resolvedValueInContext:context];
    } else {
        typedef CGRect (*fullHeightUntransformedFrameFunction)(id, SEL);
        fullHeightUntransformedFrameFunction fullHeightUntransformedFrame = (fullHeightUntransformedFrameFunction)SUI_OBJC_MSG_SEND_STRET;
        CGRect frame = fullHeightUntransformedFrame(context, SUISelectorFromReversedStringParts(@"ransformedFrame", @"_fullHeightUnt", nil));
        
        typedef UIView *(*containerViewFunction)(id, SEL);
        containerViewFunction containerView = (containerViewFunction)objc_msgSend;
        UIView *view = containerView(context, SUISelectorFromReversedStringParts(@"erView", @"_contain", nil));
        
        return self.resulutionBlock(view, frame);
    }
}

@end
