//
//  SUISheetPresentationController.m
//  
//
//  Created by Anton Spivak on 09.02.2022.
//

#import "SUISheetPresentationController.h"
#import "_SUISheetPresentationController.h"

@implementation SUISheetPresentationController

@dynamic delegate;

+ (SUISheetPresentationController *)withPresentedViewController:(UIViewController *)presentedViewController
                                       presentingViewController:(UIViewController *)presentingViewController
{
    id presentationController = [[_SUISheetPresentationController alloc] initWithPresentedViewController:presentedViewController
                                                                                presentingViewController:presentingViewController];
    return presentationController;
}

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
{
    NSAssert(NO, @"Direct initializaton of SUISheetPresentationController not allowed.");
    return nil;
}

- (instancetype)init
{
    NSAssert(NO, @"Direct initializaton of SUISheetPresentationController not allowed.");
    return nil;
}

// ATTENTION! WARNING! ALARM!
//
// All methods should be implemented at both
//
// SUI13SheetPresentationController
// SUI15SheetPresentationController

- (void)performAnimatedChanges:(void (NS_NOESCAPE ^)(void))changes {}

@end
