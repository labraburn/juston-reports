//
//  Created by Anton Spivak
//

#import "../SystemUI.h"
#import "SUINavigationControllerAnimatedTransitioning.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SUINavigationViewControllerAnimatedTransitioning <UIViewControllerAnimatedTransitioning>

- (NSTimeInterval)navigationBarTransitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext;

@end

@interface SUINavigationControllerAnimatedTransitioning (Internal) <SUINavigationViewControllerAnimatedTransitioning>

/// Dummy, real method declared in `SUINavigationControllerAnimatedTransitioning.m`

@end

NS_ASSUME_NONNULL_END
