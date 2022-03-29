//
//  UIControl+SUI.h
//  
//
//  Created by Andrew Podkovyrin on 08.02.2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (SUI)

/// Insets to extend tappable area.
/// `UIEdgeInsetsZero` is a default.
@property (nonatomic, assign) UIEdgeInsets sui_touchAreaInsets;

@end

NS_ASSUME_NONNULL_END
