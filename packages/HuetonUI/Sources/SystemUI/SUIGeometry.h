//
//  Created by Anton Spivak
//

#import "SystemUI.h"

// SUIFloatRange

typedef struct __attribute__((objc_boxable)) SUIFloatRange {
    CGFloat location;
    CGFloat length;
} SUIFloatRange;

SUI_EXTERN const SUIFloatRange SUIFloatRangeZero;

SUI_STATIC_INLINE SUIFloatRange SUIFloatRangeMake(CGFloat location, CGFloat length) {
    SUIFloatRange result = (SUIFloatRange) {
        .location = location,
        .length = length
    };
    return result;
}

SUI_STATIC_INLINE CGFloat SUIFloatMaxRange(SUIFloatRange range) {
    return (range.location + range.length);
}

SUI_STATIC_INLINE BOOL SUIFloatLocationInRange(CGFloat loc, SUIFloatRange range) {
    return (!(loc < range.location) && (loc - range.location) < range.length) ? YES : NO;
}

SUI_STATIC_INLINE BOOL SUIFloatEqualRanges(SUIFloatRange range1, SUIFloatRange range2) {
    return (range1.location == range2.location && range1.length == range2.length);
}

// SUIUnclampedInsets

typedef struct __attribute__((objc_boxable)) SUIUnclampedInsets {
    UIEdgeInsets insets;
    SUIFloatRange range;
} SUIUnclampedInsets;

SUI_EXTERN const SUIUnclampedInsets SUIUnclampedInsetsZero;

SUI_STATIC_INLINE SUIUnclampedInsets SUIUnclampedInsetsMake(UIEdgeInsets insets, SUIFloatRange range) {
    SUIUnclampedInsets result = (SUIUnclampedInsets) {
        .insets = insets,
        .range = range
    };
    return result;
}

SUI_STATIC_INLINE BOOL SUIUnclampedInsetsEqualToUnclampedInsets(SUIUnclampedInsets lhs, SUIUnclampedInsets rhs) {
    return
    UIEdgeInsetsEqualToEdgeInsets(lhs.insets, rhs.insets) &&
    lhs.range.location == rhs.range.location &&
    lhs.range.length == rhs.range.length;
}
