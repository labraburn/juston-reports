//
//  Created by Anton Spivak
//

#import "UIPageViewController+SUI.h"

#import "UIEdgeInsets+SUI.h"
#import "UIViewController+SUI.h"
#import "UIView+SUI.h"

@implementation UIPageViewController (SUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // _edgeInsetsForChildViewController:insetsAreAbsolute:
        SUISwizzleInstanceMethodOfClass(self, SUISelectorFromReversedStringParts(@"ewController:insetsAreAbsolute:", @"_edgeInsetsForChildVi", nil), @selector(sui_sw_edgeInsetsForChildViewController:insetsAreAbsolute:));
        
        // queuingScrollView:didEndManualScroll:toRevealView:direction:animated:didFinish:didComplete:
        SUISwizzleInstanceMethodOfClass(self, SUISelectorFromReversedStringParts(@"ed:didFinish:didComplete:", @"Scroll:toRevealView:direction:animat", @"queuingScrollView:didEndManual", nil), @selector(sui_sw_queuingScrollView:didEndManualScroll:toRevealView:direction:animated:didFinish:didComplete:));
        
        // queuingScrollView:willManuallyScroll:toRevealView:concealView:animated:
        SUISwizzleInstanceMethodOfClass(self, SUISelectorFromReversedStringParts(@"alView:concealView:animated:", @"llView:willManuallyScroll:toReve", @"queuingScro", nil), @selector(sui_sw_queuingScrollView:willManuallyScroll:toRevealView:concealView:animated:));
    });
}

- (void)sui_queueScrollViewDidEndManualScrolling:(UIScrollView *)scrollView {}
- (void)sui_queueScrollView:(UIScrollView *)scrollView willManualScrollToViewController:(UIViewController *)toViewController {}

#pragma mark - Swizzled

// Warning! This is swizzled method.
- (UIEdgeInsets)sui_sw_edgeInsetsForChildViewController:(UIViewController *)childViewController insetsAreAbsolute:(BOOL *)insetsAreAbsolute {
    // This method directly overriden in classes from UIKitCore and super didn't called
    // System default value is _overlayContentInsets
    UIEdgeInsets insets = [self sui_sw_edgeInsetsForChildViewController:childViewController insetsAreAbsolute:insetsAreAbsolute];
    if ([childViewController sui_shouldApplyUnclampedContentInsetsFromParentViewController:childViewController]) {
        insets = UIEdgeInsetsWithAdditionalUIEdgeInsets(insets, [self sui_overlayContentInsets]);
    }
    return insets;
}

- (void)sui_sw_queuingScrollView:(UIScrollView *)scrollView
              didEndManualScroll:(BOOL)manualScroll
                    toRevealView:(id)toRevealView
                       direction:(long long)direction
                        animated:(BOOL)animated
                       didFinish:(BOOL)didFinish
                     didComplete:(BOOL)didComplete
{
    [self sui_queueScrollViewDidEndManualScrolling:scrollView];
    [self sui_sw_queuingScrollView:scrollView
                didEndManualScroll:manualScroll
                      toRevealView:toRevealView
                         direction:direction
                          animated:animated
                         didFinish:didFinish
                       didComplete:didFinish];
}

- (void)sui_sw_queuingScrollView:(UIScrollView *)scrollView
              willManuallyScroll:(BOOL)manualScroll
                    toRevealView:(UIView *)revealView
                     concealView:(UIView *)concealView
                        animated:(BOOL)animated
{
    UIViewController *revealViewController = [revealView sui_enclosingViewController];
    if (revealViewController != nil) {
        [self sui_queueScrollView:scrollView willManualScrollToViewController:revealViewController];
    }
    
    [self sui_sw_queuingScrollView:scrollView
                willManuallyScroll:manualScroll
                      toRevealView:revealView
                       concealView:concealView
                          animated:animated];
}

@end
