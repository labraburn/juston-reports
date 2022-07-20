//
//  Created by Anton Spivak
//

#import "SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface SUICollectionView : UICollectionView

@property (nonatomic, assign, getter=isContentOffsetUpdatesLocked) BOOL contentOffsetUpdatesLocked;

/// Disables sytem provided mechanizm thats updates offset after changes layout or something same
- (void)removeContentOffsetRestorationAnchor;

@end

NS_ASSUME_NONNULL_END
