//
//  Created by Anton Spivak
//

#import "SUI13SheetPresentationController.h"
#import "SUISheetPresentationController.h"

@import ObjectiveC.runtime;
@import ObjectiveC.message;
@import Objective42;

static Class _SUI13SheetPresentationControllerKlass = nil;

static void * kSUI13ShouldRespectPresentationContextKey = &kSUI13ShouldRespectPresentationContextKey;
static void * kSUI13ShouldFullscreenKey = &kSUI13ShouldFullscreenKey;

@interface SUISheetPresentationControllerDetent (SUI13SheetPresentationController)
@property (nonatomic, copy) SUISheetPresentationControllerDetendIdentifier identifier;
@end

@implementation SUI13SheetPresentationController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *klassName = @"_SUI13SheetPresentationController";
        NSString *superklassName = SUIReversedStringWithParts(@"tationController", @"_UISheetPresen", nil);

        O42ClassRegistration *registration = [[O42ClassRegistration alloc] initWithClassNamed:klassName
                                                                              superclassNamed:superklassName];

        // self.detents
        [registration registerInstancePropertyWithReference:[O42PatternReference referenceWithNamed:@"detents" klass:self]
                                       getterExecutionBlock:^NSArray *(UIPresentationController *self) {
            return [self performSelector:SUISelectorFromReversedStringParts(@"nts", @"_dete", nil)];
        } setterExecutionBlock:^(UIPresentationController *self, NSArray *detents) {
            [self performSelector:SUISelectorFromReversedStringParts(@"nts:", @"_setDete", nil)
                       withObject:detents];
        }];

        // self.selectedDetentIdentifier
        [registration registerInstancePropertyWithReference:[O42PatternReference referenceWithNamed:@"selectedDetentIdentifier" klass:self]
                                       getterExecutionBlock:^NSString *(UIPresentationController *self) {
            NSInteger index = [[self performSelector:SUISelectorFromReversedStringParts(@"rrentDetent", @"_indexOfCu", nil)] integerValue];
            if (index == NSNotFound) {
                return nil;
            }

            NSArray<SUISheetPresentationControllerDetent *> *detents = (NSArray<SUISheetPresentationControllerDetent *> *)[(id)self detents];
            return detents[index].identifier;
        } setterExecutionBlock:^(UIPresentationController *self, NSString *selectedDetentIdentifier) {
            NSArray<SUISheetPresentationControllerDetent *> *detents = (NSArray<SUISheetPresentationControllerDetent *> *)[(id)self detents];
            NSInteger index = [detents indexOfObjectPassingTest:^BOOL(SUISheetPresentationControllerDetent *obj, NSUInteger idx, BOOL *stop) {
                return [obj.identifier isEqualToString:selectedDetentIdentifier];
            }];

            typedef void (*function)(id, SEL, NSInteger);
            function block = (function)objc_msgSend;
            block(self, SUISelectorFromReversedStringParts(@"xOfCurrentDetent:", @"_setInde", nil), index);
        }];

        // self.largestUndimmedDetentIdentifier
        [registration registerInstancePropertyWithReference:[O42PatternReference referenceWithNamed:@"largestUndimmedDetentIdentifier" klass:self]
                                       getterExecutionBlock:^NSString *(UIPresentationController *self) {
            NSInteger index = [[self performSelector:SUISelectorFromReversedStringParts(@"tUndimmedDetent", @"_indexOfLas", nil)] integerValue];
            if (index == NSNotFound) {
                return nil;
            }

            NSArray<SUISheetPresentationControllerDetent *> *detents = (NSArray<SUISheetPresentationControllerDetent *> *)[(id)self detents];
            return detents[index].identifier;
        } setterExecutionBlock:^(UIPresentationController *self, NSString *largestUndimmedDetentIdentifier) {
            NSArray<SUISheetPresentationControllerDetent *> *detents = (NSArray<SUISheetPresentationControllerDetent *> *)[(id)self detents];
            NSInteger index = [detents indexOfObjectPassingTest:^BOOL(SUISheetPresentationControllerDetent *obj, NSUInteger idx, BOOL *stop) {
                return [obj.identifier isEqualToString:largestUndimmedDetentIdentifier];
            }];

            typedef void (*function)(id, SEL, NSInteger);
            function block = (function)objc_msgSend;
            block(self, SUISelectorFromReversedStringParts(@"astUndimmedDetent:", @"_setIndexOfL", nil), index);
        }];

        // self.shouldRespectPresentationContext
        [registration registerInstancePropertyWithReference:[O42PatternReference referenceWithNamed:@"shouldRespectPresentationContext" klass:self]
                                       getterExecutionBlock:^BOOL (UIPresentationController *self) {
            return [objc_getAssociatedObject(self, kSUI13ShouldRespectPresentationContextKey) boolValue];
        } setterExecutionBlock:^(UIPresentationController *self, BOOL value) {
            objc_setAssociatedObject(self, kSUI13ShouldRespectPresentationContextKey, @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }];

        // self.shouldFullscreen
        [registration registerInstancePropertyWithReference:[O42PatternReference referenceWithNamed:@"shouldFullscreen" klass:self]
                                       getterExecutionBlock:^BOOL (UIPresentationController *self) {
            return [objc_getAssociatedObject(self, kSUI13ShouldFullscreenKey) boolValue];
        } setterExecutionBlock:^(UIPresentationController *self, BOOL value) {
            objc_setAssociatedObject(self, kSUI13ShouldFullscreenKey, @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            typedef void (*function)(id, SEL, BOOL);
            function block = (function)objc_msgSend;
            block(self, SUISelectorFromReversedStringParts(@"tsFullScreen:", @"_setWan", nil), value);
        }];

        // [self performAnimatedChanges:]
        [registration registerInstanceMethodWithReference:[O42PatternReference referenceWithNamed:@"performAnimatedChanges:" klass:self]
                                           executionBlock:^(UIPresentationController *self, void (^changes)(void)) {

            UICubicTimingParameters *timingParameters = [[UICubicTimingParameters alloc] initWithAnimationCurve:UIViewAnimationCurveEaseOut];
            UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.28
                                                                                   timingParameters:timingParameters];
            [animator addAnimations:^{
                changes();
                id layout = [self performSelector:SUISelectorFromReversedStringParts(@"utInfo", @"_layo", nil)];
                [layout performSelector:SUISelectorFromReversedStringParts(@"ut", @"_layo", nil)];
            }];

            [animator startAnimation];
        }];

        // [self _shouldRespectDefinesPresentationContext]
        [registration registerInstanceMethodWithReference:[O42PatternReference referenceWithNamed:@"_shouldRespectDefinesPresentationContext" klass:self]
                                           executionBlock:^BOOL (UIPresentationController *self) {
            return [(id)self shouldRespectPresentationContext];
        }];


        // [self shouldPresentInFullscreen]
        [registration registerInstanceMethodWithReference:[O42PatternReference referenceWithNamed:@"shouldPresentInFullscreen" klass:self]
                                           executionBlock:^BOOL (UIPresentationController *self) {
            return ![(id)self shouldRespectPresentationContext];
        }];

        // [self dimmingViewWasTapped:]
        [registration registerInstanceMethodWithReference:[O42PatternReference referenceWithNamed:@"dimmingViewWasTapped:" klass:self]
                                           executionBlock:^(UIPresentationController *self, UIView *dimmingView) {
            if ([self.presentedViewController.presentingViewController.presentationController isKindOfClass:[self class]]) {
                // Replicate iOS 15
                return;
            } else {
                struct objc_super super = {
                    .receiver = self,
                    .super_class = class_getSuperclass([self class])
                };

                typedef void (*function)(struct objc_super *, SEL, id);
                function block = (function)objc_msgSendSuper;
                block(&super, @selector(dimmingViewWasTapped:), dimmingView);
            }
        }];
        
        // [self isKindOfClass:]
        [registration registerInstanceMethodWithReference:[O42PatternReference referenceWithNamed:@"isKindOfClass:" klass:self]
                                           executionBlock:^BOOL (UIPresentationController *self, Class klass) {
            if (klass == [SUISheetPresentationController class]) {
                return YES;
            }
            
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass([self class])
            };

            typedef BOOL (*function)(struct objc_super *, SEL, Class);
            function block = (function)objc_msgSendSuper;
            return block(&super, @selector(isKindOfClass:), klass);
        }];
        
        // [self isMemberOfClass:]
        [registration registerInstanceMethodWithReference:[O42PatternReference referenceWithNamed:@"isMemberOfClass:" klass:self]
                                           executionBlock:^BOOL (UIPresentationController *self, Class klass) {
            if ([self class] == [SUI13SheetPresentationController class] && klass == [SUISheetPresentationController class]) {
                return YES;
            }
            
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass([self class])
            };

            typedef BOOL (*function)(struct objc_super *, SEL, Class);
            function block = (function)objc_msgSendSuper;
            return block(&super, @selector(isMemberOfClass:), klass);
        }];

        _SUI13SheetPresentationControllerKlass = [registration registerClass];
    });
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
{
    self = [[_SUI13SheetPresentationControllerKlass alloc] initWithPresentedViewController:presentedViewController
                                                                  presentingViewController:presentingViewController];
    return self;
}
#pragma clang diagnostic pop

// Just caps for type encoding
- (BOOL)_shouldRespectDefinesPresentationContext { return NO; }
- (BOOL)shouldPresentInFullscreen { return NO; }
- (void)performAnimatedChanges:(void (NS_NOESCAPE ^)(void))changes {};
- (void)dimmingViewWasTapped:(UIView *)dimmingView {}

- (BOOL)isKindOfClass:(Class)aClass { return NO; }
- (BOOL)isMemberOfClass:(Class)aClass { return NO; }

@end
