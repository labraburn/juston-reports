//
//  Created by Anton Spivak
//

#import "SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface SUICollectionView : UICollectionView

@property (nonatomic, assign, setter=sui_setContentOffsetUpdatesLocked:) BOOL sui_isContentOffsetUpdatesLocked;

/// Disables sytem provided mechanizm thats updates offset after changes layout or something same
- (void)sui_removeContentOffsetRestorationAnchor;

@end

NS_ASSUME_NONNULL_END
