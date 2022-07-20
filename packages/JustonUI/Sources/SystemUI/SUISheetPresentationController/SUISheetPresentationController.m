//
//  Created by Anton Spivak
//

#import "SUISheetPresentationController.h"

#import "SUI15SheetPresentationController.h"
#import "SUI13SheetPresentationController.h"

@import ObjectiveC.runtime;
@import Objective42;

@implementation SUISheetPresentationController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
{
    if (@available(iOS 15, *)) {
        self = (id)[[SUI15SheetPresentationController alloc] initWithPresentedViewController:presentedViewController
                                                                    presentingViewController:presentingViewController];
    } else if (@available(iOS 13, *)) {
        self = (id)[[SUI13SheetPresentationController alloc] initWithPresentedViewController:presentedViewController
                                                                    presentingViewController:presentingViewController];
    } else {
        [NSException o42_raiseExceptionWithName:NSGenericException
                                         reason:@"SUISheetPresentationController only available from iOS 13."
                                       userInfo:nil];
    }
    return self;
}
#pragma clang diagnostic pop

/// Implemented in:
/// - `SUI13SheetPresentationController`
/// - `SUI15SheetPresentationController`
- (void)performAnimatedChanges:(void (NS_NOESCAPE ^)(void))changes {}

/// Implemented in:
/// - `SUI13SheetPresentationController`
/// - `SUI15SheetPresentationController`
- (void)invalidateDetents {}

@end
