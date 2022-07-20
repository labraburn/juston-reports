//
//  Created by Anton Spivak
//

#import "SUISheetLayoutInfo.h"
#import "SUISheetPresentationControllerDetent.h"

@import ObjectiveC.runtime;
@import Objective42;

@interface SUISheetPresentationControllerDetent (SUISheetLayoutInfo)

@property (nonatomic, copy) SUISheetPresentationControllerDetendIdentifier identifier;

@end

@implementation SUISheetLayoutInfo

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // _UISheetDetent
        
        if (@available(iOS 15, *)) {} else {
            return;
        }
        
        Class klass = NSClassFromString(@"_UISheetLayoutInfo");
        
        Method originalMethod = class_getInstanceMethod(self, @selector(_fullHeightUntransformedFrame));
        Method swizzledMethod = class_getInstanceMethod(klass, @selector(_fullHeightUntransformedFrame));

        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

/// - warning self is `_UISheetLayoutInfo` class
- (CGRect)_fullHeightUntransformedFrame {
    IMP imp = [SUISheetLayoutInfo instanceMethodForSelector:_cmd];
    typedef CGRect (*function)(id, SEL);
    function block = (function)imp;
    CGRect frame = block(self, _cmd);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSArray<SUISheetPresentationControllerDetent *> *detens = (id)[self performSelector:SUISelectorFromReversedStringParts(@"ents", @"_det", nil)];
#pragma clang diagnostic pop
    
    NSUInteger index = [detens indexOfObjectPassingTest:^BOOL(SUISheetPresentationControllerDetent *obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[SUISheetPresentationControllerDetent class]]) {
            return NO;
        }
        
        return [obj.identifier isEqualToString:SUISheetPresentationControllerDetentIdentifierMaximum];
    }];
    
    if (index == NSNotFound) {
        return frame;
    }
    
    frame.size.height += frame.origin.y;
    frame.origin.y = 0.0001; // Little bit of magic
    
    return frame;
}

@end
