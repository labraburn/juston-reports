//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (SUI)

/// Calls default `scrollToItemAtIndexPath:atScrollPosition:animated` method but catches any Objective-C exceptions
- (void)sui_scrollToItemAtIndexPath:(NSIndexPath *)indexPath
                   atScrollPosition:(UICollectionViewScrollPosition)scrollPosition
                           animated:(BOOL)animated
                              error:(NSError * __autoreleasing *)error SUI_SWIFT_ERROR;

@end

NS_ASSUME_NONNULL_END
