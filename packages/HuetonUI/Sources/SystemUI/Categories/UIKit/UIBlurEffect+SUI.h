//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIBlurEffect (SUI)

+ (UIBlurEffect *)effectWithRadius:(CGFloat)radius;
+ (UIBlurEffect *)effectWithRadius:(CGFloat)radius scale:(CGFloat)scale;

+ (UIBlurEffect *)effectWithTintColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
