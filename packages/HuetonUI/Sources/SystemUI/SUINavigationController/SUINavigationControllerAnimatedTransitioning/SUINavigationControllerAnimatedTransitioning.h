//
//  Created by Anton Spivak
//

#import "../SystemUI.h"
#import "SUINavigationControllerTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface SUINavigationControllerAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

- (instancetype)initWithNavigationOperation:(UINavigationControllerOperation)navigationOperation
                         transitionDuration:(SUINavigationControllerTransitionDuration)transitionDuration
                        transitionAnimation:(SUINavigationControllerTransitionAnimation)transitionAnimation;

@end

NS_ASSUME_NONNULL_END
