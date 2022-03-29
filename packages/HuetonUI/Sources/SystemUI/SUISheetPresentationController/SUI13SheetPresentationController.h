//
//  SUI13SheetPresentationController.h
//  
//
//  Created by Anton Spivak on 09.02.2022.
//

#import <UIKit/UIKit.h>

@class SUISheetPresentationControllerDetent;

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos, watchos) NS_SWIFT_UI_ACTOR
@interface SUI13SheetPresentationController : NSObject

@property (nonatomic, copy) NSArray<SUISheetPresentationControllerDetent *> *detents;
@property (nonatomic, copy, nullable) NSString *selectedDetentIdentifier;
@property (nonatomic, copy, nullable) NSString *largestUndimmedDetentIdentifier;

@property (nonatomic, assign) BOOL shouldFullscreen;
@property (nonatomic, assign) BOOL shouldRespectPresentationContext;

+ (instancetype)presentationControllerWithPresentedViewController:(UIViewController *)presentedViewController
                                         presentingViewController:(UIViewController * _Nullable)presentingViewController;

@end

NS_ASSUME_NONNULL_END
