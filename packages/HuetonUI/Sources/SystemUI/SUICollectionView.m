//
//  Created by Anton Spivak
//

#import "SUICollectionView.h"

static NSString * kSUICollectionViewRestorationAnchorKey = nil;

@implementation SUICollectionView

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kSUICollectionViewRestorationAnchorKey = SUIReversedStringWithParts(@"etRestorationAnchor", @"_contentOffs", nil);
    });
}

- (void)sui_removeContentOffsetRestorationAnchor {
    [self setValue:nil forKey:kSUICollectionViewRestorationAnchorKey];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:kSUICollectionViewRestorationAnchorKey]) {
#if DEBUG
        NSLog(@"SUICollectionView: _contentOffsetRestorationAnchor is undefined key");
#endif
        return;
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}

#pragma mark - Private API Overrides

- (void)_performDiffableUpdate:(id)arg2 {
    CGSize previousContentSize = self.contentSize;
    CGPoint previousContentOffset = self.contentOffset;
    
    __auto_type supercall = ^{
        SEL sel = SUISelectorFromReversedStringParts(@"ableUpdate:", @"_performDiff", nil);
        IMP imp = [UICollectionView instanceMethodForSelector:sel];
        CGFloat (*super_msg)(id, SEL, id) = (void *)imp;
        super_msg(self, sel, arg2);
    };
    
    
    // Handle glithes when system calls
    // _adjustContentOffsetIfNeccessaryIfNeeded and etc
    // while perfroming updates and resets contentOffset
    BOOL previousIsContentOffsetUpdatesLocked = [self sui_isContentOffsetUpdatesLocked];
    [self sui_setContentOffsetUpdatesLocked:YES];
    supercall();
    [self sui_setContentOffsetUpdatesLocked:previousIsContentOffsetUpdatesLocked];
    
    NSArray<NSIndexPath *> *visibleIndexPaths = [[self indexPathsForVisibleItems] sortedArrayUsingSelector:@selector(compare:)];
    NSIndexPath *anchorIndexPath = [visibleIndexPaths firstObject];
    if (anchorIndexPath == nil) {
        return;
    }
    
    UICollectionViewCell *anchorCell = [self cellForItemAtIndexPath:anchorIndexPath];
    if (anchorCell == nil) {
        return;
    }
    
    // Store visible rect relative to anchored cell
    CGRect visibleRect = [self convertRect:self.bounds toView:anchorCell];
    CGSize initialSize = anchorCell.bounds.size;
    
    if (previousIsContentOffsetUpdatesLocked) {
        // Skip cause should not be affcted
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isDragging || self.isDecelerating || self.isTracking) {
            return;
        }
        
        [UIView performWithoutAnimation:^{
            [self layoutIfNeeded];
        }];
        
        CGPoint contentOffset = self.contentOffset;
            
        id<UICollectionViewDataSource> dataSource = [self dataSource];
        if (anchorIndexPath.section < [dataSource numberOfSectionsInCollectionView:self] &&
            anchorIndexPath.item < [dataSource collectionView:self numberOfItemsInSection:anchorIndexPath.section])
        {
            UICollectionViewCell *anchorCell = [self cellForItemAtIndexPath:anchorIndexPath];
            if (anchorCell != nil) {
                CGRect updatedVisibleRect = [self convertRect:self.bounds toView:anchorCell];
                CGSize updatedSize = anchorCell.bounds.size;
                
                CGFloat diff = visibleRect.origin.y - updatedVisibleRect.origin.y;
                diff += initialSize.height - updatedSize.height;
                    
                contentOffset.y += diff;
            }
        }
        
        CGFloat minimumYOffset = self.safeAreaInsets.top;
        CGFloat maximumYOffset = self.contentSize.height + self.safeAreaInsets.bottom - CGRectGetHeight(self.bounds);
        if (maximumYOffset < 0) {
            // Handle when contentSize smaller than bounds
            maximumYOffset = 0;
        }
        
        if (contentOffset.y < minimumYOffset) {
            return;
        }
        
        if (contentOffset.y > maximumYOffset) {
            contentOffset.y = maximumYOffset;
        }
        
        [UIView performWithoutAnimation:^{
            [self setContentOffset:contentOffset];
        }];
    });
}

- (void)adjustedContentInsetDidChange {
    [super adjustedContentInsetDidChange];
}

#pragma mark - Setters & Getters

- (void)setBounds:(CGRect)bounds {
    CGRect _bounds = bounds;
    if (self.sui_isContentOffsetUpdatesLocked && !CGPointEqualToPoint(self.bounds.origin, _bounds.origin)) {
        _bounds.origin = self.bounds.origin;
    }
    
    [super setBounds:_bounds];
}

- (void)setContentOffset:(CGPoint)contentOffset {
    CGPoint _contentOffset = contentOffset;
    if (self.sui_isContentOffsetUpdatesLocked && !CGPointEqualToPoint(self.contentOffset, _contentOffset)) {
        _contentOffset = self.contentOffset;
    }
    
    [super setContentOffset:_contentOffset];
}

@end
