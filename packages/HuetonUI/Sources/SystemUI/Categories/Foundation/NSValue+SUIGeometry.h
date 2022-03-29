//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"
#import "../../SUIGeometry.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSValue (SUIGeometry)

@property(nonatomic, readonly) SUIUnclampedInsets SUIUnclampedInsetsValue;
+ (NSValue *)valueWithSUIUnclampedInsets:(SUIUnclampedInsets)insets;

@property(nonatomic, readonly) SUIFloatRange SUIFloatRangeValue;
+ (NSValue *)valueWithSUIFloatRange:(SUIFloatRange)range;

@end

NS_ASSUME_NONNULL_END
