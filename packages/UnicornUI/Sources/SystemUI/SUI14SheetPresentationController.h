//
//  SUI14SheetPresentationController.h
//  
//
//  Created by Anton Spivak on 03.02.2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *SUI14SheetPresentationControllerDetendIdentifier NS_TYPED_EXTENSIBLE_ENUM API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos, watchos);

UIKIT_EXTERN const SUI14SheetPresentationControllerDetendIdentifier SUI14SheetPresentationControllerDetentIdentifierMedium API_DEPRECATED("Use UISheetPresentationController", ios(13.0, 14.0)) API_UNAVAILABLE(tvos, watchos);

UIKIT_EXTERN const SUI14SheetPresentationControllerDetendIdentifier SUI14SheetPresentationControllerDetentIdentifierLarge API_DEPRECATED("Use UISheetPresentationController", ios(13.0, 14.0)) API_UNAVAILABLE(tvos, watchos);

UIKIT_EXTERN const SUI14SheetPresentationControllerDetendIdentifier SUI14SheetPresentationControllerDetentIdentifierSmall API_DEPRECATED("Use UISheetPresentationController", ios(13.0, 14.0)) API_UNAVAILABLE(tvos, watchos);

typedef CGFloat (^SUI14SheetDetentResulutionBlock)(UIView *containerView);

@protocol SUISheetPresentationControllerInteractionDelegate <NSObject>

@optional
- (void)sheetPresentationController:(UIPresentationController *)presentationController
                    didChangeOffset:(CGPoint)offset
                    inContainerView:(UIView *)containerView;

@end

//
// SUI14SheetPresentationControllerDetent
//

UIKIT_EXTERN API_DEPRECATED_WITH_REPLACEMENT("UISheetPresentationControllerDetend", ios(13.0, 14.0)) API_UNAVAILABLE(tvos, watchos) NS_SWIFT_UI_ACTOR
@interface SUI14SheetPresentationControllerDetent : NSObject

+ (instancetype)detentWithIdentifier:(SUI14SheetPresentationControllerDetendIdentifier)identifier
                     resolutionBlock:(SUI14SheetDetentResulutionBlock)resolutionBlock;

+ (instancetype)smallDetent;
+ (instancetype)mediumDetent;
+ (instancetype)largeDetent;

@end

//
// SUI14SheetPresentationController
//

API_DEPRECATED_WITH_REPLACEMENT("UISheetPresentationController", ios(13.0, 14.0))
@interface SUI14SheetPresentationController : NSObject

@property (nonatomic, copy) NSArray<SUI14SheetPresentationControllerDetent *> * detents;

@property (nonatomic, strong, nullable) SUI14SheetPresentationControllerDetendIdentifier selectedDetentIdentifier;
@property (nonatomic, strong, nullable) SUI14SheetPresentationControllerDetendIdentifier largestUndimmedDetentIdentifier;

@property (nonatomic, weak, nullable) id<SUISheetPresentationControllerInteractionDelegate> interactionDelegate;

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController * _Nullable)presentingViewController;

- (void)setWantsFullscreen:(BOOL)wantsFullscreen;
- (void)animateChanges:(void(^)(void))changes;
- (UIPresentationController *)presentationController;

@end

NS_ASSUME_NONNULL_END
