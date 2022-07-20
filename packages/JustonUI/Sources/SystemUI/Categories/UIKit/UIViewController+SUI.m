//
//  Created by Anton Spivak
//

#import "UIViewController+SUI.h"
#import "UIView+SUI.h"
#import "UIResponder+SUI.h"
#import "UIEdgeInsets+SUI.h"

@import Objective42;
@import ObjectiveC.runtime;

@implementation UIViewController (SUI)

#pragma mark - Setters & Getters

// sui_isContextMenuViewController

- (BOOL)sui_isContextMenuViewController {
    NSString *className = NSStringFromClass([self class]);
    // _UIContextMenu..
    return [className containsString:SUIReversedStringWithParts(@"extMenu", @"_UICont", nil)];
}

- (UIScrollView *)sui_contentScrollView {
    // _recordedContentScrollView
    UIScrollView *recordedContentScrollView = [self valueForKey:SUIReversedStringWithParts(@"dContentScrollView", @"_recorde", nil)];
    if (recordedContentScrollView == nil) {
        // _contentScrollView
        return [self o42_performSelector:SUISelectorFromReversedStringParts(@"entScrollView", @"_cont", nil)];
    }
    return recordedContentScrollView;
}

- (UIView * _Nullable)sui_transitionView {
    Class klass = SUIClassFromReversedStringParts(@"sitionView", @"UITran", nil);
    return (UIView *)[self sui_traverseResponderChainForSubclassOfClass:klass];
}

@end
