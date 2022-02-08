//
//  Created by Anton Spivak
//

#import "SUIRefreshControl.h"

static const CGFloat kSUIRefreshControlHeight = 96.0;

SUIRefreshControlState SUIRefreshControlStateWithUIrefreshControlState(long long state) {
    SUIRefreshControlState _state;;
    if (state == 0 || state == 6) {
        // 6 - only after 5
        _state = SUIRefreshControlStateHidden;
    } else if (state == 1 || state == 2) {
        _state = SUIRefreshControlStateUserInteraction;
    } else if (state == 3 || state == 5) {
        // 5 - while user currently interacting with UIScrollView
        _state = SUIRefreshControlStateRefreshing;
    } else if (state == 4) {
        _state = SUIRefreshControlStateHidingAnimation;
    }
    return _state;
}

#pragma mark - SUIRefreshControlContentView

@implementation SUIRefreshControlContentView

- (void)updateWithRefreshControlState:(SUIRefreshControlState)state withProgressIfAvailable:(CGFloat)progress {}

@end

#pragma mark - SUIRefreshControl

@implementation SUIRefreshControl

- (instancetype)initWithContentView:(SUIRefreshControlContentView *)contentView {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _contentView = contentView;
        [self addSubview:contentView];
        
        [self setValue:@(kSUIRefreshControlHeight) forKey:SUIReversedStringWithParts(@"Height", @"_snapping", nil)];
        [self setValue:@(kSUIRefreshControlHeight) forKey:SUIReversedStringWithParts(@"ControlHeight", @"_refresh", nil)];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if (obj == self.contentView) {
            return;
        }
        
        // Don't remove because instead we have a bad glitches
        obj.hidden = YES;
    }];
    
    [self.superview sendSubviewToBack:self];
    self.clipsToBounds = NO;
    
    self.contentView.center = [self oc_internalContentView].center;
    self.contentView.bounds = (CGRect) {
        .origin = CGPointZero,
        .size.width = 100.0,
        .size.height = CGRectGetHeight(self.bounds)
    };
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    [self.contentView setTintColor:tintColor];
}

// MARK: Private API

- (UIScrollView *)oc_scrollView {
    UIScrollView *scrollView = nil;
    @try {
        scrollView = [self valueForKey:SUIReversedStringWithParts(@"View", @"_scroll", nil)];
    } @catch (NSException *exception) {
        NSAssert(NO, @"%@", exception.description);
    }
    return scrollView;
}

- (CGFloat)oc_snappingHeight {
    SEL sel = SUISelectorFromReversedStringParts(@"Height", @"_snapping", nil);
    IMP imp = [self methodForSelector:sel];
    CGFloat (*super_msg)(id, SEL) = (void *)imp;
    return super_msg(self, sel);
}

- (void)oc_updateSnappingHeight {
    SEL sel = SUISelectorFromReversedStringParts(@"SnappingHeight", @"_update", nil);
    IMP imp = [self methodForSelector:sel];
    CGFloat (*super_msg)(id, SEL) = (void *)imp;
    super_msg(self, sel);
}

- (UIView *)oc_internalContentView {
    SEL sel = SUISelectorFromReversedStringParts(@"View", @"_content", nil);
    IMP imp = [self methodForSelector:sel];
    UIView *(*super_msg)(id, SEL) = (void *)imp;
    return super_msg(self, sel);
}

- (CGPoint)oc_originForContentOffset:(CGPoint)contentOffset {
    SEL sel = SUISelectorFromReversedStringParts(@"ContentOffset:", @"_originFor", nil);
    IMP imp = [self methodForSelector:sel];
    CGPoint (*super_msg)(id, SEL, CGPoint) = (void *)imp;
    return super_msg(self, sel, contentOffset);
}

- (void)_setRefreshControlState:(long long)arg2 notify:(bool)arg3 {
    SEL sel = SUISelectorFromReversedStringParts(@"State:notify:", @"_setRefreshControl", nil);
    IMP imp = [[UIRefreshControl class] instanceMethodForSelector:sel];
    void (*super_msg)(id, SEL, long long, bool) = (void *)imp;
    super_msg(self, sel, arg2, arg3);
 
    CGFloat progress = fabs([self oc_originForContentOffset:[self oc_scrollView].contentOffset].y / [self oc_snappingHeight]);
    [self.contentView updateWithRefreshControlState:SUIRefreshControlStateWithUIrefreshControlState(arg2)
                            withProgressIfAvailable:progress];
}

- (double)_refreshControlHeight {
    return kSUIRefreshControlHeight;
}

/// Disable sytem provided mechanism that updates _snappingHeight
- (void)_updateSnappingHeight {}

/// Disable sytem provided mechanism that updates _refreshControlHeight
- (void)_resizeToFitContents {}

@end
