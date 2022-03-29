//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

@protocol UISUIScrollViewObserver;

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (SUI)

/// Overrides `nexResponder` with given object
/// Passing `nil` will remove overriden value
- (void)sui_overrideNextResponderWithResponder:(UIResponder * _Nullable)overridenNextResponder forType:(UIEventType)type;

/// Returns object that can observe given nested `UIScrollView`
- (id<UISUIScrollViewObserver> _Nullable)sui_scrollViewObserverForScrollView:(UIScrollView *)scrollView;

/// Returns first responder in chain if it's subclass of given class
- (UIResponder * _Nullable)sui_traverseResponderChainForSubclassOfClass:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
