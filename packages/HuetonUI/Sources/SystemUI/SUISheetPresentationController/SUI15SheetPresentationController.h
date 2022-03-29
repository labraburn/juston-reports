//
//  SUI15SheetPresentationController.h
//  
//
//  Created by Anton Spivak on 09.02.2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(15.0)) API_UNAVAILABLE(tvos, watchos) NS_SWIFT_UI_ACTOR
@interface SUI15SheetPresentationController : UISheetPresentationController

@property (nonatomic, assign) BOOL shouldFullscreen;
@property (nonatomic, assign) BOOL shouldRespectPresentationContext;

@end

NS_ASSUME_NONNULL_END
