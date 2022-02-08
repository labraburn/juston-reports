//
//  Created by Anton Spivak
//

#import "SystemUI.h"

typedef NS_ENUM(NSInteger, SUIRefreshControlState) {
    SUIRefreshControlStateHidden = 0,
    SUIRefreshControlStateUserInteraction,
    SUIRefreshControlStateRefreshing,
    SUIRefreshControlStateHidingAnimation
};

NS_ASSUME_NONNULL_BEGIN

/// Custom content view
@interface SUIRefreshControlContentView : UIView

- (void)updateWithRefreshControlState:(SUIRefreshControlState)state withProgressIfAvailable:(CGFloat)progress;

@end

/// Subclass of UIRefreshControl that can use system defined values and forward it's to `contentView`
@interface SUIRefreshControl : UIRefreshControl

@property (nonatomic, strong, readonly) SUIRefreshControlContentView *contentView;

- (instancetype)initWithContentView:(SUIRefreshControlContentView *)contentView;

@end

NS_ASSUME_NONNULL_END
