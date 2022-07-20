//
//  Created by Anton Spivak
//

#import "UIButton+SUI.h"

@import Objective42;
@import ObjectiveC.runtime;
@import ObjectiveC.message;

@implementation UIButton (SUI)

static void * kSUIContextMenuInteractionResetKey = &kSUIContextMenuInteractionResetKey;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SUISwizzleInstanceMethodOfClass(
            self,
            @selector(contextMenuInteraction:willEndForConfiguration:animator:),
            @selector(sui_sw_contextMenuInteraction:willEndForConfiguration:animator:)
        );
    });
}

- (void)sui_presentMenuIfPossible:(UIMenu *)menu API_AVAILABLE(ios(14.0)) API_UNAVAILABLE(watchos, tvos)
{
    [self setMenu:menu];
    
    UIContextMenuInteraction *contextMenuInteraction = [self sui_contextMenuInteraction];
    if (contextMenuInteraction.view != nil) {
        objc_setAssociatedObject(contextMenuInteraction, kSUIContextMenuInteractionResetKey, [NSObject new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self sui_triggerFirstContextMenuInteractionIfPossible];
}

- (void)sui_triggerFirstContextMenuInteractionIfPossible {
    // _presentMenuAtLocation:
    SEL _presentMenuAtLocationSEL = SUISelectorFromReversedStringParts(@"nuAtLocation:", @"_presentMe", nil);
    
    UIContextMenuInteraction *contextMenuInteraction = [self sui_contextMenuInteraction];
    if (contextMenuInteraction == nil || ![contextMenuInteraction respondsToSelector:_presentMenuAtLocationSEL]) {
        return;
    }
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    typedef void (*function)(id, SEL, CGPoint);
    function block = (function)objc_msgSend;
    block(contextMenuInteraction, _presentMenuAtLocationSEL, center);
}

- (UIContextMenuInteraction * _Nullable)sui_contextMenuInteraction {
    // _contextMenuInteraction
    SEL _contextMenuInteractionSEL = SUISelectorFromReversedStringParts(@"enuInteraction", @"_contextM", nil);
    if (![self respondsToSelector:_contextMenuInteractionSEL]) {
        return nil;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    UIContextMenuInteraction *contextMenuInteraction = (UIContextMenuInteraction *)[self performSelector:_contextMenuInteractionSEL];
#pragma clang diagnostic pop
    return contextMenuInteraction;
}

- (void)sui_sw_contextMenuInteraction:(UIContextMenuInteraction *)interaction
              willEndForConfiguration:(UIContextMenuConfiguration *)configuration
                             animator:(nullable id<UIContextMenuInteractionAnimating>)animator API_AVAILABLE(ios(14.0)) API_UNAVAILABLE(watchos, tvos)
{
    if (objc_getAssociatedObject(interaction, kSUIContextMenuInteractionResetKey) != nil) {
        __weak typeof(self) wself = self;
        [animator addCompletion:^{
            [wself setMenu:nil];
        }];
    }
    
    [self sui_sw_contextMenuInteraction:interaction
                willEndForConfiguration:configuration
                               animator:animator];
}

@end
