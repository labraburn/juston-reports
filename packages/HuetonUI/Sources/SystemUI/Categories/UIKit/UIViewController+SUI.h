//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SUI)

/// Returns `YES` if view controller is context menu
@property (nonatomic, assign, readonly, getter=sui_isContextMenuViewController) BOOL sui_contextMenuViewController;

/// Returns system defined `UIScrollView` as `content`
/// For example for `UITableViewController` it's will be `tableView`
- (UIScrollView * _Nullable)sui_contentScrollView;

@end

NS_ASSUME_NONNULL_END
