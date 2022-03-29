//
//  SUISheetPresentationControllerDetent.h
//  
//
//  Created by Anton Spivak on 09.02.2022.
//

#import "../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *SUISheetPresentationControllerDetendIdentifier NS_TYPED_EXTENSIBLE_ENUM
API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos, watchos);

UIKIT_EXTERN const SUISheetPresentationControllerDetendIdentifier SUISheetPresentationControllerDetentIdentifierMaximum
API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos, watchos);

UIKIT_EXTERN const SUISheetPresentationControllerDetendIdentifier SUISheetPresentationControllerDetentIdentifierLarge
API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos, watchos);

UIKIT_EXTERN const SUISheetPresentationControllerDetendIdentifier SUISheetPresentationControllerDetentIdentifierMedium
API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos, watchos);

UIKIT_EXTERN const SUISheetPresentationControllerDetendIdentifier SUISheetPresentationControllerDetentIdentifierSmall
API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos, watchos);

typedef CGFloat (^SUISheetDetentResulutionBlock)(UIView *containerView, CGRect maximumPresentedRect);

API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos, watchos) NS_SWIFT_UI_ACTOR
@interface SUISheetPresentationControllerDetent : NSObject

+ (instancetype)detentWithIdentifier:(SUISheetPresentationControllerDetendIdentifier)identifier
                     resolutionBlock:(SUISheetDetentResulutionBlock)resolutionBlock;

+ (instancetype)maximumDetent;
+ (instancetype)largeDetent;
+ (instancetype)mediumDetent;
+ (instancetype)smallDetent;

@end

NS_ASSUME_NONNULL_END
