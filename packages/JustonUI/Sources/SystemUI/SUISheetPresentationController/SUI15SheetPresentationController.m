//
//  Created by Anton Spivak
//

#import "SUI15SheetPresentationController.h"
#import "SUISheetPresentationController.h"

#import <objc/message.h>

@implementation SUI15SheetPresentationController

- (void)performAnimatedChanges:(void (NS_NOESCAPE ^)(void))changes {
    [self animateChanges:changes];
}

#pragma mark - System overrides

- (BOOL)_shouldRespectDefinesPresentationContext {
    return self.shouldRespectPresentationContext;
}

- (BOOL)shouldPresentInFullscreen {
    return !self.shouldRespectPresentationContext;
}

#pragma mark - Setters & Getters

- (void)setShouldFullscreen:(BOOL)shouldFullscreen {
    _shouldFullscreen = shouldFullscreen;
    
    typedef void (*function)(id, SEL, BOOL);
    function block = (function)objc_msgSend;
    block(self, SUISelectorFromReversedStringParts(@"tsFullScreen:", @"_setWan", nil), shouldFullscreen);
}

- (id)_parentSheetPresentationController {
    if (self.shouldRespectPresentationContext) {
        return nil;
    }
    
    struct objc_super _super = {
        .receiver = self,
        .super_class = [UISheetPresentationController class]
    };
    
    typedef id (*function)(struct objc_super *, SEL);
    function block = (function)objc_msgSendSuper;
    return block(&_super, SUISelectorFromReversedStringParts(@"entationController", @"_parentSheetPres", nil));
}

#pragma mark - SUISheetPresentationController

- (BOOL)isKindOfClass:(Class)aClass {
    if (aClass == [SUISheetPresentationController class]) {
        return YES;
    }
    
    return [super isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    if ([self class] == [SUI15SheetPresentationController class] && aClass == [SUISheetPresentationController class]) {
        return YES;
    }
    return [super isMemberOfClass:aClass];
}

- (void)invalidateDetents {
    NSArray *detents = [[self detents] copy];
    [self setDetents:@[[SUISheetPresentationControllerDetent mediumDetent]]];
    [self setDetents:detents];
}

@end
