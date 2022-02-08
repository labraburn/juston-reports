//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"
#import "../../SUIGeometry.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SUI)

/// Applied only for child view controllers via `adjustedContentInsets`
@property (nonatomic, assign, setter=sui_setOverlayContentInsets:) UIEdgeInsets sui_overlayContentInsets;

/// Applied only for child view controllers
@property (nonatomic, assign, setter=sui_setUnclampedContentInsets:) SUIUnclampedInsets sui_unclampedContentInsets;

/// Returns `YES` if view controller is context menu
@property (nonatomic, assign, readonly, getter=sui_isContextMenuViewController) BOOL sui_contextMenuViewController;

/// Defines availabiluty for automaticaly search observers for content scroll view
/// Defaults is `YES`
@property (nonatomic, assign, setter=sui_setIsContentScrollViewObservable:) BOOL sui_isContentScrollViewObservable;

/// Returns system defined `UIScrollView` as `content`
/// For example for `UITableViewController` it's will be `tableView`
- (UIScrollView * _Nullable)sui_contentScrollView;

/// Override this method and update unclamped content insets if needed
/// Can be animated
- (void)sui_updateUnclampedContentInsetsForChildrenIfNeccessary;

/// Called before apply unclamped insets
- (BOOL)sui_shouldApplyUnclampedContentInsetsToChildViewController:(UIViewController *)childViewController;

/// Called before apply unclamped insets
- (BOOL)sui_shouldApplyUnclampedContentInsetsFromParentViewController:(UIViewController *)parentViewController;

@end

NS_ASSUME_NONNULL_END
