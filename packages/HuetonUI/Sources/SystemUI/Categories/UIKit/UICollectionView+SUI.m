//
//  Created by Anton Spivak
//

#import "UICollectionView+SUI.h"

@import Objective42;

@implementation UICollectionView (SUI)

- (void)sui_scrollToItemAtIndexPath:(NSIndexPath *)indexPath
                   atScrollPosition:(UICollectionViewScrollPosition)scrollPosition
                           animated:(BOOL)animated
                              error:(NSError **)error
{
    __auto_type block = ^{
        [self scrollToItemAtIndexPath:indexPath
                     atScrollPosition:scrollPosition
                             animated:animated];
    };
    
    __auto_type handler = ^(NSError * _Nonnull _error) {
        if (_error != nil && error != nil) {
            *error = _error;
        }
    };
    
    throwable_execution(block, handler);
}


@end
