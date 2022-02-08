//
//  Created by Anton Spivak
//

#import "NSValue+SUIGeometry.h"

@implementation NSValue (SUIGeometry)

+ (NSValue *)valueWithSUIUnclampedInsets:(SUIUnclampedInsets)insets {
    return [NSValue value:&insets withObjCType:@encode(SUIUnclampedInsets)];
}

- (SUIUnclampedInsets)SUIUnclampedInsetsValue {
    SUIUnclampedInsets value;
    [self getValue:&value];
    return value;
}

+ (NSValue *)valueWithSUIFloatRange:(SUIFloatRange)range {
    return [NSValue value:&range withObjCType:@encode(SUIFloatRange)];
}

- (SUIFloatRange)SUIFloatRangeValue {
    SUIFloatRange value;
    [self getValue:&value];
    return value;
}

@end
