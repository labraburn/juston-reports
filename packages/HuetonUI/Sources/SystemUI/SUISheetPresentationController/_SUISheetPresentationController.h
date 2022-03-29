//
//  _SUISheetPresentationController.h
//  
//
//  Created by Anton Spivak on 09.02.2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _SUISheetPresentationController : NSProxy

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController * _Nullable)presentingViewController;

@end

NS_ASSUME_NONNULL_END
