//
//  SUI15SheetPresentationController.m
//  
//
//  Created by Anton Spivak on 09.02.2022.
//

#import "SUI15SheetPresentationController.h"
#import "SUISheetPresentationController.h"

#import <objc/message.h>

@implementation SUI15SheetPresentationController

- (void)performAnimatedChanges:(void (NS_NOESCAPE ^)(void))changes
{
    [self animateChanges:changes];
}

#pragma mark - System overrides

- (void)_sheetInteraction:(id)sheetInteraction didChangeOffset:(CGPoint)offset
{
    typedef void (*function)(id, SEL, id, CGPoint);
    function block = (function)objc_msgSend;
    block(self, _cmd, sheetInteraction, offset);
    
    id delegate = self.delegate;
    id presentationController = self;
    
    if ([delegate respondsToSelector:@selector(sheetPresentationController:didChangeOffset:inContainerView:)]) {
        [delegate sheetPresentationController:presentationController didChangeOffset:offset inContainerView:self.containerView];
    }
}

- (BOOL)_shouldRespectDefinesPresentationContext
{
    return self.shouldRespectPresentationContext;
}

- (BOOL)shouldPresentInFullscreen
{
    return !self.shouldRespectPresentationContext;
}

#pragma mark - Setters & Getters

- (void)setShouldFullscreen:(BOOL)shouldFullscreen
{
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

@end
