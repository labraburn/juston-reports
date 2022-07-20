//
//  Created by Anton Spivak
//

#import "SUINavigationController.h"

#import "SUINavigationControllerAnimatedTransitioning/SUINavigationControllerTransitionHandlerContainer.h"
#import "SUINavigationControllerAnimatedTransitioning/SUINavigationViewControllerAnimatedTransitioning.h"

@interface UINavigationController (SUINavigationController)
- (id<UIViewControllerAnimatedTransitioning>)_transitionController;
- (id<UIViewControllerAnimatedTransitioning>)_createBuiltInTransitionControllerForOperation:(UINavigationControllerOperation)operation;
- (NSTimeInterval)_customNavigationTransitionDuration;
- (BOOL)_shouldUseBuiltinInteractionController;
@end

@implementation SUINavigationController

- (SUINavigationControllerAnimatedTransitioning * _Nullable)trickyAnimatedTransitioningForOperation:(UINavigationControllerOperation)operation
{
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)_transitionController {
    return [super _transitionController];
}

- (id<UIViewControllerAnimatedTransitioning>)_createBuiltInTransitionControllerForOperation:(UINavigationControllerOperation)operation
{
    id<UIViewControllerAnimatedTransitioning> animatedTransitioning = [self trickyAnimatedTransitioningForOperation:operation];
    if (animatedTransitioning == nil) {
        return [super _createBuiltInTransitionControllerForOperation:operation];
    }
    return animatedTransitioning;
}

- (NSTimeInterval)_customNavigationTransitionDuration {
    SEL sel = @selector(transitionContext);
    
    BOOL isTrickyAnimated = [[self _transitionController] isKindOfClass:kSUINavigationControllerAnimatedTransitioningClass];
    BOOL isTransitionContextPresented = [[self _transitionController] respondsToSelector:sel];
    
    if (isTrickyAnimated && isTransitionContextPresented) {
        id<SUINavigationViewControllerAnimatedTransitioning> transitionController = (id)[self _transitionController];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id<UIViewControllerContextTransitioning> context = [transitionController performSelector:sel];
#pragma clang diagnostic pop
        return [transitionController navigationBarTransitionDuration:context];
    }
    
    return [super _customNavigationTransitionDuration];
}

- (BOOL)_shouldUseBuiltinInteractionController
{
    if ([[self _transitionController] isKindOfClass:kSUINavigationControllerAnimatedTransitioningClass]) {
        return YES;
    }
    return [super _shouldUseBuiltinInteractionController];
}

@end
