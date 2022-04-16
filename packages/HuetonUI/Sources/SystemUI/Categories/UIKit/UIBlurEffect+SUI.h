//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIBlurEffect (SUI)

+ (UIBlurEffect *)effectWithRadius:(CGFloat)radius;
+ (UIBlurEffect *)effectWithRadius:(CGFloat)radius scale:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
