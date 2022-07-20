//
//  Created by Anton Spivak
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SUINavigationControllerTransitionAnimation)(id<UIViewControllerContextTransitioning> transitionContext);
typedef NSTimeInterval (^SUINavigationBarTransitionDuration)(id<UIViewControllerContextTransitioning> transitionContext);
typedef NSTimeInterval (^SUINavigationControllerTransitionDuration)(id<UIViewControllerContextTransitioning> transitionContext);

NS_ASSUME_NONNULL_END
