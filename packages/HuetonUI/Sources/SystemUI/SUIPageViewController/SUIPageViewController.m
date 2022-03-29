//
//  SUIPageViewController.m
//  
//
//  Created by Anton Spivak on 04.03.2022.
//

#import "SUIPageViewController.h"

@interface UIPageViewController (SUIPageViewController)

- (void)_flushViewController:(UIViewController *)viewControllerToFlush animated:(BOOL)animated;

@end

@interface SUIPageViewController ()

@property (nonatomic, assign, getter=isTransitionInProgress) BOOL transitionInProgress;
@property (nonatomic, strong) NSMutableArray<NSInvocation *> *setViewControllersInvocations;

@end

@implementation SUIPageViewController

// Trying ty fix crash when this method called when current transition didn't finished yet
// -[UIPageViewController _flushViewController:animated:] and etc
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
                 direction:(UIPageViewControllerNavigationDirection)direction
                  animated:(BOOL)animated
                completion:(void (^)(BOOL))completion
{
    if (self.transitionInProgress) {
        NSMethodSignature *signature = [self methodSignatureForSelector:_cmd];
        NSInvocation *setViewControllersInvocation = [NSInvocation invocationWithMethodSignature:signature];
        [setViewControllersInvocation setTarget:self];
        [setViewControllersInvocation setSelector:_cmd];
        [setViewControllersInvocation setArgument:&viewControllers atIndex:2];
        [setViewControllersInvocation setArgument:&direction atIndex:3];
        [setViewControllersInvocation setArgument:&animated atIndex:4];
        [setViewControllersInvocation setArgument:&completion atIndex:5];
        [setViewControllersInvocation retainArguments];
        
        if (self.setViewControllersInvocations == nil) {
            self.setViewControllersInvocations = [NSMutableArray new];
        }
        
        [self.setViewControllersInvocations insertObject:setViewControllersInvocation
                                                 atIndex:0];
        
        return;
    }
    
    self.transitionInProgress = YES;
    __weak typeof(self) wself = self;
    
    [super setViewControllers:viewControllers direction:direction animated:animated completion:^(BOOL finished) {
        wself.transitionInProgress = NO;
        
        if (completion != nil) {
            completion(finished);
        }
        
        NSInvocation *invocation = [wself.setViewControllersInvocations lastObject];
        if (invocation == nil) {
            return;
        }
        
        [wself.setViewControllersInvocations removeLastObject];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [invocation invoke];
        });
    }];
}

- (void)_flushViewController:(UIViewController *)viewControllerToFlush
                    animated:(BOOL)animated
{
    [self _flushViewController:viewControllerToFlush
                      animated:animated
                       attempt:0];
}

- (void)_flushViewController:(UIViewController *)viewControllerToFlush
                    animated:(BOOL)animated
                     attempt:(NSInteger)attempt
{
    @try {
        [super _flushViewController:viewControllerToFlush
                           animated:animated];
    } @catch (NSException *exception) {
        NSLog(@"SUIPageViewController: got an exception while trying to _flushViewController: %@", exception);
        
        if (attempt > 3) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _flushViewController:viewControllerToFlush
                              animated:animated
                               attempt:attempt + 1];
        });
    }
}

@end
