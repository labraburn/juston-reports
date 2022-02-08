//
//  Created by Anton Spivak
//

#import "UICollectionViewCompositionalLayout+SUI.h"
#import "UIView+SUI.h"

@implementation UICollectionViewCompositionalLayout (SUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // _updatePinnedSectionSupplementaryItemsForCurrentVisibleBounds
        SUISwizzleInstanceMethodOfClass(self, SUISelectorFromReversedStringParts(@"entaryItemsIfNeededWithContext:", @"_solveForPinnedSupplem", nil), @selector(sui_sw_solveForPinnedSupplementaryItemsIfNeededWithContext:));
    });
}

#pragma mark - Swizzled

// Warning! This is swizzled method.
- (void)sui_sw_solveForPinnedSupplementaryItemsIfNeededWithContext:(id)context {
    // Force exclude unclamped insets for right adjustement
    [[self collectionView] sui_setExcludesUnclampedInsets:YES];
    
    // Call original
    [self sui_sw_solveForPinnedSupplementaryItemsIfNeededWithContext:context];
    
    // Disable exluding insets
    [[self collectionView] sui_setExcludesUnclampedInsets:NO];
}

@end
