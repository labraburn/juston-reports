//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SUI)

/// Insets to extend tappable area.
@property (nonatomic, assign, setter=sui_setTouchAreaInsets:) UIEdgeInsets sui_touchAreaInsets;

// Returns `YES` if code currently running in [UIView animate..] block
+ (BOOL)sui_isInAnimationBlock;

@end

NS_ASSUME_NONNULL_END
