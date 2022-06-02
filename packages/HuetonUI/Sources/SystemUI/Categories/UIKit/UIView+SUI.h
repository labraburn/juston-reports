//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"
#import "../../SUIGeometry.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SUI)

/// Overrides gesture recognizer hierarchy like `nextResponder` for simple touches
@property (nonatomic, strong, nullable, setter=sui_setOverridenGestureRecognizersParent:) UIView *sui_overridenGestureRecognizersParent;

/// Applied for self and childs in enclosing view controller
@property (nonatomic, assign, setter=sui_setUnclampedContentInsets:) SUIUnclampedInsets sui_unclampedContentInsets;

/// Returns view controller for which `self` is root view
@property (nonatomic, strong, readonly, nullable) UIViewController *sui_enclosingViewController;

/// Insets to extend tappable area.
@property (nonatomic, assign, setter=sui_setTouchAreaInsets:) UIEdgeInsets sui_touchAreaInsets;

// Returns `YES` if code currently running in [UIView animate..] block
+ (BOOL)sui_isInAnimationBlock;

// Called when unclamped insets did change
- (void)sui_unclampedContentInsetsDidChange;

// Set decrease `safeAreaInsets` with current unclamped insets
- (void)sui_setExcludesUnclampedInsets:(BOOL)excludesUnclampedInsets;

@end

NS_ASSUME_NONNULL_END
