//
//  SUISheetPresentationController.h
//  
//
//  Created by Anton Spivak on 09.02.2022.
//

#import "../SystemUI.h"
#import "SUISheetPresentationControllerDetent.h"

@class SUISheetPresentationController;

NS_ASSUME_NONNULL_BEGIN

@protocol SUISheetPresentationControllerDelegate <UIAdaptivePresentationControllerDelegate>

@optional
- (void)sheetPresentationController:(SUISheetPresentationController *)presentationController
                    didChangeOffset:(CGPoint)offset
                    inContainerView:(UIView *)containerView;

@end

//
// SUISheetPresentationController
//

@interface SUISheetPresentationController : UIPresentationController

// The delegate inherited from UIPresentationController, redeclared with conformance to UISheetPresentationControllerDelegate.
@property (nonatomic, weak, nullable) id<SUISheetPresentationControllerDelegate> delegate;

// The array of detents that the sheet may rest at.
// This array must have at least one element.
// Detents must be specified in order from smallest to largest height.
// Default: an array of only [UISheetPresentationControllerDetent largeDetent]
@property (nonatomic, copy) NSArray<SUISheetPresentationControllerDetent *> *detents;

// The identifier of the selected detent. When nil or the identifier is not found in detents, the sheet is displayed at the smallest detent.
// Default: nil
@property (nonatomic, copy, nullable) SUISheetPresentationControllerDetendIdentifier selectedDetentIdentifier;

// The identifier of the largest detent that is not dimmed. When nil or the identifier is not found in detents, all detents are dimmed.
// Default: nil
@property (nonatomic, copy, nullable) SUISheetPresentationControllerDetendIdentifier largestUndimmedDetentIdentifier;

// If set to YES will be expanded to fullscreen
// Default: NO
@property (nonatomic, assign) BOOL shouldFullscreen;

// If set to YES will be presented inside neares UIViewController that defines presentation context
// Default: NO
@property (nonatomic, assign) BOOL shouldRespectPresentationContext;

+ (SUISheetPresentationController *)withPresentedViewController:(UIViewController *)presentedViewController
                                       presentingViewController:(nullable UIViewController *)presentingViewController;

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(nullable UIViewController *)presentingViewController NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

// To animate changing any of the above properties, set them inside a block passed to this method.
// By the time this method returns, the receiver and all adjacent sheets in the sheet stack and their subviews will have been laid out.
- (void)performAnimatedChanges:(void (NS_NOESCAPE ^)(void))changes;

@end

@interface SUISheetPresentationController (UNAVAILABLE)

// Use combination of `shouldFullscreen` and `shouldRespectPresentationContext`
@property (nonatomic, assign, readonly) BOOL shouldPresentInFullscreen NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
