//
//  Created by Anton Spivak
//

#import "SUINavigationController.h"

@interface UINavigationController (SUINavigationController)
- (id<UIViewControllerAnimatedTransitioning>)_cachedTransitionController;
- (id<UIViewControllerAnimatedTransitioning>)_createBuiltInTransitionControllerForOperation:(UINavigationControllerOperation)operation;
- (BOOL)_shouldUseBuiltinInteractionController;
@end

@implementation SUINavigationController

- (SUINavigationControllerAnimatedTransitioning * _Nullable)trickyAnimatedTransitioningForOperation:(UINavigationControllerOperation)operation
{
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)_createBuiltInTransitionControllerForOperation:(UINavigationControllerOperation)operation
{
    id<UIViewControllerAnimatedTransitioning> animatedTransitioning = [self trickyAnimatedTransitioningForOperation:operation];
    if (animatedTransitioning == nil) {
        return [super _createBuiltInTransitionControllerForOperation:operation];
    }
    return animatedTransitioning;
}

- (BOOL)_shouldUseBuiltinInteractionController
{
    if ([[self _cachedTransitionController] isKindOfClass:[SUINavigationControllerAnimatedTransitioning class]]) {
        return YES;
    }
    return [super _shouldUseBuiltinInteractionController];
}

@end
