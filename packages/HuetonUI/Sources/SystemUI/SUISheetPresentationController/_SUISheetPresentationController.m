//
//  _SUISheetPresentationController.m
//  
//
//  Created by Anton Spivak on 09.02.2022.
//

#import "_SUISheetPresentationController.h"

#import "SUISheetPresentationController.h"
#import "SUI15SheetPresentationController.h"
#import "SUI13SheetPresentationController.h"

@interface _SUISheetPresentationController ()

@property (nonatomic, strong) id presentationController;

@end

@implementation _SUISheetPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
{
    if (@available(iOS 15, *)) {
        _presentationController = [[SUI15SheetPresentationController alloc] initWithPresentedViewController:presentedViewController
                                                                                   presentingViewController:presentingViewController];
    } else if (@available(iOS 13, *)) {
        _presentationController = [SUI13SheetPresentationController presentationControllerWithPresentedViewController:presentedViewController
                                                                                             presentingViewController:presentingViewController];
    } else {
        NSAssert(NO, @"SUISheetPresentationController available only for iOS 13 and upper.");
    }
    
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [self.presentationController methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.presentationController];
}

- (BOOL)isKindOfClass:(Class)aClass
{
    if (aClass == [SUISheetPresentationController class]) {
        return YES;
    }
    
    return [self.presentationController isKindOfClass:aClass];
}

@end
