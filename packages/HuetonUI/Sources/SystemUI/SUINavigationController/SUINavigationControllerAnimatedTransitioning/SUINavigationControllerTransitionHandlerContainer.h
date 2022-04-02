//
//  Created by Anton Spivak
//

#import "../SystemUI.h"
#import "SUINavigationControllerTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface SUINavigationControllerTransitionHandlerContainer : NSObject

@property (nonatomic, copy) SUINavigationControllerTransitionAnimation transitionAnimation;
@property (nonatomic, copy) SUINavigationControllerTransitionDuration transitionDuration;

@end

NS_ASSUME_NONNULL_END
