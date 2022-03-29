//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UISUIScrollViewObserver <NSObject>
@optional
- (void)scrollViewDidChangeContentOffset:(UIScrollView *)scrollView contentOffset:(CGPoint)contentOffset previousContentOffset:(CGPoint)previousContentOffset;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)willDecelerate;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewAnimationEnded:(UIScrollView *)arg1 finished:(BOOL)finished;
@end

@interface UIScrollView (SUI)

@property (nonatomic, assign, setter=sui_setShouldAutomaticallyFindObservers:) BOOL sui_shouldAutomaticallyFindObservers;
@property (nonatomic, assign, setter=sui_setContentOffsetAnimationDuration:) NSTimeInterval sui_contentOffsetAnimationDuration;

/// Call to trigger system mechanizm that determinates offsets that depends on insets
- (void)sui_adjustContentOffsetIfNecessary;

@end

NS_ASSUME_NONNULL_END
