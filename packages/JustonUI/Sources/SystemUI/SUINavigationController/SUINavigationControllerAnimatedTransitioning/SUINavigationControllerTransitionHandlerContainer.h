//
//  Created by Anton Spivak
//

#import "../SystemUI.h"
#import "SUINavigationControllerTransition.h"

SUI_EXTERN Class _Nullable kSUINavigationControllerAnimatedTransitioningClass;

NS_ASSUME_NONNULL_BEGIN

@interface SUINavigationControllerTransitionHandlerContainer : NSObject

@property (nonatomic, copy) SUINavigationControllerTransitionAnimation transitionAnimation;
@property (nonatomic, copy) SUINavigationControllerTransitionDuration transitionDuration;
@property (nonatomic, copy) SUINavigationBarTransitionDuration navigationBarTransitionDuration;

@end

NS_ASSUME_NONNULL_END
