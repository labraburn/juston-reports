//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIPageViewController (SUI)

/// Called when user did complete scrolling in `queueScrollView`
- (void)sui_queueScrollViewDidEndManualScrolling:(UIScrollView *)scrollView;

/// Called when new view controller will appear
- (void)sui_queueScrollView:(UIScrollView *)scrollView willManualScrollToViewController:(UIViewController *)toViewController;

@end

NS_ASSUME_NONNULL_END
