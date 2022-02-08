//
//  UISheetPresentationControllerDetent+SUI.h
//  
//
//  Created by Anton Spivak on 03.02.2022.
//

#import <UIKit/UIKit.h>

@protocol SUISheetPresentationControllerInteractionDelegate;

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN const UISheetPresentationControllerDetentIdentifier UISheetPresentationControllerDetentIdentifierSmall API_AVAILABLE(ios(15.0)) API_UNAVAILABLE(tvos, watchos);

typedef CGFloat (^UISheetDetentResulutionBlock)(UIView *containerView);

//
// UISheetPresentationControllerDetent
//

API_AVAILABLE(ios(15.0))
API_UNAVAILABLE(tvos, watchos)
@interface UISheetPresentationControllerDetent (SUI)

+ (instancetype)detentWithIdentifier:(UISheetPresentationControllerDetentIdentifier)identifier
                     resolutionBlock:(UISheetDetentResulutionBlock)resolutionBlock;

+ (instancetype)smallDetent;

@end

//
// UISheetPresentationController
//

API_AVAILABLE(ios(15.0))
API_UNAVAILABLE(tvos, watchos)
@interface UISheetPresentationController (SUI)

@property (nonatomic, weak, nullable, setter=sui_setInteractionDelegate:) id<SUISheetPresentationControllerInteractionDelegate> sui_interactionDelegate;

- (void)sui_setWantsFullscreen:(BOOL)wantsFullscreen;

@end

NS_ASSUME_NONNULL_END
