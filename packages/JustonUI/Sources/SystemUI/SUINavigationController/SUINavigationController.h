//
//  Created by Anton Spivak
//

#import "../SystemUI.h"
#import "SUINavigationControllerAnimatedTransitioning/SUINavigationControllerAnimatedTransitioning.h"

NS_ASSUME_NONNULL_BEGIN

@interface SUINavigationController : UINavigationController

- (SUINavigationControllerAnimatedTransitioning * _Nullable)trickyAnimatedTransitioningForOperation:(UINavigationControllerOperation)operation;

@end

NS_ASSUME_NONNULL_END

